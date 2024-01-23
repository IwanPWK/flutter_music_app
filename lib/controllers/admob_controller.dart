// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// import '../services/ad_mob_services.dart';

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
