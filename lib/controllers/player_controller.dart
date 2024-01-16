import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();
  RxList<SongModel> songs = <SongModel>[].obs;
  RxList<String> filePaths = <String>[].obs;
  RxSet<String> folders = <String>{}.obs;
  RxMap<String, List<SongModel>> groupedFiles = <String, List<SongModel>>{}.obs;
  RxList<String> directories = <String>[].obs;

  var listLength = 0.obs;
  var playIndex = 0.obs;
  var isPlaying = false.obs;
  var playUri = ''.obs;
  var nextUri = ''.obs;

  var duration = ''.obs;
  var position = ''.obs;

  var max = 0.0.obs;
  var value = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermission();
  }

  checkPermission() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    PermissionStatus perm;
    PermissionStatus permAudio;
    PermissionStatus permVideos;
    PermissionStatus permImages;
    if (deviceInfo.version.sdkInt > 32) {
      permAudio = await Permission.audio.request();
      permVideos = await Permission.videos.request();
      permImages = await Permission.photos.request();
      log('nilai permAudio: ${permAudio.isGranted}');
      log('nilai permVideos: ${permVideos.isGranted}');
      log('nilai permImages: ${permImages.isGranted}');
      if (!(permAudio.isGranted && permVideos.isGranted && permImages.isGranted)) {
        checkPermission();
      }
    } else {
      perm = await Permission.storage.request();
      permAudio = await Permission.audio.request();
      permVideos = await Permission.videos.request();
      permImages = await Permission.photos.request();

      if (!(perm.isGranted && permAudio.isGranted && permVideos.isGranted && permImages.isGranted)) {
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
      isPlaying(true);
      updatePosition();
    } on Exception catch (e) {
      debugPrint(e.toString());
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

  stopSong() async {
    isPlaying(false);
    await audioPlayer.stop();
  }

  pauseSong() async {
    isPlaying(false);
    await audioPlayer.pause();
  }

  stopSongPlayer() async {
    try {
      await audioPlayer.stop();
      audioPlayer.dispose;

      isPlaying(false);
      changeDurationToSeconds(0);

      updatePosition();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  startSong() async {
    await audioPlayer.stop();

    audioPlayer.dispose;

    isPlaying(false);
    changeDurationToSeconds(0);

    updatePosition();
    isPlaying(true);
    await audioPlayer.play();
  }

  updatePosition() {
    audioPlayer.durationStream.listen(
      (d) {
        duration.value = d.toString().split(".")[0];
        max.value = d!.inSeconds.toDouble();
      },
    );
    audioPlayer.positionStream.listen(
      (p) {
        position.value = p.toString().split(".")[0];
        value.value = p.inSeconds.toDouble();
      },
    );
  }

  changeDurationToSeconds(seconds) {
    var duration = Duration(seconds: seconds);
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