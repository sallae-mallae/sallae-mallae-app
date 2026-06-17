import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double input = 18;
  static const double lg = 20;
  static const double xl = 24;
  static const double modal = 28;
  static const double device = 48;
  static const double pill = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
  static const BorderRadius pillShape = BorderRadius.all(Radius.circular(pill));
}
