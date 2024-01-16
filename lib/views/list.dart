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
  const ListMusic({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    log('Periksa data length atas : ${data.length}');
    var controller = Get.find<PlayerController>();
    // final searchController = TextEditingController();
    log('data data: $data');
    return Scaffold(
        backgroundColor: bgDarkColor,
        appBar: AppBar(
          backgroundColor: bgDarkColor,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: whiteColor,
              ),
            ),
          ],
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
        body: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 4),
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Obx(
                      () => Column(
                        children: [
                          ListTile(
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(12),
                              // ),
                              tileColor: bgColor,
                              title: Text(
                                data[index].displayNameWOExt,
                                style: ourStyle(family: bold, size: 15),
                              ),
                              subtitle: Text(
                                data[index].artist == '<unknown>' ? 'Unknown Artist' : data[index].artist!,
                                style: ourStyle(family: bold, size: 12),
                              ),
                              leading: QueryArtworkWidget(
                                id: data[index].id,
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
                                  controller.stopSong();
                                } else {
                                  controller.playSong(
                                    data[index].uri,
                                    index,
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(content: Text('Long press the button to access the music player.')));
                                }
                                log('datanya : ${data[index].data}');
                              },
                              onLongPress: () {
                                Get.to(
                                  Player(
                                    data: data,
                                  ),
                                  transition: Transition.downToUp,
                                );
                                if (controller.playIndex.value == index && controller.isPlaying.value) {
                                  controller.stopSong();
                                } else {
                                  controller.playSong(
                                    data[index].uri,
                                    index,
                                  );
                                }
                              }),
                        ],
                      ),
                    ),
                  );
                })));
  }
}
