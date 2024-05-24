import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Map<String, dynamic> assignedToUser = {};
List<Map<String, dynamic>> householdUsers = [
  {
    'forename': '...',
    'surname': '...',
    'id': null,
    'username': '...',
  }
];
bool isPermanent = false;

void createNewTask(int? userId, String name, String description, int points,
    Map<String, dynamic> userData) async {
  final Map<String, dynamic> variables = {
    'userId': userId,
    'householdId': userData['householdId'],
    'routineId': null,
    'name': name,
    'deadline': DateTime.now().toIso8601String().split('.')[0] + 'Z',
    'description': description,
    'points': points,
    'status': 0
  };

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(
        r'''mutation CreateTask($userId: Int!, $householdId: Int!, $routineId: Int, $name: String!, $deadline: String, $description: String, $points: Int!, $status: Int!) {
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

class NewTask extends StatefulWidget {
  const NewTask({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  bool required = false;

  TextEditingController taskName = TextEditingController();
  TextEditingController taskPrice = TextEditingController();
  TextEditingController description = TextEditingController();

  void _updateRequired() {
    setState(() {
      required = _checkInputs(); // Update required based on inputs
    });
  }

  bool _checkInputs() {
    return taskName.text.isNotEmpty &&
        taskPrice.text.isNotEmpty &&
        assignedToUser.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Add listener to text controllers to update required variable
    taskName.addListener(_updateRequired);
    taskPrice.addListener(_updateRequired);
    description.addListener(_updateRequired);
  }

  void changePermanent() {
    setState(() {});
    isPermanent = !isPermanent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const BackIconRow(),
              Align(
                alignment: Alignment.topLeft,
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: taskName,
                        decoration: InputDecoration.collapsed(
                          hintText: ('new_task_txt'.tr),
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Sedan",
                            fontSize: 40,
                            color: Color.fromARGB(255, 204, 198, 196),
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    changePermanent();
                  });
                },
                child: Padding(
                  // Hinzufügen von Padding um den Container
                  padding: const EdgeInsets.only(
                      top: 40), // Verschieben Sie den Slider nach unten
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0x7FD9D9D9),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedAlign(
                          alignment: isPermanent
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(7),
                              ),
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
                                    color: isPermanent
                                        ? Colors.black
                                        : const Color(0xFF4A4646),
                                    fontSize: 20,
                                    fontFamily: 'Karla',
                                    fontWeight: isPermanent
                                        ? FontWeight.w700
                                        : FontWeight.w300,
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
                                    color: !isPermanent
                                        ? Colors.black
                                        : const Color(0xFF4A4646),
                                    fontSize: 20,
                                    fontFamily: 'Karla',
                                    fontWeight: !isPermanent
                                        ? FontWeight.w700
                                        : FontWeight.w300,
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
              ),
              //const SliderWidgetWho(),
              const SizedBox(height: 40),
              AssignTo(userData: widget.userData),
              isPermanent
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 10, right: 20, bottom: 10),
                          child: Icon(
                            CupertinoIcons.clock_fill,
                            size: 40,
                            color: Color.fromARGB(255, 204, 198, 196),
                          ),
                        ),
                        Text(
                          ('repeats_txt'.tr),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    )
                  : Container(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10, right: 20),
                    child: Icon(
                      CupertinoIcons.add_circled,
                      size: 40,
                      color: Color.fromARGB(255, 204, 198, 196),
                    ),
                  ),
                  Text(
                    'price:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Expanded(
                    child: TextField(
                        textAlign: TextAlign.end,
                        controller: taskPrice,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                            hintText: "add price",
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 204, 198, 196),
                                fontSize: 20),
                            border: InputBorder.none),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10, bottom: 10, right: 20),
                        child: Icon(
                          CupertinoIcons.text_aligncenter,
                          size: 40,
                          color: Color.fromARGB(255, 204, 198, 196),
                        ),
                      ),
                      Expanded(
                          child: Text(
                        'description',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodySmall,
                      )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextField(
                        maxLines: 3,
                        controller: description,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            hintText: 'None Yet',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 204, 198, 196),
                                fontSize: 20),
                            border: InputBorder.none),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                    decoration: required
                        ? const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color.fromARGB(255, 74, 70, 70),
                            boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(61, 109, 103, 103),
                                  offset: Offset(5.0, 5.0),
                                  blurRadius: 10.0,
                                  spreadRadius: 2.0,
                                )
                              ])
                        : BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                strokeAlign: BorderSide.strokeAlignOutside,
                                width: 5,
                                color:
                                    const Color.fromARGB(255, 204, 198, 196)),
                            color: const Color.fromARGB(255, 243, 243, 243),
                          ),
                    child: TextButton(
                      onPressed: () {
                        print(taskName.text);
                        print(taskPrice.text);
                        print(assignedToUser);
                        print(description.text);
                        createNewTask(
                            assignedToUser['id'],
                            taskName.text,
                            description.text,
                            int.parse(taskPrice.text),
                            widget.userData);
                        //createTask(taskName.text, description.text, int.parse(taskPrice.text), userData);
                        //Get.back();

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => MainWidget(userId: widget.userData['id'])),
                            (route) => false,
                          ).then((value) {
                          setState(() {
                            // Perform any state updates here
                          });
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
                        child: Text(
                          required ? "Confirm" : "Cancel",
                          style: required
                              ? const TextStyle(
                                  color: Color.fromARGB(255, 243, 243, 243),
                                  fontFamily: "Karla",
                                  fontSize: 30,
                                )
                              : const TextStyle(
                                  color: Color.fromARGB(255, 204, 198, 196),
                                  fontFamily: "Karla",
                                  fontSize: 30,
                                ),
                        ),
                      ),
                    )),
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
                      width: 176,
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

class AssignTo extends StatefulWidget {
  const AssignTo({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<AssignTo> createState() => _AssignToState();
}

class _AssignToState extends State<AssignTo> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
          ),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) {
                  return FutureBuilder(
                    future: getHouseholdUsers(widget.userData['id']),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CupertinoActivityIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        print("household data: ${snapshot.data}");
                        List<Map<String, dynamic>> all =
                            householdUsers + snapshot.data!;
                        print(all);
                        return Container(
                          color: Theme.of(context).colorScheme.background,
                          height: 300,
                          child: CupertinoPicker(
                            itemExtent:
                                50, // Increase the item extent to make the items bigger
                            onSelectedItemChanged: (int index) {
                              print(
                                  'Selected member: ${all[index]['forename'] ?? ''}');
                              setState(() {
                                assignedToUser = all[index];
                              });
                            },
                            children: all.map((member) {
                              return Center(
                                child: Text(
                                  member['forename'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
            child: Text(
                assignedToUser['id'] == null
                    ? "anyone"
                    : "${assignedToUser['forename']}",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.bold))),
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
