import 'package:flutter/material.dart';

ThemeData lighttheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 204, 198, 196)),
        titleTextStyle:
            TextStyle(color: Color.fromARGB(255, 74, 70, 70), fontSize: 20)),
    textTheme: const TextTheme(
        bodyLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: "Sedan",
            letterSpacing: 0),
        bodyMedium: TextStyle(
            letterSpacing: -1,
            fontSize: 23,
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontFamily: "Karla"),
        bodySmall: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 58, 58, 58),
            fontFamily: "Karla",
            letterSpacing: 0),
        labelSmall: TextStyle(
            color: Color.fromARGB(255, 140, 127, 147),
            fontSize: 16,
            fontFamily: "Karla",
            fontWeight: FontWeight.bold),
        labelLarge: TextStyle(
            color: Color.fromARGB(255, 140, 127, 147),
            fontSize: 15,
            fontFamily: "Karla",
            fontWeight: FontWeight.bold)),
    colorScheme: const ColorScheme.light(
      surface: Color.fromARGB(255, 255, 255, 255),
      primary: Color.fromARGB(255, 255, 255, 255),
      secondary: Color.fromARGB(60, 83, 76, 76),
      tertiary: Color.fromARGB(255, 130, 92, 206),
      onPrimary: Color.fromARGB(255, 210, 194, 241),
      onSecondary: Color.fromARGB(255, 130, 92, 206),
      inversePrimary: Color(0xFF4A4646),
    ));
