import 'package:flutter/widgets.dart';

abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

abstract final class Radii {
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
  static const BorderRadius card = BorderRadius.all(md);
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
}

abstract final class Layout {
  static const double maxContentWidth = 560;
  static const double compactWidth = 600;
  static const double narrowWidth = 360;
}
