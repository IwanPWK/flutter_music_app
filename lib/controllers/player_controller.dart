import 'dart:async';
import 'dart:collection';
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
// import 'package:path/path.dart' as path;
// import 'package:flutter/services.dart' show rootBundle;

import '../helpers/path_helper.dart';
import '../models/audio_model.dart';
import '../models/folder_model.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();

  RxList<AudioModel> songList = <AudioModel>[].obs;
  RxList<String> filePaths = <String>[].obs;
  RxSet<String> folders = <String>{}.obs;
  RxMap<String, List<AudioModel>> groupedFiles = <String, List<AudioModel>>{}.obs;
  RxMap<String, List<AudioModel>> foundGroupedFiles = <String, List<AudioModel>>{}.obs;
  RxList<String> directoryPaths = <String>[].obs;
  RxList<AudioModel> listMusics = <AudioModel>[].obs;
  RxList<AudioModel> foundMusic = <AudioModel>[].obs;
  // RxList<FolderData> foundFolder = <FolderData>[].obs;
  RxList<FolderData> listFolder = <FolderData>[].obs;
  RxList<String> idIndex = <String>[].obs;
  var lyricModel = LyricsModelBuilder.create().bindLyricToMain('').getModel().obs;
  RxList<dynamic> listFolderNames = [].obs;
  // Rx<BannerAd?> testTipe =

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
    // checkPermission();

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

  Future<Map<String, List<AudioModel>>> queryAndSaveSongs() async {
    // List<AudioModel> audioList = [];
    // Lakukan querySongs

    List<SongModel> queriedSongs = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );

    // num++;
    // Simpan hasil query ke dalam List songs
    // songs.value = queriedSongs;
    // log('cek songsssssssssss: ${queriedSongs}');
    // log('Jumlah $num');
    log("Cek queriedSongsss: ${queriedSongs[0].duration}");
    songList.value = List.from(queriedSongs.map((data) => AudioModel.fromAudioQuery(data)));
    log('cek cek cek cek');
    // await Future.delayed(Duration.zero);
    // log('Cek songList: $audioList');

    for (AudioModel audioModel in songList.value) {
      String folderName = getFolderName(audioModel.directoryPath!);
      log('Cek folderName: $folderName');
      if (!groupedFiles.containsKey(folderName)) {
        groupedFiles[folderName] = [];
      }
      if (!foundGroupedFiles.containsKey(folderName)) {
        foundGroupedFiles[folderName] = [];
      }
      groupedFiles[folderName]!.add(audioModel);
      foundGroupedFiles[folderName]!.add(audioModel);
    }
    log('Cek groupedFiles: $groupedFiles');
    // for (int index = 0; index < queriedSongs.length; index++) {
    //   var pathSong = queriedSongs[index].data;
    //   var queriedSong = queriedSongs[index];
    //   var directoryPath = getDirectory(pathSong);
    //   String folderName = getFolderName(pathSong);
    //   if (!groupedFiles.containsKey(folderName)) {
    //     groupedFiles[folderName] = [];
    //   }
    //   if (!foundGroupedFiles.containsKey(folderName)) {
    //     foundGroupedFiles[folderName] = [];
    //   }
    //   if (!directories.contains(directoryPath)) {
    //     directories.add(directoryPath);
    //   }
    //   groupedFiles[folderName]!.add(queriedSong);
    //   foundGroupedFiles[folderName]!.add(queriedSong);
    // }

    // log('periksa directories: ${directories.value}');
    // log('Folders Name: ${groupedFiles['listen']}');
    return groupedFiles;
  }

  // String getFolderName(String filePath) {
  //   String directory = getDirectory(filePath);
  //   String folderName = path.basename(directory);
  //   return folderName;
  // }

  // String getDirectory(String filePath) {
  //   String directory = path.dirname(filePath);
  //   return directory;
  // }

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
    List<AudioModel> results = [];
    log('cek listMusicssss : ${listMusics.value}');
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = List.from(listMusics.value);
    } else {
      results = listMusics.where((listMusic) => listMusic.title!.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
      log('cek listMusicssss 12345 : ${listMusics.value}');
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI

    foundMusic.value = results;
    log('cek results : $results');
    log('cek entered keyword : $enteredKeyword');
    log('cek foundMusic : ${foundMusic.value}');
  }

  void runFilterGroupedFiles(String enteredKeyword) {
    Map<String, List<AudioModel>> results = {};
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = Map.from(groupedFiles);
    } else {
      results = Map.fromEntries(groupedFiles.entries.where((entry) => entry.key.toLowerCase().contains(enteredKeyword.toLowerCase())));
      // we use the toLowerCase() method to make it case-insensitive
    }
    foundGroupedFiles.value = results;
  }

  sortTitleList(bool isAscending) {
    foundMusic.sort((a, b) {
      if (isAscending) {
        // foundMusic.value = foundMusic.toList();
        log('sedang ditest isAscending ${foundMusic.value}');
        return a.title!.compareTo(b.title!);
      } else {
        // foundMusic.value = foundMusic.toList();
        log('sedang ditest isDescending ${foundMusic.value}');
        return b.title!.compareTo(a.title!);
      }
    });
    foundMusic.value = foundMusic.toList();
    log('sedang ditest isFinal ${foundMusic.value}');
  }

  sortFolderList(bool isAscending) {
    Map<String, List<AudioModel>> results;

    results = SplayTreeMap<String, List<AudioModel>>.from(foundGroupedFiles, (a, b) {
      final aLower = a.toLowerCase();
      final bLower = b.toLowerCase();
      return isAscending ? aLower.compareTo(bLower) : bLower.compareTo(aLower);
    });

    log('cek results sort folder : ${results.keys.elementAt(0)}, ${results.keys.elementAt(1)}, ${results.keys.elementAt(2)}, ${results.keys.elementAt(3)}');
    log('cek nilai results : $results');
    foundGroupedFiles.clear();
    foundGroupedFiles.addAll(RxMap<String, List<AudioModel>>.from(results));
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

  // addListFolderModel(String folderName, String directoryName) {
  //   var folderData = FolderData(
  //     folderName: folderName,
  //     directoryName: directoryName,
  //   );
  //   listFolder.add(folderData);
  //   foundFolder.add(folderData);
  // }

  searchNewPlayIndex() {
    int newPlayIndex;
    String searchedIndex = playUri.value;
    newPlayIndex = foundMusic.indexWhere((data) => data.uri == searchedIndex);
    playIndex.value = newPlayIndex == -1 ? playIndex.value : newPlayIndex;
    log('cek new play index : ${playIndex.value}');
  }

  StreamSubscription<double>? autoNextPlay(PlayerController controller, List<AudioModel> finalData) {
    StreamSubscription<double>? subscription;
    subscription = controller.value.listen((newValue) {
      'log(cek max value : ${controller.max.value})';
      if (newValue >= controller.max.value && (playIndex.value) < (finalData.length - 1)) {
        // playIndex.value = index;
        // log('cek max value : ${controller.max.value}');
        log('pertama dijalankan');
        // Panggil metode atau fungsi yang ingin dijalankan
        log('cek index di autoNextPlay 0: ${playIndex.value}');
        playIndex.value += 1;
        controller.playSong(finalData[playIndex.value].uri, playIndex.value);
        log('cek index di autoNextPlay 1: ${playIndex.value}');
        log('cek finalData.length di autoNextPlay : ${finalData.length}');
        controller.showLyric(finalData[playIndex.value].audioPath);
      } else if (newValue >= controller.max.value && (playIndex.value + 1) > (finalData.length - 1)) {
        log('cek index di kedua autoNextPlay 0: ${playIndex.value}');
        // playIndex.value += 1;
        controller.stopSongPlayer();
        log('kedua dijalankan');
        log('cek index di kedua autoNextPlay 1: ${playIndex.value}');
        if (subscription != null) {
          subscription.cancel();
        }
      } else if (newValue >= controller.max.value) {
        controller.stopSongPlayer();
        log('ketiga dijalankan');
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