import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_music_app/views/list.dart';
import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../consts/colors.dart';
import '../consts/text_style.dart';
// import '../controllers/admob_controller.dart';
import '../controllers/player_controller.dart';
import '../helpers/permission_helper.dart';
import '../models/audio_model.dart';
// import '../services/ad_mob_services.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isPermission = false;
  bool? isApprove;
  // Key? futureBuilderKey;
  // Key futureBuilderKey = ValueKey<bool>(isPermission);
  // PlayerController controller;
  // List<dynamic> listFolderNames = [];

  permissionHandler() async {
    isApprove = await CheckPermission.checkPermission();
    setState(() {
      isApprove = isApprove;
    });
    // if (isApprove == null) {
    //   isApprove = false;
    // }

    // isApprove ??= false;
    if (isApprove!) {
      setState(() {
        isPermission = true;
      });
    }
  }

  // isApproval() {
  //   if (isApprove == null) {
  //     Future.delayed(Duration(seconds: 30), () {
  //       if (isApprove == null) {
  //         isApproval();
  //       }
  //       if (isApprove != false) {
  //         setState(() {
  //           isApprove = false;
  //         });
  //       }
  //       log('direbuild');
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    //   if (isApprove == null) {}
  }

  @override
  Widget build(BuildContext context) {
    if (isPermission == false && isApprove == null) {
      permissionHandler();

      log('ini dicetak di console');
    }
    var controller = Get.put(PlayerController());
    log('nilai isPermission: $isPermission');
    log('nilai approve: $isApprove');
    // futureBuilderKey = ValueKey<bool>(isPermission);
    // var controllerAdMobBottom = Get.put(AdMobController(), tag: "100");

    // BannerAd? bannerBottom = controllerAdMobBottom.banner;

    // Map<String, List<AudioModel>> finalFolderData = controller.foundGroupedFiles;
    // log('cek finalFolderData : ${finalFolderData.keys}');

    // for (String element in finalFolderData.keys) {
    //   log('listFolderNames dijalankan');
    //   if (currentIndex % 1 == 0 && currentIndex != 0) {
    //     controller.listFolderNames.add(Get.put(AdMobController(), tag: '$currentIndex').banner);
    //     controller.listFolderNames.add(element);
    //   } else {
    //     controller.listFolderNames.add(element);
    //     log('listFolderNames else dijalankan');
    //   }
    //   // log('cek nilai listFolderNames: $listFolderNames');
    //   currentIndex++;
    // }
    // controller.readFromFile('storage/emulated/0/download/jason\'s lyric.lrc');
    log('isi song lirik${controller.songLyric.value}');

    return Scaffold(
      backgroundColor: bgDarkColor,
      appBar: AppBar(
        backgroundColor: bgDarkColor,
        leading: GestureDetector(
          onTap: () {
            log('sedang di test di tap gesture');
            controller.isFolderSortAscending();
            controller.sortFolderList(controller.isFolderAscending.value);
            // controller.stopSongPlayer();
          },
          child: const Icon(
            Icons.sort_rounded,
            color: whiteColor,
          ),
        ),
        title: Text(
          'I\'Wan Audio Player',
          style: ourStyle(
            family: bold,
            size: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: bgColor),
            child: TextField(
              onSubmitted: (value) => controller.runFilterGroupedFiles(value),
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
            child: FutureBuilder(
                // key: futureBuilderKey,
                future: isPermission ? controller.queryAndSaveSongs() : null,
                builder: (BuildContext context, snapshot) {
                  // log('cek length controller listFolderNames : ${controller.listFolderNames.length}');
                  Map<String, List<AudioModel>> finalFolderData = controller.foundGroupedFiles;
                  // log('cek finalFolderData : ${finalFolderData.keys}');

                  // for (String element in finalFolderData.keys) {
                  //   controller.listFolderNames.add(element);
                  //   //   log('listFolderNames dijalankan');
                  //   //   if (currentIndex % 1 == 0 && currentIndex != 0) {
                  //   //     // controller.listFolderNames.add(Get.put(AdMobController(), tag: '$currentIndex').banner);
                  //   //     controller.listFolderNames.add(element);
                  //   //   } else {
                  //   //     controller.listFolderNames.add(element);
                  //   //     log('listFolderNames else dijalankan');
                  //   //   }
                  //   //   // log('cek nilai listFolderNames: $listFolderNames');
                  //   //   currentIndex++;
                  // }
                  if (snapshot.data == null) {
                    (isPermission == false && isApprove == null) ? permissionHandler() : null;
                    log('nilai isPermissionssssssssss: $isPermission');
                    // futureBuilderKey = ValueKey<bool>(isPermission);
                    return Center(
                      child: (isApprove == null)
                          ? Column(
                              children: [
                                Text(
                                  'Please provide approval as soon as possible',
                                  style: ourStyle(family: bold, size: 20),
                                ),
                                const SizedBox(height: 20),
                                const SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: CircularProgressIndicator(),
                                ),
                              ],
                            )
                          : (isApprove == false)
                              ? Text(
                                  'Please reinstall this app, the app need your approval.',
                                  textAlign: TextAlign.center,
                                  style: ourStyle(family: bold, size: 20),
                                )
                              : null,
                    );
                  } else if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No Songs Found',
                        style: ourStyle(family: bold, size: 14),
                      ),
                    );
                  } else {
                    // log("cek snapshot : ${snapshot.data}");

                    // finalFolderData.keys.length
                    // finalFolderData.keys.elementAt(index)
                    // snapshot.data!.keys.length,
                    // var controllerAdMob = Get.put(AdMobController(), tag: "1");
                    // BannerAd? banner = controllerAdMob.banner;

                    // List<dynamic> listFolderNames = [];
                    // int currentIndex = 0;
                    // for (String element in finalFolderData.keys) {
                    //   // log('isi currentIndex : $banner');
                    //   if (currentIndex % 1 == 0 && currentIndex != 0) {
                    //     listFolderNames.add(Get.put(AdMobController(), tag: "$currentIndex").banner);
                    //   } else {
                    //     listFolderNames.add(element);
                    //     log('listFolderNames else dijalankan');
                    //   }
                    //   currentIndex++;
                    //   log('isi list folder Name: $listFolderNames');
                    // }

                    return Obx(() {
                      return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: finalFolderData.keys.length,
                          itemBuilder: (BuildContext context, int index) {
                            String folderName = finalFolderData.keys.elementAt(index);
                            String pathDirectoryName = finalFolderData[folderName]![0].directoryPath!;

                            // log('isi  folder Name: $folderName');
                            // log('cek snapshot datasss : ${snapshot.data![folderName]!}');
                            // if (listFolderNames[index] == banner) {}
                            return Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.only(bottom: 2),
                              child: Column(
                                children: [
                                  Obx(() => ListTile(
                                        tileColor: bgColor,
                                        title: Text(
                                          folderName,
                                          style: ourStyle(family: bold, size: 14),
                                        ),
                                        subtitle: Text(
                                          pathDirectoryName,
                                          style: ourStyle(family: regular, size: 10),
                                        ),
                                        leading: Icon(
                                          controller.isFolderAscending.value ? Icons.folder : Icons.folder,
                                          size: 60,
                                        ),
                                        onTap: () {
                                          controller.listMusics.value = finalFolderData[folderName]!;
                                          controller.foundMusic.value = finalFolderData[folderName]!;
                                          Get.to(
                                            () => ListMusic(
                                              data: finalFolderData[folderName]!,
                                              folderName: folderName,
                                            ),
                                            transition: Transition.downToUp,
                                          );
                                          // log('cek snapshot data : ${snapshot.data![folderName]!}');
                                        },
                                      ))
                                  // :
                                  // ? SizedBox(
                                  //     height: 60,
                                  //     child: SizedBox(height: 60, child: Obx(() => AdWidget(ad: folderName))),
                                  //   )
                                  // const SizedBox.shrink()
                                ],
                              ),
                            );
                          });
                    });
                  }
                }),
          ),
          // (bannerBottom == null) ? const SizedBox.shrink() : SizedBox(height: 60, child: Obx(() => AdWidget(ad: controllerAdMobBottom.banner))),
        ],
      ),
      // bottomNavigationBar: Container(
      //   alignment: Alignment.center,
      //   width: _bannerAd.size.width.toDouble(),
      //   height: _bannerAd.size.height.toDouble(),
      //   child: _adLoaded ? AdWidget(ad: _bannerAd) : const LinearProgressIndicator(),
      // ),
    );
  }
}
