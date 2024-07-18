import 'package:flutter/material.dart';

//purpose: Define the dark theme for the app
//author: Maurice, Michelle
//Date: 11.05.2024

ThemeData darktheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 55, 53, 52)),
        titleTextStyle:
            TextStyle(color: Color.fromARGB(255, 74, 70, 70), fontSize: 20)),
    textTheme: const TextTheme(
        bodyLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 183, 177, 175),
            fontFamily: "Karla",
            letterSpacing: 0),
        bodyMedium: TextStyle(
            letterSpacing: -1,
            fontSize: 23,
            color: Color.fromARGB(255, 183, 177, 175),
            fontWeight: FontWeight.w800,
            fontFamily: "Karla"),
        bodySmall: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 183, 177, 175),
            fontFamily: "Karla",
            letterSpacing: 0),
        labelSmall: TextStyle(
            color: Color.fromARGB(255, 204, 198, 196),
            fontSize: 16,
            fontFamily: "Karla",
            fontWeight: FontWeight.bold),
        labelLarge: TextStyle(
            color: Color.fromARGB(255, 204, 198, 196),
            fontSize: 15,
            fontFamily: "Karla",
            fontWeight: FontWeight.bold)),
    colorScheme: const ColorScheme.light(
      background: Color.fromARGB(255, 50, 48, 48),
      primary: Color.fromARGB(255, 50, 48, 48),
      secondary: Color.fromARGB(168, 0, 0, 0),
      tertiary: Color.fromARGB(255, 183, 177, 175),
      onPrimary: Color.fromARGB(255, 74, 70, 70) ,
      onSecondary:Color.fromARGB(255, 204, 198, 196),
      inversePrimary: Color(0xFF4A4646),
    ));
