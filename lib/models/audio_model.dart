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
  String? duration;
  double? max;
  String? position;
  double? val;

  AudioModel();

  AudioModel.fromAudioQuery(data) {
    log('cek data di model ${data.displayNameWOExt}');
    id = data.id;
    uri = data.uri;
    audioPath = data.data;
    directoryPath = path.dirname(data.data);
    title = data.displayNameWOExt;
    artist = data.artist;
    duration = Duration(milliseconds: data.duration).toString().split('.').first;
    max = Duration(milliseconds: data.duration).inMilliseconds.toDouble();
    position = '0:00:00';
    val = 0.0;
  }
}
