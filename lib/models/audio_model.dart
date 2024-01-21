import 'dart:developer';

import 'package:path/path.dart' as path;

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AudioModel {
  int? id;
  String? uri;
  String? audioPath;
  String? directoryPath;
  String? title;
  String? artist;
  int? duration;

  AudioModel();

  AudioModel.fromAudioQuery(data) {
    log('cek data di model ${data}');
    id = data.id;
    uri = data.uri;
    audioPath = data.data;
    directoryPath = path.dirname(data.data);
    title = data.displayNameWOExt;
    artist = data.artist;
    duration = data.duration;
  }
}
