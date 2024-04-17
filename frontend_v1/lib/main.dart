import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: WelcometextWidget(),
        ),
      ),
    );
  }
}

class WelcometextWidget extends StatelessWidget {
  const WelcometextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 327,
      height: 74,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              'Welcome, Michelle!',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color.fromRGBO(74, 70, 70, 1),
                fontFamily: 'Karla',
                fontSize: 32,
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
          Positioned(
            top: 43,
            left: 0,
            child: Text(
              'time to get productive.',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color.fromRGBO(74, 70, 70, 1),
                fontFamily: 'Karla',
                fontSize: 20,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
