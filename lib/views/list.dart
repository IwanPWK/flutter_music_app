import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../consts/colors.dart';
import '../consts/text_style.dart';
import '../controllers/player_controller.dart';
import 'player.dart';

class ListMusic extends StatelessWidget {
  final List<SongModel> data;
  StreamSubscription? subscription;

  ListMusic({super.key, required this.data});
  List noData = ['No Data Found'];
  // void autoNextPlay(int index, PlayerController controller, List<SongModel> finalData) {
  //   subscription = controller.value.listen((newValue) {
  //     'log(cek max value : ${controller.max.value})';
  //     if (newValue >= controller.max.value && (index) < (finalData.length - 1)) {
  //       log('cek max value : ${controller.max.value}');
  //       // Panggil metode atau fungsi yang ingin dijalankan
  //       controller.playSong(finalData[index + 1].uri, index + 1);
  //       controller.showLyric(finalData[index].data);
  //     } else if (newValue == controller.max.value && (index + 1) > (finalData.length - 1)) {
  //       log('123456789000');
  //       controller.stopSongPlayer();
  //       if (subscription != null) {
  //         subscription!.cancel();
  //       }
  //     }
  //   });
  // }

  // controller.value.listen((newValue) {
  //     if (newValue == controller.max.value && (controller.playIndex.value) < (data.length - 1)) {
  //       // Panggil metode atau fungsi yang ingin dijalankan
  //       controller.playSong(data[controller.playIndex.value + 1].uri, controller.playIndex.value + 1);
  //       controller.showLyric(data[controller.playIndex.value].data);
  //     } else if (newValue == controller.max.value && (controller.playIndex.value + 1) > (data.length - 1)) {
  //       controller.stopSongPlayer();
  //     }
  //   });

  @override
  Widget build(BuildContext context) {
    log('Periksa data length atas : ${data.length}');
    var controller = Get.find<PlayerController>();
    log('sedang di test di tap gesture : ${controller.foundMusic.value}');
    // controller.listMusics.value = data;
    // log('cek listMusics length : ${controller.listMusics.value}');
    // final searchController = TextEditingController();
    // controller.value.listen((newValue) {
    //   if (newValue == controller.max.value && (controller.playIndex.value) < (data.length - 1) && controller.isPlaying.value) {
    //     controller.playSong(data[controller.playIndex.value + 1].uri, controller.playIndex.value + 1);
    //     log('cek max value : ${controller.max.value}');
    //     // Panggil metode atau fungsi yang ingin dijalankan
    //     log('cek playIndex 4 : ${controller.playIndex.value}');

    //     log('cek max value 2: ${controller.max.value}');
    //     log('cek playIndex 3 : ${controller.playIndex.value}');
    //     controller.showLyric(data[controller.playIndex.value].data);
    //   } else if (newValue == controller.max.value && (controller.playIndex.value + 1) > (data.length - 1)) {
    //     controller.stopSongPlayer();
    //   }
    // });

    log('cek playIndex 0 : ${controller.playIndex.value}');

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
                // controller.stopSongPlayer();
              },
              child: const Icon(
                Icons.sort_rounded,
                color: whiteColor,
              ),
            ),
            title: Text(
              'List Musics',
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
                    List<SongModel> finalData = controller.foundMusic.value;

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: finalData.length,
                      itemBuilder: (BuildContext context, int index) {
                        // List<SongModel> finalData = controller.foundMusic.value;
                        controller.searchNewPlayIndex();
                        log('sedang ditest finalData : ${finalData.length}');

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Obx(
                                () => ListTile(
                                    // shape: RoundedRectangleBorder(
                                    //   borderRadius: BorderRadius.circular(12),
                                    // ),
                                    tileColor: bgColor,
                                    title: Text(
                                      finalData[index].displayNameWOExt,
                                      style: ourStyle(family: bold, size: 15),
                                    ),
                                    subtitle: Text(
                                      finalData[index].artist ?? '<unknown>',
                                      style: ourStyle(family: regular, size: 12),
                                    ),
                                    leading: QueryArtworkWidget(
                                      id: finalData[index].id,
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
                                      if (controller.playIndex.value == index &&
                                          controller.isPlaying.value &&
                                          finalData[index].uri == controller.playUri.value) {
                                        controller.stopSongPlayer();
                                        if (subscription != null) {
                                          subscription!.cancel();
                                        }
                                      } else {
                                        log('Uri onTap : ${finalData[index]}');
                                        controller.playSong(
                                          finalData[index].uri,
                                          index,
                                        );
                                        subscription = controller.autoNextPlay(index, controller, finalData);
                                        controller.showLyric(finalData[index].data);
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
                                        controller.showLyric(finalData[index].data);
                                      }
                                    }),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          )),
    );
  }
}
