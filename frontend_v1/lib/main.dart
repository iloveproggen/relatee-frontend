import 'package:flutter/material.dart';

void main() {
  runApp(const MyHomePage());
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relatee',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 189, 187, 187),
          title: const Text("Test"),
        ),
        body: const Column(
          children: [
            Text("Text1"),
            Text("Text1"),
            Text("Text1"),
            Text("Text1")
          ],)
      ),
    );
  }
}
