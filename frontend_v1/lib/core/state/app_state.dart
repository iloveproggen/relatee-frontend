import 'package:flutter/material.dart';

class AppState {
  AppState._();

  static Color userColor = Colors.blue;
  static VoidCallback update = _noop;
  static VoidCallback updateWithoutReload = _noop;

  static Map<String, dynamic> userData = <String, dynamic>{};
  static List<Map<String, dynamic>> tasks = <Map<String, dynamic>>[];
  static List<Map<String, dynamic>> users = <Map<String, dynamic>>[];
  static Map<String, dynamic> householdData = <String, dynamic>{};

  static void _noop() {}
}
