import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../consts/colors.dart';
import '../controllers/player_controller.dart';

class Player extends StatelessWidget {
  final List<SongModel> data;
  var lyricUI = UINetease();

  Player({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<PlayerController>();
    log('cek playIndex : ${controller.playIndex.value}');
    controller.value.listen((newValue) {
      if (newValue == controller.max.value && (controller.playIndex.value) < (data.length - 1) && controller.isPlaying.value) {
        // Panggil metode atau fungsi yang ingin dijalankan
        controller.playSong(data[controller.playIndex.value + 1].uri, controller.playIndex.value + 1);
        controller.showLyric(data[controller.playIndex.value].data);
      } else if (newValue == controller.max.value && (controller.playIndex.value + 1) > (data.length - 1)) {
        controller.stopSongPlayer();
      }
    });
    // Stream<String> stream = controller.controllerStream.stream;
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, // remove back button
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          children: [
            Obx(
              () => Container(
                clipBehavior: Clip.antiAliasWithSaveLayer, // make artwork circle shape
                height: size * 0.8,
                width: size * 0.8,
                alignment: Alignment.center,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
                child: QueryArtworkWidget(
                  id: data[controller.playIndex.value].id,
                  type: ArtworkType.AUDIO,
                  artworkHeight: double.infinity,
                  artworkWidth: double.infinity,
                  nullArtworkWidget: const Icon(
                    Icons.music_note,
                    size: 40,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: whiteColor,
                ),
                child: Obx(
                  () => Column(
                    children: [
                      Text(
                        data[controller.playIndex.value].displayNameWOExt,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          color: bgDarkColor,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        data[controller.playIndex.value].artist.toString(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          color: bgDarkColor,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Obx(
                        () => Row(
                          children: [
                            Text(
                              controller.position.value,
                              style: const TextStyle(
                                color: bgDarkColor,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                thumbColor: slideColor,
                                inactiveColor: bgColor,
                                activeColor: slideColor,
                                min: const Duration(milliseconds: 0).inMilliseconds.toDouble(),
                                max: controller.max.value,
                                value: controller.value.value,
                                onChanged: (newValue) {
                                  controller.changeDurationToMilliseconds(newValue.toInt());
                                  newValue = newValue;
                                },
                              ),
                            ),
                            Text(
                              controller.duration.value,
                              style: const TextStyle(
                                color: bgDarkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {
                              controller.playSong(data[controller.playIndex.value - 1].uri, controller.playIndex.value - 1);
                              controller.showLyric(data[controller.playIndex.value].data);
                            },
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              size: 40,
                              color: bgDarkColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              controller.stopSongPlayer();
                            },
                            icon: const Icon(
                              Icons.stop,
                              size: 40,
                              color: bgDarkColor,
                            ),
                          ),
                          Obx(
                            () => CircleAvatar(
                              radius: 35,
                              backgroundColor: bgDarkColor,
                              child: Transform.scale(
                                scale: 2.5,
                                child: IconButton(
                                  onPressed: () {
                                    if (controller.isPlaying.value && controller.value.value != controller.max.value) {
                                      controller.pauseSong();
                                      // stream.p
                                      print('next song ${controller.playIndex.value + 1}');
                                    } else if (controller.isPlaying.value && controller.value.value == controller.max.value) {
                                      controller.againSong();
                                      // controller.isPause(false);
                                    } else {
                                      controller.startSong();
                                      // controller.testLrc(controller.songLyric.value);
                                      controller.showLyric(data[controller.playIndex.value].data);
                                    }
                                  },
                                  icon: controller.isPlaying.value && controller.value.value != controller.max.value
                                      ? const Icon(
                                          Icons.pause,
                                          color: whiteColor,
                                        )
                                      : const Icon(
                                          Icons.play_arrow_rounded,
                                          color: whiteColor,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              controller.playSong(data[controller.playIndex.value + 1].uri, controller.playIndex.value + 1);
                              controller.showLyric(data[controller.playIndex.value].data);
                              log('cek next : ${data[(controller.playIndex.value)].data}');
                            },
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              size: 40,
                              color: bgDarkColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Expanded(
                        child: Obx(() {
                          log('cek Lyric playProgress : ${controller.playProgress.value}');
                          return LyricsReader(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            model: controller.lyricModel.value,
                            position: controller.playProgress.value,
                            lyricUi: lyricUI,
                            playing: controller.isPlaying.value,
                            size: Size(double.infinity, MediaQuery.of(context).size.height / 2),
                            emptyBuilder: () => Center(
                              child: Text(
                                "No lyrics",
                                style: lyricUI.getOtherMainTextStyle(),
                              ),
                            ),
                            selectLineBuilder: (progress, confirm) {
                              return Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        LyricsLog.logD("点击事件");
                                        confirm.call();

                                        controller.changeDurationToMilliseconds(progress);
                                      },
                                      icon: Icon(Icons.play_arrow, color: Colors.green)),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(color: Colors.green),
                                      height: 1,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Text(
                                    progress.toString(),
                                    style: TextStyle(color: Colors.green),
                                  )
                                ],
                              );
                            },
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
