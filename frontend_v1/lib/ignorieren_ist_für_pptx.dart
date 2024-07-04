import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                      'Button: ',
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      //This is where you define the action of the button
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.purple[200]!)),
                    child: Icon(Icons.ballot, color: Colors.white),)]), 
              Text(
                      'This is a Widget!',
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    ),
          ], // Add your widget tree here
        ),
      ),
    );
  }
}
