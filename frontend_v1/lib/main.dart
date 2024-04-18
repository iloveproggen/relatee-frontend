import 'package:flutter/material.dart';

void main() {
  runApp(const MainWidget());
}

// MainWidget

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          fontFamily: 'Karla',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
                fontSize: 40,
                color: Color.fromARGB(255, 74, 70, 70),
                fontWeight: FontWeight.bold,
                fontFamily: "Karla",
                letterSpacing: 0),
            bodySmall: TextStyle(
                fontSize: 25,
                color: Color.fromARGB(255, 74, 70, 70),
                fontFamily: "Karla",
                letterSpacing: 0),
            bodyMedium: TextStyle(
                fontSize: 25,
                color: Color.fromARGB(255, 74, 70, 70),
                fontFamily: "Sedan",
                letterSpacing: 0),
          ),
          scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243)),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(100),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WelcomeText(),
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text("Recomended", style: TextStyle(color: Color.fromARGB(255, 204, 198, 196), fontSize: 20, fontFamily: "Karla")),
                  )),
              ButtonLong(task: "do the dishes"),
              ButtonRow(),
              ButtonLong(task: "Marvin completed \"do the dishes\" today.")
            ]),
          ),
        ),
      ),
    );
  }
}

// TextWidget

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome, Michelle!",
            style: Theme.of(context).textTheme.bodyLarge),
        Text("Time to get productive.",
            style: Theme.of(context).textTheme.bodySmall),
        Container(height: 70)
      ],
    ));
  }
}

// ButtonWidget

class ButtonLong extends StatelessWidget {
  const ButtonLong({super.key, required this.task});

  final String task;
  final int height = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Color.fromARGB(255, 243, 243, 243),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(61, 109, 103, 103),
                  offset: Offset(5.0, 5.0),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                )
              ]),
          child: Column(
              //color: Colors.amber,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:10, right:10),
                          child: Text(task,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontFamily: "Karla",
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )),
              ]),
        ),
        const SizedBox(height: 30)
      ],
    ));
  }
}

class ButtonShort extends StatelessWidget {
  const ButtonShort({super.key, required this.number, required this.textBelow});

  final int height = 150;
  final String number;
  final String textBelow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Color.fromARGB(255, 243, 243, 243),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(61, 109, 103, 103),
                  offset: Offset(5.0, 5.0),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                )
              ]),
          child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(number,
                      style: const TextStyle(
                          fontSize: 50,
                          fontFamily: "Karla",
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(textBelow,
                        style: const TextStyle(
                            fontSize: 20, fontFamily: "Karla")),
                  )
                ],
              )),
        ),
        const SizedBox(height: 30)
      ],
    ));
  }
}

//ButtonRow containing Button Widgets

class ButtonRow extends StatelessWidget {
  const ButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        child: Row(
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(right: 15),
          child: ButtonShort(
            number: "10",
            textBelow: "left to do this week",
          ),
        )),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(left: 15),
          child: ButtonShort(
            number: "2",
            textBelow: "done this week",
          ),
        )),
      ],
    ));
  }
}
