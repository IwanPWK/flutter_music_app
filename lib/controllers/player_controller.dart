import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();
  List<SongModel> songs = <SongModel>[];

  var playIndex = 0.obs;
  var isPlaying = false.obs;

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

  playSong(String? uri, index) {
    playIndex.value = index;
    try {
      audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(uri!),
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

  // Future<void> queryAndSaveSongs() async {
  //   // Lakukan querySongs
  //   List<SongModel> queriedSongs = await audioQuery.querySongs(
  //     ignoreCase: true,
  //     orderType: OrderType.ASC_OR_SMALLER,
  //     sortType: null,
  //     uriType: UriType.EXTERNAL,
  //   );

  //   // Simpan hasil query ke dalam List songs
  //   songs = queriedSongs;

  //   // Tampilkan hasil query jika diperlukan
  //   log('Total Songs: ${songs.length}');
  //   for (var song in songs) {
  //     log('Song Title: ${song.title}, Artist: ${song.artist}');
  //   }
  // }
}
