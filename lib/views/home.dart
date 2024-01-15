import 'package:flutter/material.dart';

import '../consts/colors.dart';
import '../consts/text_style.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
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
          itemCount: 100,
          itemBuilder: (BuildContext context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
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
