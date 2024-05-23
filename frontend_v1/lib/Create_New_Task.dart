import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void createNewTask(int routineId, String name, String deadline, String description, int points,
    Map<String, dynamic> userData) async {
final Map<String, dynamic> variables = {
    'userId': userData['userId'],
    'householdId': userData['householdId'],
    'routineId': routineId,
    'name': name,
    'deadline': deadline,
    'description': description,
    'points': points,
    'status': 0
};

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(r'''mutation CreateTask($userId: Int!, $householdId: Int!, $routineId: Int, $name: String!, $deadline: String, $description: String, $points: Int!, $status: Int!) {
  createTask(userId: $userId, householdId: $householdId, routineId: $routineId, name: $name, deadline: $deadline, description: $description, points: $points, status: $status) {
    userId
    householdId
    routineId
    name
    deadline
    description
    points
    status
  }
}
'''),
    variables: variables,
  );

  try {
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      // Handle the result
      print(result.data);
      print("pushed the new item to the db: $variables");
    }
  } catch (e) {
    print(e);
  }
}

class NewTask extends StatelessWidget {
  const NewTask({super.key, required this.userData});


  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            children: [
              BackIconRow(),
              CustomTextField(),
              SliderWidgetRepeat(),
              SliderWidgetWho(),
              SizedBox(height: 40),
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
          children: [
            TextFormField(
              decoration: InputDecoration.collapsed(
                hintText: ('new_task_txt'.tr),
              ),
              style: const TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 74, 70, 70),
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
  State<SliderWidgetRepeat> createState() => _SliderWidgetState();
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
      child: Padding(
        // Hinzufügen von Padding um den Container
        padding: const EdgeInsets.only(
            top: 60.0), // Verschieben Sie den Slider nach unten
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
                alignment:
                    _isPermanent ? Alignment.centerLeft : Alignment.centerRight,
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
                        'repeat_txt'.tr,
                        style: TextStyle(
                          color: _isPermanent
                              ? Colors.black
                              : const Color(0xFF4A4646),
                          fontSize: 20,
                          fontFamily: 'Karla',
                          fontWeight:
                              _isPermanent ? FontWeight.w700 : FontWeight.w300,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'only_once_txt'.tr,
                        style: TextStyle(
                          color: !_isPermanent
                              ? Colors.black
                              : const Color(0xFF4A4646),
                          fontSize: 20,
                          fontFamily: 'Karla',
                          fontWeight:
                              !_isPermanent ? FontWeight.w700 : FontWeight.w300,
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
  State<SliderWidgetWho> createState() => _SliderWidgetStateWho();
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
                        color: _selectedOption == i
                            ? const Color(0xFFD9D9D9)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          _getOptionText(i),
                          style: TextStyle(
                            color: _selectedOption == i
                                ? Colors.black
                                : const Color(0xFF4A4646),
                            fontSize: 20,
                            fontFamily: 'Karla',
                            fontWeight: _selectedOption == i
                                ? FontWeight.w700
                                : FontWeight.w300,
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
        return 'anyone_txt'.tr;
      case 1:
        return 'everyone_txt'.tr;
      case 2:
        return 'someone_txt'.tr;
      case 3:
        return 'rotate_txt'.tr;
      default:
        return '';
    }
  }
}

class AssignTo extends StatelessWidget {
  const AssignTo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10, right: 20, bottom: 10),
              child: Icon(
                CupertinoIcons.person_fill,
                size: 40,
                color: Color.fromARGB(255, 204, 198, 196),
              ),
            ),
            Text(('assign_to_txt'.tr),
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: "Karla",
                  color: Color.fromARGB(255, 74, 70, 70),
                )),
          ],
        ),
        const Text(
          "Name",
          style: TextStyle(
            fontSize: 20,
            fontFamily: "Karla",
            color: Color.fromARGB(255, 74, 70, 70),
          ),
        ),
      ],
    );
  }
}

class Repeats extends StatelessWidget {
  const Repeats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 10, right: 20, bottom: 10),
          child: Icon(
            CupertinoIcons.clock,
            size: 40,
            color: Color.fromARGB(255, 204, 198, 196),
          ),
        ),
        Text(
          ('repeats_txt'.tr),
          style: const TextStyle(
            fontSize: 20,
            fontFamily: "Karla",
            color: Color.fromARGB(255, 74, 70, 70),
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
  State<WeekdaySelector> createState() => _WeekdaySelectorState();
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