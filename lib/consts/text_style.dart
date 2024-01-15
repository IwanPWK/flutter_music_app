import 'package:flutter/material.dart';

import 'colors.dart';

const bold = 'bold';
const regular = 'regular';

ourStyle({String family = regular, double size = 14, Color color = whiteColor}) {
  return TextStyle(
    fontSize: size,
    color: whiteColor,
    fontFamily: family,
  );
}
