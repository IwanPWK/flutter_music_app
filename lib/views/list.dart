import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../consts/colors.dart';
import '../consts/text_style.dart';
import '../controllers/admob_controller.dart';
import '../controllers/player_controller.dart';
import '../models/audio_model.dart';
import 'player.dart';

// ignore: must_be_immutable
class ListMusic extends StatelessWidget {
  // final List<AudioModel> data;
  final String folderName;
  StreamSubscription<double>? subscription;
  AdMobController adMobController = Get.put(AdMobController(), tag: 'adMob2');
  int currentIndex = 0;
  bool isActive = false;
  bool isResume = false;

  ListMusic({super.key, required this.folderName});
  List noData = ['No Data Found'];

  @override
  Widget build(BuildContext context) {
    // log('Periksa data length atas : ${data.length}');
    var controller = Get.find<PlayerController>();

    log('sedang di test di tap gesture : ${controller.foundMusic.value}');

    log('cek playIndex 0 : ${controller.playIndex.value}');
    controller.fetchFoundMusic();

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
        backgroundColor: bgDarkColor,
        appBar: AppBar(
          backgroundColor: bgDarkColor,
          // actions: [],
          leading: GestureDetector(
            onTap: () {
              log('sedang di test di tap gesture');
              controller.isTitleSortAscending();
              controller.sortTitleList(controller.isTitleAscending.value);
              controller.stopSongPlayer();
            },
            child: const Icon(
              Icons.sort_rounded,
              color: whiteColor,
            ),
          ),
          title: Text(
            '$folderName folder',
            style: ourStyle(
              size: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: bgColor),
              child: TextField(
                onSubmitted: (value) => controller.runFilterTitle(value),
                style: const TextStyle(color: whiteColor),
                // onChanged: (value) => _runFilter(value),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10),
                  labelText: 'Search',
                  suffixIcon: Icon(Icons.search, color: whiteColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 4),
                child: Obx(() {
                  // List finalData = controller.foundMusic.value.isNotEmpty ? controller.foundMusic.value : noData;
                  List<dynamic> finalData = controller.foundMusic.value;
                  // for (String element in controller.foundGroupedFiles.keys) {
                  //   // controller.listFolderNames.add(element);
                  //   if (currentIndex % 3 == 0 && currentIndex != 0) {
                  //     controller.listFolderNames.add(Get.put(AdMobController(), tag: '$currentIndex').bannerAd.value);
                  //     controller.listFolderNames.add(element);
                  //   } else {
                  //     controller.listFolderNames.add(element);
                  //     log('listFolderNames else dijalankan');
                  //   }
                  //   // log('cek nilai listFolderNames: $listFolderNames');
                  //   currentIndex++;
                  // }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: finalData.length,
                    itemBuilder: (BuildContext context, int index) {
                      List<dynamic> finalData = controller.foundMusic.value;
                      controller.searchNewPlayIndex();
                      log('sedang ditest finalData : ${finalData[index] is AudioModel}');

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Obx(
                          () => (controller.foundMusic[index] is AudioModel)
                              ? Container(
                                  color: bgColor,
                                  child: Column(
                                    children: [
                                      ListTile(
                                          // tileColor: bgColor,
                                          title: Text(
                                            finalData[index].title,
                                            style: ourStyle(family: bold, size: 15),
                                          ),
                                          subtitle: Text(
                                            finalData[index].artist == '<unknown>' ? 'No Data' : finalData[index].artist!,
                                            style: ourStyle(family: regular, size: 12),
                                          ),
                                          leading: QueryArtworkWidget(
                                            id: finalData[index].id!,
                                            type: ArtworkType.AUDIO,
                                            nullArtworkWidget: const Icon(
                                              Icons.music_note,
                                              color: whiteColor,
                                              size: 32,
                                            ),
                                          ),
                                          trailing: controller.playIndex.value == index &&
                                                  controller.isPlaying.value &&
                                                  finalData[index].uri == controller.playUri.value
                                              ? const Icon(
                                                  Icons.stop,
                                                  size: 26,
                                                  color: whiteColor,
                                                )
                                              : const Icon(
                                                  Icons.play_arrow,
                                                  size: 26,
                                                  color: whiteColor,
                                                ),
                                          onTap: () {
                                            log('cek nilai uri ${finalData[index].uri == controller.playUri.value}');
                                            if (controller.playIndex.value == index &&
                                                controller.isPlaying.value &&
                                                finalData[index].uri == controller.playUri.value) {
                                              controller.stopSongPlayer();
                                              if (subscription != null) {
                                                subscription!.cancel();
                                              }
                                            } else if (controller.sliderValue > 0 &&
                                                controller.playIndex.value == index &&
                                                finalData[index].uri == controller.playUri.value) {
                                              controller.startSong();
                                              // subscription = controller.autoNextPlay(controller, controller.foundMusic);
                                              // controller.testLrc(controller.songLyric.value);
                                              controller.showLyric(finalData[controller.playIndex.value].audioPath);
                                              // List<AudioModel> finalData = controller.songList.value;
                                              // finalData.
                                              // log('cek finalData : ${(finalData.contains(element)}');
                                              log('cek index : ${controller.foundMusic[index].runtimeType}');
                                            } else {
                                              controller.playSong(
                                                finalData[index].uri,
                                                index,
                                              );
                                              isActive = true;
                                              // subscription = controller.autoNextPlay(controller, controller.foundMusic.value);
                                              controller.showLyric(finalData[index].audioPath);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(content: Text('Long press the button to access the music player.')));
                                            }

                                            log('datanya : ${finalData[index].uri}');
                                          },
                                          onLongPress: () {
                                            if (subscription != null) {
                                              subscription!.cancel();
                                            }

                                            Get.to(
                                              () => Player(
                                                data: finalData,
                                              ),
                                              transition: Transition.downToUp,
                                            );
                                            if (controller.playIndex.value == index &&
                                                controller.isPlaying.value &&
                                                finalData[index].uri == controller.playUri.value) {
                                              controller.pauseSong();
                                            } else {
                                              log('Uri onLongPress : ${finalData[index].uri}');
                                              controller.playSong(
                                                finalData[index].uri,
                                                index,
                                              );
                                              log('cek playIndex 1 : $index');
                                              controller.isListToPlayer(true);
                                              controller.showLyric(finalData[controller.playIndex.value].audioPath);
                                            }
                                          }),
                                      GetBuilder<PlayerController>(
                                        builder: (_) => Row(
                                          children: [
                                            Text(
                                              controller.foundMusic[index].position,
                                              style: const TextStyle(
                                                color: whiteColor,
                                              ),
                                            ),
                                            Expanded(
                                              // child:
                                              // GestureDetector(
                                              //   onDoubleTap: () {
                                              // controller.playSong(
                                              //   finalData[index].uri,
                                              //   index,
                                              // );
                                              // },
                                              child: Slider(
                                                thumbColor: slideColor,
                                                inactiveColor: whiteColor,
                                                activeColor: slideColor,
                                                min: const Duration(milliseconds: 0).inMilliseconds.toDouble(),
                                                max: controller.foundMusic[index].val >= controller.foundMusic[index].max
                                                    ? controller.foundMusic[index].val
                                                    : controller.foundMusic[index].max,
                                                value: controller.foundMusic[index].val,
                                                onChanged: (newValue) {
                                                  if (isActive && controller.playIndex.value == index) {
                                                    if (newValue >= (controller.foundMusic[index].max as double) &&
                                                        (index < (finalData.length - 1))) {
                                                      controller.playSong(finalData[index + 1].uri, index + 1);
                                                      controller.showLyric(finalData[index].audioPath);
                                                    } else if (newValue <= (controller.foundMusic[index].max as double)) {
                                                      controller.foundMusic[index].val = controller.updateSliderValue(newValue);
                                                      controller.changeDurationToMilliseconds(newValue.toInt());
                                                      isResume = true;
                                                    } else {
                                                      controller.stopSongPlayer();
                                                    }
                                                  }

                                                  //  controller.pauseSong();
                                                  // newValue = controller.updateSliderValue(newValue);
                                                  log('cek nilai newValue : $newValue');
                                                },
                                              ),
                                              // ),
                                            ),
                                            Text(
                                              controller.foundMusic[index].duration,
                                              style: const TextStyle(
                                                color: whiteColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height: 60,
                                  child: Obx(
                                    () => AdWidget(ad: controller.foundMusic.value[index]),
                                  ),
                                ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Obx(() {
          return Container(
            alignment: Alignment.center,
            width: adMobController.bannerAd.value.size.width.toDouble(),
            height: adMobController.bannerAd.value.size.height.toDouble(),
            child: adMobController.adLoaded.value ? AdWidget(ad: adMobController.bannerAd.value) : const LinearProgressIndicator(),
          );
        }),
      ),
    );
  }
}
