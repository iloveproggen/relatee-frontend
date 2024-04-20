import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainWidget());
}

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
          bodyText1: TextStyle(
              color: Color.fromARGB(255, 99, 21, 21), fontSize: 20),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(),
              SliderWidgetRepeat(),
              SliderWidgetWho(),
              AssignTo(),
              Repeats()
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Form(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 20),
              child: TextFormField(
                decoration: const InputDecoration.collapsed(
                  hintText: 'new task..',
                ),
                style: const TextStyle(fontSize: 30, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SliderWidgetRepeat extends StatefulWidget {
  const SliderWidgetRepeat({super.key});

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}
class _SliderWidgetState extends State<SliderWidgetRepeat> {
  bool _isPermanent = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPermanent = !_isPermanent;
        });
      },
      child: Padding( // Hinzufügen von Padding um den Container
        padding: const EdgeInsets.only(top: 60.0), // Verschieben Sie den Slider nach unten
        child: Container(
          width: 386,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0x7FD9D9D9),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: _isPermanent ? Alignment.centerLeft : Alignment.centerRight,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Container(
                  width: 193,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'repeat',
                        style: TextStyle(
                          color: _isPermanent ? Colors.black : const Color(0xFF4A4646),
                          fontSize: 20,
                          fontFamily: 'Karla',
                          fontWeight: _isPermanent ? FontWeight.w700 : FontWeight.w300,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'only once',
                        style: TextStyle(
                          color: !_isPermanent ? Colors.black : const Color(0xFF4A4646),
                          fontSize: 20,
                          fontFamily: 'Karla',
                          fontWeight: !_isPermanent ? FontWeight.w700 : FontWeight.w300,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SliderWidgetWho extends StatefulWidget {
  const SliderWidgetWho({super.key});

  @override
  _SliderWidgetStateWho createState() => _SliderWidgetStateWho();
}

class _SliderWidgetStateWho extends State<SliderWidgetWho> {
  int _selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        setState(() {
          // Berechnen Sie den Bereich der x- und y-Koordinaten basierend auf dem Tippen
          double x = details.localPosition.dx;
          double y = details.localPosition.dy;

          // Bestimmen Sie die ausgewählte Option basierend auf den Koordinaten
          if (x < MediaQuery.of(context).size.width / 2) {
            if (y < MediaQuery.of(context).size.height / 2) {
              _selectedOption = 0; // Oben links
            } else {
              _selectedOption = 2; // Unten links
            }
          } else {
            if (y < MediaQuery.of(context).size.height / 2) {
              _selectedOption = 1; // Oben rechts
            } else {
              _selectedOption = 3; // Unten rechts
            }
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: Container(
          width: 386,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0x7FD9D9D9),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            children: [
              // Erstellen Sie vier Container für die verschiedenen Optionen
              for (int i = 0; i < 4; i++)
                Positioned(
                  left: i % 2 == 0 ? 0 : null,
                  right: i % 2 != 0 ? 0 : null,
                  top: i < 2 ? 0 : null,
                  bottom: i >= 2 ? 0 : null,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOption = i;
                      });
                    },
                    child: Container(
                      width: 193,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _selectedOption == i ? const Color(0xFFD9D9D9) : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          _getOptionText(i),
                          style: TextStyle(
                            color: _selectedOption == i ? Colors.black : const Color(0xFF4A4646),
                            fontSize: 20,
                            fontFamily: 'Karla',
                            fontWeight: _selectedOption == i ? FontWeight.w700 : FontWeight.w300,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getOptionText(int optionIndex) {
    switch (optionIndex) {
      case 0:
        return 'anyone';
      case 1:
        return 'everyvone';
      case 2:
        return 'someone';
      case 3:
        return 'rotate';
      default:
        return '';
    }
  }
}

class AssignTo extends StatelessWidget {
  const AssignTo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, top: 75),
        child: Icon(CupertinoIcons.person_alt_circle_fill, size: 40),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, top: 75),
          child: Text("assign to: ",
            style: TextStyle(
              fontSize: 20
            ) ,
          ),
        ),
        Padding(
            padding: EdgeInsets.only(left: 70, top: 75),
            child: Text("Name",
              style: TextStyle(
                  fontSize: 20
              ) ,
            )
        )
      ],
    );
  }
}

class Repeats extends StatelessWidget {
  const Repeats({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: Icon(CupertinoIcons.clock_fill, size: 40),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: Text("repeats: ",
            style: TextStyle(
                fontSize: 20
            ) ,
          ),
        ),
      ],
    );
  }
}
/*
class WeekdaySelector extends StatefulWidget {
  const WeekdaySelector({super.key})

  @override
  _WeekdaySelectorState createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  Set<String> _selectedDays = {};

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  List<Widget> _buildWeekdayWidgets() {
    return ['M', 'D', 'M', 'D', 'F', 'S', 'S'].map((day) {
      return GestureDetector(
        onTap: () => _toggleDay(day),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _selectedDays.contains(day) ? Colors.blue : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: _selectedDays.contains(day) ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _buildWeekdayWidgets(),
    );
  }
}
 */


