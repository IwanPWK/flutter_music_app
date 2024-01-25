import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermission {
  static int count = 0;
  static Future<bool> checkPermission() async {
    // int count = 0;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    PermissionStatus perm;
    PermissionStatus permAudio;
    PermissionStatus permNearWiDev;
    // PermissionStatus permVideos;
    PermissionStatus permImages;
    // PermissionStatus permExtStorage;
    // PermissionStatus permMediaLibrary;
    // PermissionStatus permaccMediaLoc;
    if (deviceInfo.version.sdkInt > 32) {
      permAudio = await Permission.audio.request();
      // permNearWiDev = await Permission.nearbyWifiDevices.request();
      permImages = await Permission.photos.request();
      // permExtStorage = await Permission.manageExternalStorage.request();
      // permMediaLibrary = await Permission.mediaLibrary.request();
      // permaccMediaLoc = await Permission.accessMediaLocation.request();
      log('nilai permAudio: ${permAudio.isGranted}');
      // log('nilai permVideos: ${permVideos.isGranted}');
      log('nilai permImages: ${permImages.isGranted}');
      log('nilai all: ${(!(permAudio.isGranted && permImages.isGranted))}');

      if (!(permAudio.isGranted && permImages.isGranted)) {
        log('Dijalankan if $checkPermission()');

        count = count + 1;
        // log('count : $count');
        if (count <= 10) {
          checkPermission();
        }

        return false;
      } else {
        log('Dijalankan else');
        return true;
      }
    } else {
      perm = await Permission.storage.request();
      // permAudio = await Permission.audio.request();
      // permVideos = await Permission.videos.request();
      // permImages = await Permission.photos.request();
      // permExtStorage = await Permission.manageExternalStorage.request();
      // permMediaLibrary = await Permission.mediaLibrary.request();
      // permaccMediaLoc = await Permission.accessMediaLocation.request();

      log('nilai perm: ${perm.isGranted}');
      // log('nilai permAudio: ${permAudio.isGranted}');
      // log('nilai permVideos: ${permVideos.isGranted}');
      // log('nilai permImages: ${permImages.isGranted}');
      // log('nilai all: ${(!(permAudio.isGranted && permImages.isGranted))}');

      if (!(perm.isGranted)) {
        count++;
        if (count <= 10) {
          return false;
        }
        checkPermission();
        return false;
      } else {
        return true;
      }
    }
  }
}
