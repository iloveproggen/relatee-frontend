import 'package:flutter/material.dart';

//purpose: Define the light theme for the app
//author: Maurice, Michelle
//Date: 11.05.2024

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
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 74, 70, 70),
            fontFamily: "Sedan",
            letterSpacing: 0),
        bodyMedium: TextStyle(
            letterSpacing: -1,
            fontSize: 30,
            color: Color.fromARGB(255, 74, 70, 70),
            fontWeight: FontWeight.w800,
            fontFamily: "Karla"),
        bodySmall: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 74, 70, 70),
            fontFamily: "Karla",
            letterSpacing: 0),
        labelSmall: TextStyle(
            color: Color.fromARGB(255, 204, 198, 196),
            fontSize: 20,
            fontFamily: "Karla",
            fontWeight: FontWeight.bold)),
    colorScheme: const ColorScheme.light(
      background: Color.fromARGB(255, 243, 243, 243),
      primary: Color.fromARGB(255, 243, 243, 243),
      secondary: Color.fromARGB(60, 83, 76, 76),
      tertiary: Color.fromARGB(255, 204, 198, 196),
      onPrimary: Color.fromARGB(255, 204, 198, 196),
      onSecondary: Color.fromARGB(255, 130, 122, 122),
    ));
