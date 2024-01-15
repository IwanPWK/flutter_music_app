import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../consts/colors.dart';
import '../consts/text_style.dart';
import '../controllers/player_controller.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 100,
          itemBuilder: (BuildContext context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: bgColor,
                title: Text(
                  "Music name",
                  style: ourStyle(family: bold, size: 15),
                ),
                subtitle: Text(
                  "Artist name",
                  style: ourStyle(family: bold, size: 12),
                ),
                leading: const Icon(
                  Icons.music_note,
                  color: whiteColor,
                  size: 32,
                ),
                trailing: const Icon(
                  Icons.play_arrow,
                  size: 26,
                  color: whiteColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
