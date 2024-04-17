import 'package:flutter/material.dart';

void main() {
  runApp(const MainWidget());
}

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  // This widget is the root of your application.
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
          body: Padding(
            padding: EdgeInsets.all(100),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [WelcomeText(), Buttons(), ButtonRow()]),
          ),
        ));
  }
}

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

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      children: [
        const SizedBox(
            height: 150,
            width: double.infinity,
            child: DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: Color.fromARGB(255, 243, 243, 243),
                    boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(62, 74, 70, 70),
                    offset: Offset(5.0, 5.0),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  )
                ]
              )
            )
          ),
          
        Container(height: 70)
      ],
      
    )
  );
  }
}

class ButtonRow extends StatelessWidget {
  const ButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      child: Row(
        children: <Widget> [
          Expanded(child: Buttons()),
          Expanded(child: Buttons()),
          ],
        )
    );
  }
}