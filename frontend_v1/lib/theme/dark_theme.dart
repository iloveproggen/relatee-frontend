import 'package:flutter/material.dart';

ThemeData darktheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme:  AppBarTheme(
    backgroundColor: Colors.black,
    iconTheme: IconThemeData(color: Colors.grey[900]!),
    titleTextStyle: TextStyle(color: Colors.grey[900]!, fontSize: 20)
  ),
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Colors.grey[900]!,
    secondary: Colors.grey[700]!,
  )
);
