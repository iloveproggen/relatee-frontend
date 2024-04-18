import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

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
                letterSpacing: -1,
                fontSize: 35,
                color: Color.fromARGB(255, 74, 70, 70),
                fontWeight: FontWeight.w800,
                fontFamily: "Karla"),
            bodySmall: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 74, 70, 70),
                fontFamily: "Karla",
                letterSpacing: 0),
            bodyMedium: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 74, 70, 70),
                fontFamily: "Sedan",
                letterSpacing: 0),
          ),
          scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243)),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 160, left: 40, right: 40),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WelcomeText(),
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text("Recommended", style: TextStyle(color: Color.fromARGB(255, 204, 198, 196), fontSize: 20, fontFamily: "Karla")),
                  )),
              ButtonRecommended(task: "do the dishes"),
              ButtonRow(),
              ButtonCompleted(who:"Marvin", what:"do the dishes", time:"today"),
              TaskOverview()
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
        Container(height: 80)
      ],
    ));
  }
}

// ButtonWidget
class ButtonRecommended extends StatelessWidget {
  const ButtonRecommended({super.key, required this.task});

  final String task;
  final double height = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      children: [
        Container(
          height: height,
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
                                  //fontWeight: FontWeight.bold
                                  )),
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

class ButtonCompleted extends StatelessWidget {
  const ButtonCompleted({super.key, required this.who, required this.what, required this.time});

  final String who;
  final String what;
  final String time;
  final double height = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      children: [
        Container(
          height: height,
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
                          padding: const EdgeInsets.only(left:30, right:30),
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: 
                              TextSpan(
                                text: "$who completed",
                                style: const TextStyle(color: Color.fromARGB(255, 74, 70, 70), fontFamily: "Karla", fontSize: 25),
                              children: <TextSpan>[
                                TextSpan(
                                  text: " \"$what\" ",
                                  style: const TextStyle(fontWeight: FontWeight.bold,)
                                ),
                                TextSpan(
                                  text: "$time.",
                                )
                              ]
                                  //fontWeight: FontWeight.bold
                          )),
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

  final double height = 150;
  final String number;
  final String textBelow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      children: [
        Container(
          height: height,
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
                          fontSize: 55,
                          fontFamily: "Karla",
                          fontWeight: FontWeight.bold),
                        maxLines: 1,),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(textBelow,
                        style: const TextStyle(
                            fontSize: 17, fontFamily: "Karla", letterSpacing: -0.5),
                          textAlign: TextAlign.center, maxLines: 1),
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
            textBelow: "left this week",
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

class TaskOverview extends StatefulWidget {
  const TaskOverview({super.key});

  @override
  State<TaskOverview> createState() => _TaskState();
}

class _TaskState extends State<TaskOverview> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 100),
        Text("All Tasks", style: Theme.of(context).textTheme.bodyLarge),
        Container(height: 20),
        Task(taskName: "do the dishes")
      ],
    );
  }
}

class Task extends StatelessWidget {
  Task({super.key, required this.taskName});

  final String taskName;
  /*final Widget green = SvgPicture.asset("assets/images/green.svg");
  final Widget yellow = SvgPicture.asset("assets/images/yellow.svg");
  final Widget red = SvgPicture.asset("assets/images/red.svg");*/

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 30, left: 20),
        child: Row(
          children: [
            Text(taskName, style: Theme.of(context).textTheme.bodySmall),
            SvgPicture.asset("assets/images/green.svg"),
          ],),
      ),
    );
  }
}