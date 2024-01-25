import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'controllers/player_controller.dart';
// import 'controllers/player_controller.dart';
import 'global.dart';
import 'services/ad_mob_services.dart';
import 'views/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // controller.checkPermission();

  final initAdFuture = MobileAds.instance.initialize();
  adMobService = AdMobService(initAdFuture);
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Music App',
      theme: ThemeData(
        fontFamily: "regular",
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
        useMaterial3: true,
      ),
      home: Home(),
    );
  }
}
