import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../consts/colors.dart';
import '../consts/text_style.dart';
import '../controllers/player_controller.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());
    // controller.queryAndSaveSongs();

    return Scaffold(
      backgroundColor: bgDarkColor,
      appBar: AppBar(
        backgroundColor: bgDarkColor,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: whiteColor)),
        ],
        leading: const Icon(Icons.sort_rounded, color: whiteColor),
        title: Text(
          'I\'Wan Music',
          style: ourStyle(
            family: bold,
            size: 18,
          ),
        ),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: controller.audioQuery.querySongs(
          ignoreCase: true,
          orderType: OrderType.ASC_OR_SMALLER,
          sortType: null,
          uriType: UriType.EXTERNAL,
        ),
        builder: (BuildContext context, snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No Songs Found',
                style: ourStyle(family: bold, size: 14),
              ),
            );
          } else {
            debugPrint("${snapshot.data}");
            return Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  log('artist : ${snapshot.data![index].artist}');
                  return Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 4),
                    child: Obx(
                      () => Column(
                        children: [
                          ListTile(
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(12),
                            // ),
                            tileColor: bgColor,
                            title: Text(
                              snapshot.data![index].displayNameWOExt,
                              style: ourStyle(family: bold, size: 15),
                            ),
                            subtitle: Text(
                              snapshot.data![index].artist.toString() == '<unknown>' ? 'Unknown Artist' : snapshot.data![index].artist.toString(),
                              style: ourStyle(family: bold, size: 12),
                            ),
                            leading: QueryArtworkWidget(
                              id: snapshot.data![index].id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: const Icon(
                                Icons.music_note,
                                color: whiteColor,
                                size: 32,
                              ),
                            ),
                            trailing: controller.playIndex.value == index && controller.isPlaying.value
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
                              // Get.to(
                              //   Player(
                              //     data: snapshot.data!,
                              //   ),
                              //   transition: Transition.downToUp,
                              // );
                              controller.playIndex.value == index && controller.isPlaying.value
                                  ? controller.stopSong()
                                  : controller.playSong(
                                      snapshot.data![index].uri,
                                      index,
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
