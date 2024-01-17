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

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();
  RxList<SongModel> songs = <SongModel>[].obs;
  RxList<String> filePaths = <String>[].obs;
  RxSet<String> folders = <String>{}.obs;
  RxMap<String, List<SongModel>> groupedFiles = <String, List<SongModel>>{}.obs;
  RxList<String> directories = <String>[].obs;
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

  var duration = ''.obs;
  var position = ''.obs;

  var max = 0.0.obs;
  var value = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermission();
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

  playSong(String? uri, index) {
    playIndex.value = index;
    playUri.value = uri!;
    log('uri: $uri');
    try {
      audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(playUri.value),
        ),
      );
      audioPlayer.play();
      isStop(false);
      isPause(false);
      isLyricStream(true);
      isPlaying(true);

      updatePosition();
    } on Exception catch (e) {
      debugPrint(e.toString());
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
      await audioPlayer.stop();
      audioPlayer.dispose;

      isStop(true);
      isPause(false);
      isPlaying(false);
      changeDurationToMilliseconds(0);

      updatePosition();
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
      if (!directories.value.contains(directory)) {
        directories.value.add(directory);
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