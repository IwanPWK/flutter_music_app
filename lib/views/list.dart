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
  void autoNextPlay(int index, PlayerController controller) {
    subscription = controller.value.listen((newValue) {
      'log(cek max value : ${controller.max.value})';
      if (newValue == controller.max.value && (index) < (data.length - 1)) {
        log('cek max value : ${controller.max.value}');
        // Panggil metode atau fungsi yang ingin dijalankan
        controller.playSong(data[index + 1].uri, index + 1);
        controller.showLyric(data[index].data);
      } else if (newValue == controller.max.value && (index + 1) > (data.length - 1)) {
        log('123456789000');
        controller.stopSongPlayer();
        if (subscription != null) {
          subscription!.cancel();
        }
      }
    });
  }

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
    controller.listMusics.value = data;
    log('cek listMusics length : ${controller.listMusics.value}');
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

    return Scaffold(
        backgroundColor: bgDarkColor,
        appBar: AppBar(
          backgroundColor: bgDarkColor,
          // actions: [],
          leading: const Icon(
            Icons.sort_rounded,
            color: whiteColor,
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
                onSubmitted: (value) => controller.runFilter(value),
                style: const TextStyle(color: whiteColor),
                // onChanged: (value) => _runFilter(value),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10),
                  labelText: 'Search',
                  suffixIcon: Icon(Icons.search, color: whiteColor),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 4),
                child: Obx(
                  () => ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.foundMusic.value.isNotEmpty ? controller.foundMusic.value.length : data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListTile(
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(12),
                                // ),
                                tileColor: bgColor,
                                title: Text(
                                  controller.foundMusic.value.isNotEmpty
                                      ? controller.foundMusic.value[index].displayNameWOExt
                                      : data[index].displayNameWOExt,
                                  style: ourStyle(family: bold, size: 15),
                                ),
                                subtitle: Text(
                                  (() {
                                    List<SongModel> foundMusic = controller.foundMusic.value;
                                    List<SongModel> allMusic = data;

                                    String artist =
                                        foundMusic.isNotEmpty ? foundMusic[index].artist ?? '<unknown>' : allMusic[index].artist ?? '<unknown>';

                                    return artist == '<unknown>' ? 'Unknown Artist' : artist;
                                  })(),
                                ),
                                leading: QueryArtworkWidget(
                                  id: controller.foundMusic.value.isNotEmpty ? controller.foundMusic.value[index].id : data[index].id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: const Icon(
                                    Icons.music_note,
                                    color: whiteColor,
                                    size: 32,
                                  ),
                                ),
                                trailing:
                                    controller.playIndex.value == index && controller.isPlaying.value && data[index].uri == controller.playUri.value
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
                                      data[index].uri == controller.playUri.value) {
                                    controller.stopSongPlayer();
                                    if (subscription != null) {
                                      subscription!.cancel();
                                    }
                                  } else {
                                    controller.playSong(
                                      data[index].uri,
                                      index,
                                    );
                                    autoNextPlay(index, controller);
                                    controller.showLyric(data[index].data);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(content: Text('Long press the button to access the music player.')));
                                  }
                                  log('datanya : ${data[index].data}');
                                },
                                onLongPress: () {
                                  Get.to(
                                    () => Player(
                                      data: data,
                                    ),
                                    transition: Transition.downToUp,
                                  );
                                  if (controller.playIndex.value == index && controller.isPlaying.value) {
                                    controller.pauseSong();
                                  } else {
                                    controller.playSong(
                                      data[index].uri,
                                      index,
                                    );
                                    log('cek playIndex 1 : $index');
                                    controller.showLyric(data[index].data);
                                  }
                                }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
