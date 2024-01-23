// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class AdMobService {
//   Future<InitializationStatus> initialization;

//   AdMobService(this.initialization);

//   static String get bannerAdUnitId {
//     if (kReleaseMode) {
//       return "ca-app-pub-2432858870037025/9691615585";
//     } else {
//       return "ca-app-pub-3940256099942544/6300978111";
//     }
//   }

//   String get interstitialAdUnitId {
//     if (kReleaseMode) {
//       return "ca-app-pub-2432858870037025/7556406831";
//     } else {
//       return "ca-app-pub-3940256099942544/1033173712";
//     }
//   }

//   // static final BannerAdListener bannerListener = BannerAdListener(
//   //   onAdLoaded: (ad) => log('Ad loaded'),
//   //   onAdFailedToLoad: (ad, error) {
//   //     ad.dispose();
//   //     log('Ad failed to load: $error');
//   //   },
//   //   onAdOpened: (ad) => log('Ad opened.'),
//   //   onAdClosed: (ad) => log('Ad closed.'),
//   // );
// }
