import 'package:flutter/material.dart';

class DSRadius {
  DSRadius._();

  static const double xs   = 4;
  static const double sm   = 6;
  static const double md   = 8;
  static const double lg   = 12;
  static const double xl   = 16;
  static const double full = 9999;

  static const BorderRadius borderXs   = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm   = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd   = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg   = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl   = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));
}
