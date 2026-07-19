import 'package:flutter/material.dart';

/// Corner radius tokens — precise, not pill-heavy.
abstract final class AfterRadius {
  static const double none = 0;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));

  /// Buttons, chips, compact controls.
  static const double control = sm;

  /// Cards, list rows, inputs.
  static const double surface = md;

  /// Dialogs, sheets, large panels.
  static const double panel = lg;

  /// Hero media frames (use sparingly).
  static const double media = xl;
}
