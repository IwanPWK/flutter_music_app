import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lrc/lrc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;

import '../models/folder_model.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();
  RxList<SongModel> songs = <SongModel>[].obs;
  RxList<String> filePaths = <String>[].obs;
  RxSet<String> folders = <String>{}.obs;
  RxMap<String, List<SongModel>> groupedFiles = <String, List<SongModel>>{}.obs;
  RxList<String> directories = <String>[].obs;
  RxList<SongModel> listMusics = <SongModel>[].obs;
  RxList<SongModel> foundMusic = <SongModel>[].obs;
  RxList<FolderData> foundFolder = <FolderData>[].obs;
  RxList<FolderData> listFolder = <FolderData>[].obs;
  RxList<String> idIndex = <String>[].obs;
  var lyricModel = LyricsModelBuilder.create().bindLyricToMain('').getModel().obs;
  // StreamController<String> controllerStream = StreamController<String>();
  // late StreamSubscription<String> subscription;

  // var showLyric = ''.obs;
  var listLength = 0.obs;
  var playIndex = 0.obs;
  var isPlaying = false.obs;
  var playUri = ''.obs;
  var nextUri = ''.obs;
  var songLyric = """ """.obs;
  var isPause = false.obs;
  var lyricPosition = 0.obs;
  // var lyricDuration = Duration(milliseconds: 0).obs;
  var isStop = false.obs;
  var isLyricStream = true.obs;
  var playProgress = 0.obs;
  var isTitleAscending = true.obs;
  var isFolderAscending = true.obs;
  var isListToPlayer = true.obs;
  var duration = ''.obs;
  var position = ''.obs;

  var max = 11.0.obs;
  var value = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermission();

    // foundMusic = listMusics; // membuat referensi, saling terhubung
    // subscription = controllerStream.stream.listen((data) {
    //   // Callback yang akan dijalankan saat data diterima
    //   // Di sini, kita hanya mencetak data ke konsol
    //   // print('Data: $data');
    // });
  }

  @override
  void dispose() {
    // subscription.cancel();
    // controllerStream.close(); // Jangan lupa menutup StreamController
    super.dispose();
  }

  checkPermission() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    PermissionStatus perm;
    PermissionStatus permAudio;
    PermissionStatus permVideos;
    PermissionStatus permImages;
    PermissionStatus permExtStorage;
    if (deviceInfo.version.sdkInt > 32) {
      permAudio = await Permission.audio.request();
      permVideos = await Permission.videos.request();
      permImages = await Permission.photos.request();
      permExtStorage = await Permission.manageExternalStorage.request();
      log('nilai permAudio: ${permAudio.isGranted}');
      log('nilai permVideos: ${permVideos.isGranted}');
      log('nilai permImages: ${permImages.isGranted}');
      log('nilai permExtStorage: ${permExtStorage.isGranted}');
      if (!(permAudio.isGranted && permVideos.isGranted && permImages.isGranted && permExtStorage.isGranted)) {
        checkPermission();
      }
    } else {
      perm = await Permission.storage.request();
      permAudio = await Permission.audio.request();
      permVideos = await Permission.videos.request();
      permImages = await Permission.photos.request();
      permExtStorage = await Permission.manageExternalStorage.request();

      if (!(perm.isGranted && permAudio.isGranted && permVideos.isGranted && permImages.isGranted && permExtStorage.isGranted)) {
        checkPermission();
      }
    }
  }

  // updtPlayIndex(index) {
  //   playIndex.value = index;
  // }

  playSong(String? uri, index) async {
    playIndex.value = index;
    playUri.value = uri!;
    log('uri: $uri');
    try {
      audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(playUri.value),
        ),
      );
      max.value = foundMusic[index].duration!.toDouble();
      updatePosition();
      isStop(false);
      isPause(false);
      isLyricStream(true);
      isPlaying(true);
      await audioPlayer.play();
    } on Exception catch (e) {
      debugPrint('error playSong: ${e.toString()}');
    }
  }

  void showLyric(String? path) {
    if (path != null && path != '') {
      log('showLyric: $path');
      // var cleanedPath = path.replaceAll("'", "\\'");
      readFromFile(path);
      log('cleanedPath: $path');
    }
    /*try {
      ConcatenatingAudioSource(
        useLazyPreparation: true,
        shuffleOrder: DefaultShuffleOrder(),
        children: [
          AudioSource.uri(
            Uri.parse(uri!),
          ),
        ],
      );
      audioPlayer.play();
      isPlaying(true);
      updatePosition();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }*/
  }

  startSong() async {
    isStop(false);
    isPause(false);
    isLyricStream(true);
    isPlaying(true);
    // subscription.resume();

    await audioPlayer.play();
  }

  pauseSong() async {
    isStop(false);
    isPause(true);
    // subscription.pause();
    isPlaying(false);
    await audioPlayer.pause();
  }

  stopSongPlayer() async {
    try {
      audioPlayer.dispose;

      isStop(true);
      isPause(false);
      isPlaying(false);
      changeDurationToMilliseconds(0);

      updatePosition();
      await audioPlayer.stop();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  againSong() async {
    await audioPlayer.stop();

    audioPlayer.dispose;
    isStop(true);
    isPause(false);
    isPlaying(false);
    changeDurationToMilliseconds(0);

    updatePosition();
    isLyricStream(true);
    isPlaying(true);

    isStop(false);
    isPause(false);
    await audioPlayer.play();
  }

  updatePosition() {
    audioPlayer.durationStream.listen(
      (d) {
        duration.value = d.toString().split(".")[0];
        max.value = d!.inMilliseconds.toDouble();
      },
    );
    audioPlayer.positionStream.listen(
      (p) {
        position.value = p.toString().split(".")[0];
        value.value = p.inMilliseconds.toDouble();
        playProgress.value = p.inMilliseconds;
      },
    );
  }

  changeDurationToMilliseconds(milliseconds) {
    var duration = Duration(milliseconds: milliseconds);
    playProgress.value = milliseconds;
    audioPlayer.seek(duration);
  }

  Future<Map<String, List<SongModel>>> queryAndSaveSongs() async {
    // Lakukan querySongs

    List<SongModel> queriedSongs = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );
    // num++;
    // Simpan hasil query ke dalam List songs
    songs.value = queriedSongs;
    log('cek songsssssssssss: ${queriedSongs}');
    // log('Jumlah $num');

    for (int index = 0; index < queriedSongs.length; index++) {
      var songData = queriedSongs[index].data;
      var queriedSong = queriedSongs[index];
      var directory = getDirectory(songData);
      String folderName = getFolderName(songData);
      if (!groupedFiles.containsKey(folderName)) {
        groupedFiles[folderName] = [];
      }
      if (!directories.contains(directory)) {
        directories.add(directory);
      }
      groupedFiles[folderName]!.add(queriedSong);
    }

    log('periksa directories: ${directories.value}');
    log('Folders Name: ${groupedFiles['listen']}');
    return groupedFiles;
  }

  String getFolderName(String filePath) {
    String directory = getDirectory(filePath);
    String folderName = path.basename(directory);
    return folderName;
  }

  String getDirectory(String filePath) {
    String directory = path.dirname(filePath);
    return directory;
  }

  // getData() async {
  //   String response = await rootBundle.loadString('music_lyrics/lirik_musik.txt');
  //   songLyric.value = response;
  // }

  void readFromFile(String filePath) {
    try {
      String newPath = removeFileExtension(filePath);
      log('newPath: $newPath');
      File file = File(newPath);

      if (file.existsSync()) {
        // Baca isi file
        // log('123456789');
        var song = file.readAsStringSync();
        setLrc(song);
        // log('1234567');
        // log('Isi file: $contents');
      } else {
        log('File tidak ditemukan.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  setLrc(String lyric) {
    songLyric.value = """
$lyric
""";

    lyricModel.value = LyricsModelBuilder.create().bindLyricToMain(songLyric.value).getModel();
  }

  String removeFileExtension(String filePath) {
    String newModifiedPath = '';

    // Mencari posisi titik (.) terakhir dalam path
    int lastDotIndex = filePath.lastIndexOf('.');

    // Jika titik ditemukan dan bukan merupakan bagian dari direktori (contoh: /path/to/file.xyz/)
    if (lastDotIndex != -1 && !filePath.substring(lastDotIndex).contains('/')) {
      // Mengambil substring hingga sebelum titik terakhir
      String modifiedPath = filePath.substring(0, lastDotIndex);
      newModifiedPath = '$modifiedPath.lrc';
    } else {
      // Jika tidak ada ekstensi, gunakan path asli
      newModifiedPath = '$filePath.lrc';
    }

    return newModifiedPath;
  }

  testLrc(String songLyric) {
    log('sebelum song Armada');
    var song = """
$songLyric
""";
    log('isi file song : $song');
    var lrc = Lrc.parse(song);
    log('sesudah song Armada');
    //Prints the formatted string. The output is mostly the same as the string to be parsed.
    print(lrc.format() + '\n');
    var abc = printLyrics(lrc);
    return abc;
  }

  printLyrics(Lrc lrc) async* {
    String lrcData;

    await for (LrcStream i in lrc.stream) {
      lrcData = i.current.lyrics;
      yield lrcData;
      // i.position = 10;
      // if (isLyricStream.value) {
      //   if (isPause.value) {
      //     lyricPosition.value = i.position;
      //     isLyricStream(false);
      //     log('Pause positionLRC : ${lyricPosition.value}');
      //   }
      //   if (isStop.value) {
      //     lyricPosition.value = 0;
      //     isLyricStream(false);
      //   }
      //   if (isPlaying.value) {
      //     i.position = i.position;
      //     lrcData = i.current.lyrics;
      //     log('Start 1 positionLRC : $lrcData');
      //     yield i.position.toString();
      //   }
      // }
      // else {
      //   if (isStop.value) {
      //     lyricPosition.value = 0;
      //     isLyricStream(false);
      //   }
      //   if (isPlaying.value) {
      //     i.position = lyricPosition.value;
      //     lrcData = i.current.lyrics;
      //     isLyricStream(true);
      //     log('Start positionLRC : ${i.current.lyrics}');
      //     yield i.position.toString();
      //   }
      // }

      // i.position = lyricPosition.value;

      // print('ABC ${i.current.lyrics}');
      // showLyric(i.current.lyrics);
      // lrcData = isPause.value ? 'PAUSE' : i.position = 4;
    }
  }

  void runFilterTitle(String enteredKeyword) {
    List<SongModel> results = [];
    log('cek listMusicssss : ${listMusics.value}');
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = List.from(listMusics.value);
    } else {
      results = listMusics.where((listMusic) => listMusic.displayNameWOExt.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
      log('cek listMusicssss 12345 : ${listMusics.value}');
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI

    foundMusic.value = results;
    log('cek results : $results');
    log('cek entered keyword : $enteredKeyword');
    log('cek foundMusic : ${foundMusic.value}');
  }

  void runFilterFolder(String enteredKeyword) {
    List<FolderData> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = List.from(listFolder.value);
    } else {
      results = listFolder.where((listFolder) => listFolder.folderName.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    foundFolder.value = results;
  }

  sortTitleList(bool isAscending) {
    foundMusic.value.sort((a, b) {
      if (isAscending) {
        // foundMusic.value = foundMusic.toList();
        log('sedang ditest isAscending ${foundMusic.value}');
        return a.displayNameWOExt.compareTo(b.displayNameWOExt);
      } else {
        // foundMusic.value = foundMusic.toList();
        log('sedang ditest isDescending ${foundMusic.value}');
        return b.displayNameWOExt.compareTo(a.displayNameWOExt);
      }
    });
    foundMusic.value = foundMusic.toList();
    log('sedang ditest isFinal ${foundMusic.value}');
  }

  sortFolderList(bool isAscending) {
    foundFolder.value.sort((a, b) {
      if (isAscending) {
        // foundMusic.value = foundMusic.toList();
        log('sedang ditest isAscending ${foundFolder.value}');
        return a.folderName.compareTo(b.folderName);
      } else {
        // foundMusic.value = foundMusic.toList();
        log('sedang ditest isDescending ${foundFolder.value}');
        return b.folderName.compareTo(a.folderName);
      }
    });
    foundFolder.value = foundFolder.toList();
    log('sedang ditest isFinal ${foundFolder.value}');
  }

  isTitleSortAscending() {
    isTitleAscending.value = !isTitleAscending.value;
  }

  isFolderSortAscending() {
    isFolderAscending.value = !isFolderAscending.value;
  }

//   addListFoundFolder(Map<String, String> data) {
//   var folderData = FolderData(
//     folderName: data['folderName'] ?? '',
//     directoryName: data['directoryName'] ?? '',
//   );
//   listFolder.add(folderData);
//   foundFolder.add(folderData);
// }

  addListFolderModel(String folderName, String directoryName) {
    var folderData = FolderData(
      folderName: folderName,
      directoryName: directoryName,
    );
    listFolder.add(folderData);
    foundFolder.add(folderData);
  }

  searchNewPlayIndex() {
    int newPlayIndex;
    String searchedIndex = playUri.value;
    newPlayIndex = foundMusic.indexWhere((data) => data.uri == searchedIndex);
    playIndex.value = newPlayIndex == -1 ? playIndex.value : newPlayIndex;
    log('cek new play index : ${playIndex.value}');
  }

  StreamSubscription? autoNextPlay(int index, PlayerController controller, List<SongModel> finalData) {
    StreamSubscription? subscription;
    subscription = controller.value.listen((newValue) {
      'log(cek max value : ${controller.max.value})';
      if (newValue >= controller.max.value && (index) < (finalData.length - 1)) {
        log('cek max value : ${controller.max.value}');
        // Panggil metode atau fungsi yang ingin dijalankan
        controller.playSong(finalData[index + 1].uri, index + 1);
        controller.showLyric(finalData[index].data);
      } else if (newValue >= controller.max.value && (index + 1) > (finalData.length - 1)) {
        controller.stopSongPlayer();
        if (subscription != null) {
          subscription.cancel();
        }
      } else if (newValue >= controller.max.value) {
        controller.stopSongPlayer();
        if (subscription != null) {
          subscription.cancel();
        }
      }
    });
    return subscription;
  }
}
   // Lakukan sesuatu dengan data lagu, misalnya:
    // filePaths.value.add(songData);

    // for (String filePath in filePaths) {
    //   String folderName = getFolderName(filePath);
    //   if (!groupedFiles.containsKey(folderName)) {
    //     groupedFiles[folderName] = [];
    //   }
    //   groupedFiles[folderName]!.add(queriedSongs);
    // }
    // log('Folder Name: $folders');

    // Tampilkan hasil query jika diperlukan
    // log('Total Songs: ${songs.length}');
    // log('cek queriedSongs: ${queriedSongs}');
    // for (var song in songs) {
    //   log('Song Title: ${song.title}, Artist: ${song.artist}');
    // }