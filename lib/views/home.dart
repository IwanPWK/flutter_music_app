import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_music_app/views/list.dart';
import 'package:get/get.dart';
import '../consts/colors.dart';
import '../consts/text_style.dart';
import '../controllers/player_controller.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  getValue() async {}

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());
    // controller.readFromFile('storage/emulated/0/download/jason\'s lyric.lrc');
    log('isi song lirik${controller.songLyric.value}');

    return Scaffold(
        backgroundColor: bgDarkColor,
        appBar: AppBar(
          backgroundColor: bgDarkColor,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: whiteColor)),
          ],
          leading: GestureDetector(
            onTap: () {
              // log('sedang di test di tap gesture');
              // controller.isTitleSortAscending();
              // controller.sortTitleList(controller.isAscending.value);
              // controller.stopSongPlayer();
            },
            child: const Icon(
              Icons.sort_rounded,
              color: whiteColor,
            ),
          ),
          title: Text(
            'I\'Wan Music',
            style: ourStyle(
              family: bold,
              size: 18,
            ),
          ),
        ),
        body: FutureBuilder(
            future: controller.queryAndSaveSongs(),
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
                log("cek snapshot : ${snapshot.data}");
                return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.keys.length,
                    itemBuilder: (BuildContext context, int index) {
                      String folder = snapshot.data!.keys.elementAt(index);
                      String directory = controller.directories[index];
                      controller.addListFolderModel(folder, directory);
                      // List<SongModel> files = controller.groupedFiles[folderName]!;

                      String folderName = controller.foundFolder[index].folderName;
                      String directoryName = controller.foundFolder[index].directoryName;
                      log('cek snapshot datasss : ${snapshot.data![folderName]!}');

                      return Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.only(bottom: 2),
                          child: Column(
                            children: [
                              ListTile(
                                tileColor: bgColor,
                                title: Text(
                                  folderName,
                                  style: ourStyle(family: bold, size: 14),
                                ),
                                subtitle: Text(
                                  directoryName,
                                  style: ourStyle(family: regular, size: 10),
                                ),
                                leading: const Icon(
                                  Icons.folder,
                                  size: 60,
                                ),
                                onTap: () {
                                  controller.listMusics.value = snapshot.data![folderName]!;
                                  controller.foundMusic.value = snapshot.data![folderName]!;
                                  Get.to(
                                    () => ListMusic(
                                      data: snapshot.data![folderName]!,
                                    ),
                                    transition: Transition.downToUp,
                                  );
                                  log('cek snapshot data : ${snapshot.data![folderName]!}');
                                },
                              ),
                            ],
                          ));
                    });
              }
            }));

    // ListView.builder(
    //     itemCount: controller.groupedFiles.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       log('cek-cek 1');
    //       String folderName = controller.groupedFiles.keys.elementAt(index);
    //       log('cek-cek');
    //       // Check if folderName is not null and exists in the map
    //       if (folderName != null && controller.groupedFiles.containsKey(folderName)) {
    //         log('total : ${controller.groupedFiles.length}');
    //         log('isi folder name: $folderName');
    //       } else {
    //         log('kosong');
    //       }
    //       // log('total : ${controller.groupedFiles.length}');
    //       // log('isi folder name: $folderName');
    //       List<SongModel> files = controller.groupedFiles[folderName]!;

    //       return Container(
    //           decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
    //           margin: const EdgeInsets.only(bottom: 4),
    //           child: Column(
    //             children: [
    //               ListTile(
    //                 tileColor: bgColor,
    //                 title: Text(
    //                   folderName,
    //                   style: ourStyle(family: bold, size: 14),
    //                 ),
    //                 leading: const Icon(
    //                   Icons.folder,
    //                 ),
    //                 onTap: () {
    //                   log('passing: ${controller.groupedFiles}');
    //                 },
    //               ),
    //             ],
    //           ));
    //     })
    // );
  }
}
        //  FutureBuilder<List<SongModel>>(
        //   future: controller.audioQuery.querySongs(
        //     ignoreCase: true,
        //     orderType: OrderType.ASC_OR_SMALLER,
        //     sortType: null,
        //     uriType: UriType.EXTERNAL,
        //   ),
        //   builder: (BuildContext context, snapshot) {
        //     if (snapshot.data == null) {
        //       return const Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     } else if (snapshot.data!.isEmpty) {
        //       return Center(
        //         child: Text(
        //           'No Songs Found',
        //           style: ourStyle(family: bold, size: 14),
        //         ),
        //       );
        //     } else {
        //       debugPrint("${snapshot.data}");
        //       return Padding(
        //         padding: const EdgeInsets.all(8),
        //         child: ListView.builder(
        //           physics: const BouncingScrollPhysics(),
        //           itemCount: snapshot.data?.length,
        //           itemBuilder: (BuildContext context, int index) {
        //             // log('artist : ${snapshot.data![index].data}');
        //             // log('cek length: ${snapshot.data?.length}');
        //             filePaths.add(snapshot.data![index].data.toString());

        //             return Card(
        //               child: Text(snapshot.data![index].data.toString()),
        //             );

        //             // Container(
        //             //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        //             //   margin: const EdgeInsets.only(bottom: 4),
        //             //   child: Obx(
        //             //     () => Column(
        //             //       children: [
        //             //         ListTile(
        //             //             // shape: RoundedRectangleBorder(
        //             //             //   borderRadius: BorderRadius.circular(12),
        //             //             // ),
        //             //             tileColor: bgColor,
        //             //             title: Text(
        //             //               snapshot.data![index].displayNameWOExt,
        //             //               style: ourStyle(family: bold, size: 15),
        //             //             ),
        //             //             subtitle: Text(
        //             //               snapshot.data![index].artist.toString() == '<unknown>' ? 'Unknown Artist' : snapshot.data![index].artist.toString(),
        //             //               style: ourStyle(family: bold, size: 12),
        //             //             ),
        //             //             leading: QueryArtworkWidget(
        //             //               id: snapshot.data![index].id,
        //             //               type: ArtworkType.AUDIO,
        //             //               nullArtworkWidget: const Icon(
        //             //                 Icons.music_note,
        //             //                 color: whiteColor,
        //             //                 size: 32,
        //             //               ),
        //             //             ),
        //             //             trailing: controller.playIndex.value == index && controller.isPlaying.value
        //             //                 ? const Icon(
        //             //                     Icons.stop,
        //             //                     size: 26,
        //             //                     color: whiteColor,
        //             //                   )
        //             //                 : const Icon(
        //             //                     Icons.play_arrow,
        //             //                     size: 26,
        //             //                     color: whiteColor,
        //             //                   ),
        //             //             onTap: () {
        //             //               if (controller.playIndex.value == index && controller.isPlaying.value) {
        //             //                 controller.stopSong();
        //             //               } else {
        //             //                 controller.playSong(
        //             //                   snapshot.data![index].uri,
        //             //                   index,
        //             //                 );
        //             //                 ScaffoldMessenger.of(context)
        //             //                     .showSnackBar(const SnackBar(content: Text('Long press the button to access the music player.')));
        //             //               }
        //             //               log('datanya : ${snapshot.data![index].data}');
        //             //             },
        //             //             onLongPress: () {
        //             //               Get.to(
        //             //                 Player(
        //             //                   data: snapshot.data!,
        //             //                 ),
        //             //                 transition: Transition.downToUp,
        //             //               );
        //             //               if (controller.playIndex.value == index && controller.isPlaying.value) {
        //             //                 controller.stopSong();
        //             //               } else {
        //             //                 controller.playSong(
        //             //                   snapshot.data![index].uri,
        //             //                   index,
        //             //                 );
        //             //               }
        //             //             }),
        //             //       ],
        //             //     ),
        //             //   ),
        //             // );
        //           },
        //         ),
        //       );
        //     }
        //   },
        // ),

