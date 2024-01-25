import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lrc/lrc.dart';
import 'package:on_audio_query/on_audio_query.dart';
// import 'package:path/path.dart' as path;
// import 'package:flutter/services.dart' show rootBundle;

import '../helpers/path_helper.dart';
import '../models/audio_model.dart';
import '../models/folder_model.dart';
import 'admob_controller.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();

  RxList<AudioModel> songList = <AudioModel>[].obs;
  RxList<String> filePaths = <String>[].obs;
  RxSet<String> folders = <String>{}.obs;
  RxMap<String, List<AudioModel>> groupedFiles = <String, List<AudioModel>>{}.obs;
  RxMap<String, List<AudioModel>> foundGroupedFiles = <String, List<AudioModel>>{}.obs;
  RxList<String> directoryPaths = <String>[].obs;
  RxList<AudioModel> listMusics = <AudioModel>[].obs;
  RxList<dynamic> foundMusic = <dynamic>[].obs;
  // RxList<FolderData> foundFolder = <FolderData>[].obs;
  RxList<FolderData> listFolder = <FolderData>[].obs;
  RxList<String> idIndex = <String>[].obs;
  var lyricModel = LyricsModelBuilder.create().bindLyricToMain('').getModel().obs;
  RxList<dynamic> listFolderNames = [].obs;
  // var audioModels = AudioModel().obs;
  // var folderList = Rxn<List<AudioModel>>();
  // Rx<BannerAd?> testTipe =

  // StreamController<String> controllerStream = StreamController<String>();
  // late StreamSubscription<String> subscription;

  // var showLyric = ''.obs;
  var listLength = 0.obs;
  var playIndex = 0.obs;
  var isPlaying = false.obs;
  var playUri = ''.obs;
  var nextUri = ''.obs;
  var songLyric = """ """.obs;
  var isPause = false.obs;
  var lyricPosition = 0.obs;
  // var lyricDuration = Duration(milliseconds: 0).obs;
  var isStop = false.obs;
  var isLyricStream = true.obs;
  var playProgress = 0.obs;
  var isTitleAscending = true.obs;
  var isFolderAscending = true.obs;
  var isListToPlayer = true.obs;
  var duration = ''.obs;
  var position = '0:00:00'.obs;

  var max = 11.0.obs;
  var value = 0.0.obs;
  var sliderValue = 0.0;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void dispose() {
    // subscription.cancel();
    // controllerStream.close(); // Jangan lupa menutup StreamController
    super.dispose();
  }

  // updtPlayIndex(index) {
  //   playIndex.value = index;
  // }

  playSong(String? uri, index) async {
    playIndex.value = index;
    playUri.value = uri!;
    log('uri: $uri');
    try {
      audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(playUri.value),
        ),
      );
      // foundMusic[index].max = foundMusic[index].duration!.inMilliseconds.toDouble();
      updatePosition();
      isStop(false);
      isPause(false);
      isLyricStream(true);
      isPlaying(true);
      await audioPlayer.play();
    } on Exception catch (e) {
      debugPrint('error playSong: ${e.toString()}');
    }
  }

  void showLyric(String? path) {
    if (path != null && path != '') {
      log('showLyric: $path');
      // var cleanedPath = path.replaceAll("'", "\\'");
      readFromFile(path);
      log('cleanedPath: $path');
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

  startSong() async {
    isStop(false);
    isPause(false);
    isLyricStream(true);
    isPlaying(true);
    // subscription.resume();

    await audioPlayer.play();
  }

  pauseSong() async {
    isStop(false);
    isPause(true);
    // subscription.pause();
    isPlaying(false);
    await audioPlayer.pause();
  }

  stopSongPlayer() async {
    try {
      audioPlayer.dispose;

      isStop(true);
      isPause(false);
      isPlaying(false);
      changeDurationToMilliseconds(0);

      updatePosition();
      await audioPlayer.stop();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  againSong() async {
    await audioPlayer.stop();

    audioPlayer.dispose;
    isStop(true);
    isPause(false);
    isPlaying(false);
    changeDurationToMilliseconds(0);

    updatePosition();
    isLyricStream(true);
    isPlaying(true);

    isStop(false);
    isPause(false);
    await audioPlayer.play();
  }

  updatePosition() {
    audioPlayer.durationStream.listen(
      (d) {
        foundMusic[playIndex.value].duration = (d.toString().split(".")[0]);
        foundMusic[playIndex.value].max = (d!.inMilliseconds.toDouble());
        update();
        {}
      },
    );
    audioPlayer.positionStream.listen(
      (p) {
        foundMusic[playIndex.value].position = (p.toString().split(".")[0]);
        foundMusic[playIndex.value].val = (p.inMilliseconds.toDouble());
        // playProgress.value = p.inMilliseconds;
        update();
        {
          value.value = p.inMilliseconds.toDouble();
        }
      },
    );
  }

  changeDurationToMilliseconds(milliseconds) {
    var duration = Duration(milliseconds: milliseconds);
    playProgress.value = milliseconds;
    audioPlayer.seek(duration);
  }

  Future<Map<String, List<AudioModel>>> queryAndSaveSongs() async {
    // List<AudioModel> audioList = [];
    // Lakukan querySongs

    List<SongModel> queriedSongs = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );

    // num++;
    // Simpan hasil query ke dalam List songs
    // songs.value = queriedSongs;
    // log('cek songsssssssssss: ${queriedSongs}');
    // log('Jumlah $num');
    log("Cek queriedSongsss: ${queriedSongs[6]}");
    songList.value = List.from(queriedSongs.map((data) => AudioModel.fromAudioQuery(data)));
    // await Future.delayed(Duration.zero);
    // log('Cek songList: $audioList');
    groupedFiles.clear();
    for (AudioModel audioModel in songList.value) {
      int currentIndex = 0;
      String folderName = getFolderName(audioModel.directoryPath!);
      log('Cek folderName: $folderName');

      if (!groupedFiles.containsKey(folderName)) {
        groupedFiles[folderName] = [];
      }
      if (!foundGroupedFiles.containsKey(folderName)) {
        foundGroupedFiles[folderName] = [];
      }
      groupedFiles[folderName]!.add(audioModel);
      foundGroupedFiles[folderName]!.add(audioModel);
      listFolderNames.clear();
      for (String element in foundGroupedFiles.keys) {
        // controller.listFolderNames.add(element);

        if (currentIndex % 1 == 0 && currentIndex != 0) {
          listFolderNames.add(Get.put(AdMobController(), tag: '$currentIndex').bannerAd.value);
          listFolderNames.add(element);
        } else {
          listFolderNames.add(element);
          // log('listFolderNames else dijalankan');
        }
        // log('cek nilai listFolderNames: $listFolderNames');
        currentIndex++;
      }
    }
    log('Cek groupedFiles: $groupedFiles');
    // for (int index = 0; index < queriedSongs.length; index++) {
    //   var pathSong = queriedSongs[index].data;
    //   var queriedSong = queriedSongs[index];
    //   var directoryPath = getDirectory(pathSong);
    //   String folderName = getFolderName(pathSong);
    //   if (!groupedFiles.containsKey(folderName)) {
    //     groupedFiles[folderName] = [];
    //   }
    //   if (!foundGroupedFiles.containsKey(folderName)) {
    //     foundGroupedFiles[folderName] = [];
    //   }
    //   if (!directories.contains(directoryPath)) {
    //     directories.add(directoryPath);
    //   }
    //   groupedFiles[folderName]!.add(queriedSong);
    //   foundGroupedFiles[folderName]!.add(queriedSong);
    // }

    // log('periksa directories: ${directories.value}');
    // log('Folders Name: ${groupedFiles['listen']}');
    return groupedFiles;
  }

  // String getFolderName(String filePath) {
  //   String directory = getDirectory(filePath);
  //   String folderName = path.basename(directory);
  //   return folderName;
  // }

  // String getDirectory(String filePath) {
  //   String directory = path.dirname(filePath);
  //   return directory;
  // }

  // getData() async {
  //   String response = await rootBundle.loadString('music_lyrics/lirik_musik.txt');
  //   songLyric.value = response;
  // }

  void readFromFile(String filePath) {
    try {
      String newPath = removeFileExtension(filePath);
      log('newPath: $newPath');
      File file = File(newPath);

      if (file.existsSync()) {
        // Baca isi file
        // log('123456789');
        var song = file.readAsStringSync();
        setLrc(song);
        // log('1234567');
        // log('Isi file: $contents');
      } else {
        log('File tidak ditemukan.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  setLrc(String lyric) {
    songLyric.value = """
$lyric
""";

    lyricModel.value = LyricsModelBuilder.create().bindLyricToMain(songLyric.value).getModel();
  }

  String removeFileExtension(String filePath) {
    String newModifiedPath = '';

    // Mencari posisi titik (.) terakhir dalam path
    int lastDotIndex = filePath.lastIndexOf('.');

    // Jika titik ditemukan dan bukan merupakan bagian dari direktori (contoh: /path/to/file.xyz/)
    if (lastDotIndex != -1 && !filePath.substring(lastDotIndex).contains('/')) {
      // Mengambil substring hingga sebelum titik terakhir
      String modifiedPath = filePath.substring(0, lastDotIndex);
      newModifiedPath = '$modifiedPath.lrc';
    } else {
      // Jika tidak ada ekstensi, gunakan path asli
      newModifiedPath = '$filePath.lrc';
    }

    return newModifiedPath;
  }

  testLrc(String songLyric) {
    log('sebelum song Armada');
    var song = """
$songLyric
""";
    log('isi file song : $song');
    var lrc = Lrc.parse(song);
    log('sesudah song Armada');
    //Prints the formatted string. The output is mostly the same as the string to be parsed.
    print(lrc.format() + '\n');
    var abc = printLyrics(lrc);
    return abc;
  }

  printLyrics(Lrc lrc) async* {
    String lrcData;

    await for (LrcStream i in lrc.stream) {
      lrcData = i.current.lyrics;
      yield lrcData;
      // i.position = 10;
      // if (isLyricStream.value) {
      //   if (isPause.value) {
      //     lyricPosition.value = i.position;
      //     isLyricStream(false);
      //     log('Pause positionLRC : ${lyricPosition.value}');
      //   }
      //   if (isStop.value) {
      //     lyricPosition.value = 0;
      //     isLyricStream(false);
      //   }
      //   if (isPlaying.value) {
      //     i.position = i.position;
      //     lrcData = i.current.lyrics;
      //     log('Start 1 positionLRC : $lrcData');
      //     yield i.position.toString();
      //   }
      // }
      // else {
      //   if (isStop.value) {
      //     lyricPosition.value = 0;
      //     isLyricStream(false);
      //   }
      //   if (isPlaying.value) {
      //     i.position = lyricPosition.value;
      //     lrcData = i.current.lyrics;
      //     isLyricStream(true);
      //     log('Start positionLRC : ${i.current.lyrics}');
      //     yield i.position.toString();
      //   }
      // }

      // i.position = lyricPosition.value;

      // print('ABC ${i.current.lyrics}');
      // showLyric(i.current.lyrics);
      // lrcData = isPause.value ? 'PAUSE' : i.position = 4;
    }
  }

  void runFilterTitle(String enteredKeyword) {
    int currentIndex = 0;
    List<dynamic> results = [];
    log('cek listMusicssss : ${listMusics.value}');
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = List.from(listMusics.value);
    } else {
      results = listMusics.where((listMusic) => listMusic.title!.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
      log('cek listMusicssss 12345 : ${listMusics.value}');
      // we use the toLowerCase() method to make it case-insensitive
    }
    foundMusic.clear();
    for (var element in results) {
      // controller.listFolderNames.add(element);
      if (currentIndex % 1 == 0 && currentIndex != 0) {
        foundMusic.add(Get.put(AdMobController(), tag: 'rFT$currentIndex').bannerAd.value);
        foundMusic.add(element);
      } else {
        foundMusic.add(element);
        // log('listFolderNames else dijalankan');
      }
      // log('cek nilai listFolderNames: $listFolderNames');
      currentIndex++;
    }

    // Refresh the UI

    // foundMusic.value = results;
    log('cek results : $results');
    log('cek entered keyword : $enteredKeyword');
    log('cek foundMusic : ${foundMusic.value}');
  }

  void runFilterGroupedFiles(String enteredKeyword) {
    int currentIndex = 0;
    Map<String, List<AudioModel>> results = {};
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = Map.from(groupedFiles);
    } else {
      results = Map.fromEntries(groupedFiles.entries.where((entry) => entry.key.toLowerCase().contains(enteredKeyword.toLowerCase())));
      // we use the toLowerCase() method to make it case-insensitive
    }
    listFolderNames.clear();
    for (String element in results.keys) {
      // controller.listFolderNames.add(element);
      if (currentIndex % 1 == 0 && currentIndex != 0) {
        listFolderNames.add(Get.put(AdMobController(), tag: 'rFGF$currentIndex').bannerAd.value);
        listFolderNames.add(element);
      } else {
        listFolderNames.add(element);
        // log('listFolderNames else dijalankan');
      }
      // log('cek nilai listFolderNames: $listFolderNames');
      currentIndex++;
    }
    foundGroupedFiles.value = results;
  }

  sortTitleList(bool isAscending) {
    int currentIndex = 0;
    log('cek foundMusic : ${foundMusic.value}');
    List<dynamic> filteredMusic = foundMusic.where((audio) {
      if (audio is AudioModel) {
        String cleanedTitle = audio.title?.replaceAll("'", "\\'") ?? '';
        log('cek title: $cleanedTitle');
        return cleanedTitle.isNotEmpty;
      }
      return false;
    }).toList();
    filteredMusic.sort((a, b) {
      if (isAscending) {
        // foundMusic.value = foundMusic.toList();
        log('sedang ditest isAscending ${foundMusic.value}');

        return a.title!.compareTo(b.title!);
      } else {
        // foundMusic.value = foundMusic.toList();
        log('sedang ditest isDescending ${foundMusic.value}');
        return b.title!.compareTo(a.title!);
      }
    });
    // foundMusic.value = foundMusic.toList();
    foundMusic.clear();
    for (var element in filteredMusic) {
      // controller.listFolderNames.add(element);

      if (currentIndex % 1 == 0 && currentIndex != 0) {
        foundMusic.add(Get.put(AdMobController(), tag: 'sTL$currentIndex').bannerAd.value);
        foundMusic.add(element);
      } else {
        foundMusic.add(element);
        // log('listFolderNames else dijalankan');
      }
      // log('cek nilai listFolderNames: $listFolderNames');
      currentIndex++;
    }

    log('sedang ditest isFinal ${foundMusic.value}');
  }

  sortFolderList(bool isAscending) {
    int currentIndex = 0;
    Map<String, List<AudioModel>> results;

    results = SplayTreeMap<String, List<AudioModel>>.from(foundGroupedFiles, (a, b) {
      final aLower = a.toLowerCase();
      final bLower = b.toLowerCase();
      return isAscending ? aLower.compareTo(bLower) : bLower.compareTo(aLower);
    });

    log('cek results sort folder : ${results.keys.elementAt(0)}, ${results.keys.elementAt(1)}, ${results.keys.elementAt(2)}, ${results.keys.elementAt(3)}');
    log('cek nilai results : $results');
    foundGroupedFiles.clear();
    listFolderNames.clear();
    for (var element in results.keys) {
      // controller.listFolderNames.add(element);
      if (currentIndex % 1 == 0 && currentIndex != 0) {
        listFolderNames.add(Get.put(AdMobController(), tag: 'sFL$currentIndex').bannerAd.value);
        listFolderNames.add(element);
      } else {
        listFolderNames.add(element);
        // log('listFolderNames else dijalankan');
      }
      // log('cek nilai listFolderNames: $listFolderNames');
      currentIndex++;
    }
    foundGroupedFiles.addAll(RxMap<String, List<AudioModel>>.from(results));
  }

  isTitleSortAscending() {
    isTitleAscending.value = !isTitleAscending.value;
  }

  isFolderSortAscending() {
    isFolderAscending.value = !isFolderAscending.value;
  }

//   addListFoundFolder(Map<String, String> data) {
//   var folderData = FolderData(
//     folderName: data['folderName'] ?? '',
//     directoryName: data['directoryName'] ?? '',
//   );
//   listFolder.add(folderData);
//   foundFolder.add(folderData);
// }

  // addListFolderModel(String folderName, String directoryName) {
  //   var folderData = FolderData(
  //     folderName: folderName,
  //     directoryName: directoryName,
  //   );
  //   listFolder.add(folderData);
  //   foundFolder.add(folderData);
  // }

  searchNewPlayIndex() {
    int newPlayIndex;
    String searchedIndex = playUri.value;
    newPlayIndex = foundMusic.indexWhere((data) => ((data is AudioModel) ? data.uri : null) == searchedIndex);
    playIndex.value = newPlayIndex == -1 ? playIndex.value : newPlayIndex;
    log('cek new play index : ${playIndex.value}');
  }

  StreamSubscription<double>? autoNextPlay(PlayerController controller, List<dynamic> finalData) {
    // StreamSubscription<double>? subscription;
    // log('cek finalData value : ${controller.value is Stream} ');
    // subscription = /*(controller.foundMusic[playIndex.value].val as RxDouble)*/ controller.value.listen((newValue) {
    //   log('cek finalData value : ${controller.value is Stream} ');
    //   if ((finalData[playIndex.value] is AudioModel) && newValue >= finalData[playIndex.value].max && (playIndex.value) < (finalData.length - 1)) {
    //     // playIndex.value = index;
    //     // log('cek max value : ${controller.max.value}');
    //     log('pertama dijalankan');
    //     // Panggil metode atau fungsi yang ingin dijalankan
    //     log('cek index di autoNextPlay 0: ${playIndex.value}');
    //     playIndex.value += 1;
    //     playSong(finalData[playIndex.value].uri, playIndex.value);
    //     log('cek index di autoNextPlay 1: ${playIndex.value}');
    //     log('cek finalData.length di autoNextPlay : ${finalData.length}');
    //     showLyric(finalData[playIndex.value].audioPath);
    //   } else if (newValue >= finalData[playIndex.value].max && (playIndex.value + 1) > (finalData.length - 1)) {
    //     log('cek index di kedua autoNextPlay 0: ${playIndex.value}');
    //     // playIndex.value += 1;
    //     stopSongPlayer();
    //     log('kedua dijalankan');
    //     log('cek index di kedua autoNextPlay 1: ${playIndex.value}');
    //     if (subscription != null) {
    //       subscription.cancel();
    //     }
    //   } else if (newValue >= finalData[playIndex.value].max) {
    //     stopSongPlayer();
    //     log('ketiga dijalankan');
    //     if (subscription != null) {
    //       subscription.cancel();
    //     }
    //   }
    // });
    // return subscription;
  }

  fetchFoundMusic() {
    int currentIndex = 0;
    List<dynamic> current = [];
    for (AudioModel element in foundMusic.value) {
      // controller.listFolderNames.add(element);

      if (currentIndex % 2 == 0 && currentIndex != 0) {
        current.add(Get.put(AdMobController(), tag: 'fFM$currentIndex').bannerAd.value);
        current.add(element);
      } else {
        current.add(element);
        // log('listFolderNames else dijalankan');
      }
      // log('cek nilai listFolderNames: $listFolderNames');
      currentIndex++;
    }
    foundMusic.value = current.toList();
  }

  updateSliderValue(value) {
    sliderValue = value;
    update();
    return sliderValue;
  }
}
