import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../consts/colors.dart';
import '../controllers/player_controller.dart';
import '../models/audio_model.dart';

class Player extends StatelessWidget {
  final List<dynamic> data;
  var lyricUI = UINetease();
  StreamSubscription? subscription;

  // void autoNextPlay(int index, PlayerController controller, List<SongModel> finalData) {
  //   subscription = controller.value.listen((newValue) {
  //     'log(cek max value : ${controller.max.value})';
  //     if (newValue >= controller.max.value && (index) < (finalData.length - 1)) {
  //       log('cek max value : ${controller.max.value}');
  //       // Panggil metode atau fungsi yang ingin dijalankan
  //       controller.playSong(finalData[index + 1].uri, index + 1);
  //       controller.showLyric(finalData[index].data);
  //     } else if (newValue == controller.max.value && (index + 1) > (finalData.length - 1)) {
  //       controller.stopSongPlayer();
  //       if (subscription != null) {
  //         subscription!.cancel();
  //       }
  //     }
  //   });
  // }

  Player({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<PlayerController>();
    log('cek data player : $controller.foundMusic');
    log('cek data length player: ${controller.foundMusic.length}');
    log('cek playIndex value : ${controller.playIndex.value}');
    log('cek isPlaying value : ${controller.isPlaying.value}');

    if (controller.isPlaying.value && controller.isListToPlayer.value) {
      log('cek autonextplay');
      log('cek controller ${controller.foundMusic}');
      subscription = controller.autoNextPlay(controller, controller.foundMusic);
      controller.isListToPlayer(false);
    }

    // log('cek uri data : ${data[controller.playIndex.value + 2]}');

    // autoNextPlay(controller.playIndex.value, controller, controller.foundMusic, controller.isPlaying.value);

    // controller.value.listen((newValue) {
    //   if (data[controller.playIndex.value + 1].data != null)
    //     log('cek logika value 1 : ${(newValue >= controller.max.value && (controller.playIndex.value) < (data.length - 1) && controller.isPlaying.value)}');
    //   log('cek logika value 2 : ${(newValue == controller.max.value && (controller.playIndex.value + 1) > (data.length - 1))}');
    //   if (newValue >= controller.max.value && (controller.playIndex.value) < (data.length - 1) && controller.isPlaying.value) {
    //     // Panggil metode atau fungsi yang ingin dijalankan
    //     controller.playSong(data[controller.playIndex.value + 1].uri, controller.playIndex.value + 1);
    //     controller.showLyric(data[controller.playIndex.value].data);
    //   } else if (newValue == controller.max.value && (controller.playIndex.value + 1) > (data.length - 1)) {
    //     controller.stopSongPlayer();
    //   }
    // });
    // Stream<String> stream = controller.controllerStream.stream;
    double size = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        if (subscription != null) {
          subscription!.cancel();
        }
        if (controller.isPlaying.value) {
          controller.stopSongPlayer();
          return true;
        } else {
          controller.stopSongPlayer();
          return true;
        }
      },
      child: Scaffold(
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
                    id: data[controller.playIndex.value].id!,
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
                    () => Stack(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.question_mark,
                            color: bgDarkColor,
                            size: 32,
                          ),
                          tooltip: 'How to show the lyric',
                        ),
                        Column(
                          children: [
                            Text(
                              data[controller.playIndex.value].title!,
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
                                      max: controller.value.value > controller.max.value ? controller.value.value : controller.max.value,
                                      value: controller.value.value,
                                      onChanged: (newValue) {
                                        if (newValue >= controller.max.value && ((controller.playIndex.value) < (data.length - 1))) {
                                          controller.playSong(data[controller.playIndex.value + 1].uri, controller.playIndex.value + 1);
                                          controller.showLyric(data[controller.playIndex.value].audioPath);
                                        } else if (newValue <= controller.max.value) {
                                          controller.changeDurationToMilliseconds(newValue.toInt());
                                          newValue = newValue;
                                        } else {
                                          controller.stopSongPlayer();
                                        }
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
                                    controller.showLyric(data[controller.playIndex.value].audioPath);
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
                                    if (subscription != null) {
                                      subscription!.cancel();
                                    }
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
                                            subscription = controller.autoNextPlay(controller, controller.foundMusic);
                                            // controller.isPause(false);
                                          } else {
                                            controller.startSong();
                                            subscription = controller.autoNextPlay(controller, controller.foundMusic);
                                            // controller.testLrc(controller.songLyric.value);
                                            controller.showLyric(data[controller.playIndex.value].audioPath);
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
                                    controller.showLyric(data[controller.playIndex.value].audioPath);
                                    // log('cek next : ${data[(controller.playIndex.value)].data}');
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.question_mark)),
        // floatingActionButtonLocation: ,
      ),
    );
  }
}
