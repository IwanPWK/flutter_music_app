import 'package:flutter/material.dart';

import 'views/home.dart';

void main() {
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Music App',
      theme: ThemeData(
        fontFamily: "regular",
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
