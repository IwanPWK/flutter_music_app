import 'dart:developer';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../global.dart';

class AdMobController extends GetxController {
  RxBool adLoaded = RxBool(false);
  late Rx<BannerAd> bannerAd;

  @override
  void onInit() {
    super.onInit();
    loadAd();
  }

  @override
  void onClose() {
    super.onClose();
    bannerAd().dispose();
  }

  Future<void> loadAd() async {
    bannerAd = BannerAd(
      adUnitId: adMobService!.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdLoaded: (Ad ad) {
        log('Ad Loaded');
        bannerAd.value = ad as BannerAd;
        adLoaded.value = true;
      }, onAdFailedToLoad: (ad, error) {
        log('onAdFailedToLoad error: $error');
        ad.dispose();
        loadAd();
      }),
    ).obs;
    return bannerAd.value.load();
  }
}

// import 'package:get/get.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';

// i
// class AdMobController extends GetxController {
//   final AdMobService adMobService = AdMobService(MobileAds.instance.initialize());
//   late AdMobService adMobServiceCall;
//   // Rx<BannerAd?> banner = Rx<BannerAd?>(null)..obs;
//   late BannerAd banner;

//   @override
//   void onInit() {
//     super.onInit();
//     adMobServiceCall = adMobService;
//     adMobServiceCall.initialization.then((value) {
//       banner = BannerAd(
//         adUnitId: adMobServiceCall.bannerAdUnitId,
//         size: AdSize.fullBanner,
//         request: const AdRequest(),
//         listener: adMobServiceCall.bannerListener,
//       )..load();
//     });
//   }
// }
