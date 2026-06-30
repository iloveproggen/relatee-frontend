import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Colors.purple[200]!)),
                    child: const Icon(Icons.ballot, color: Colors.white),
                  )
                ]),
            const Text(
              'This is a Widget!',
              style: TextStyle(fontSize: 30, color: Colors.black),
            ),
          ], // Add your widget tree here
        ),
      ),
    );
  }
}
