import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Karla',
        textTheme: const TextTheme().apply(bodyColor:const Color.fromARGB(255,74,70,70)),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 175, 175, 175)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243)
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 187, 184, 184),
        foregroundColor: const Color.fromARGB(255,255,255,255),
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700),),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the \nbutton this many times:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color:Color.fromARGB(255,74,70,70)),
              textAlign: TextAlign.center,
            ),
            Text(
              '$_counter',
              //style: const TextStyle(fontFamily: "Sedan", fontSize: 90)
              style: GoogleFonts.yatraOne(textStyle: const TextStyle(fontSize: 100, color:Color.fromARGB(255,74,70,70)))
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        hoverColor: const Color.fromARGB(255, 255, 255, 255),
        tooltip: 'Boo!',
        backgroundColor: const Color.fromARGB(255, 187, 184, 184),
        foregroundColor: const Color.fromARGB(255,255,255,255),
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
