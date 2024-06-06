import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

Map<String, dynamic> assignedToUser = {};

DateTime? deadline;

bool isPermanent = false;

void updateTask(String name, String? description, int reward, int? routineId,
    Map<String, dynamic> userData, Map<String, dynamic> task) async {
  // Update task
  final Map<String, dynamic> variables = {
    'id': task['id'],
    'householdId': userData['householdId'],
    'routineId': routineId,
    'name': name,
    'deadline': deadline != null ? '${deadline!.toIso8601String().split('.')[0]}Z' : null,
    'description': description,
    'reward': reward,
    'status': 0
  };

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(
        r'''mutation UpdateTask($id: Int!, $userId: Int, $householdId: Int, $routineId: Int, $name: String, $deadline: String, $description: String, $reward: Int, $completed: Boolean) {
    updateTask(id: $id, userId: $userId, householdId: $householdId, routineId: $routineId, name: $name, deadline: $deadline, description: $description, reward: $reward, completed: $completed) {
      id
      householdId
      routineId
      name
      deadline
      description
      reward
      completed
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

class DetailedTaskView extends StatefulWidget {
  const DetailedTaskView(
      {super.key,
      required this.task,
      required this.userData,
      required this.assigned});

  final Map<String, dynamic> task;
  final Map<String, dynamic> userData;
  final String? assigned;

  @override
  State<DetailedTaskView> createState() => _DetailedTaskViewState(task: task);
}

class _DetailedTaskViewState extends State<DetailedTaskView> {
  _DetailedTaskViewState({required this.task});

  bool required = false;
  final Map<String, dynamic> task;

  late TextEditingController taskName = TextEditingController();
  late TextEditingController taskPrice = TextEditingController();
  late TextEditingController description = TextEditingController();

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
    taskName.addListener(_updateRequired);
    taskPrice.addListener(_updateRequired);
    description.addListener(_updateRequired);

    taskName.text = task['name'];
    taskPrice.text = task['reward'].toString();
    description.text = task['description'];
  }

  void changePermanent() {
    setState(() {});
    isPermanent = !isPermanent;
  }

  @override
  Widget build(BuildContext context) {
    print(task);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackIconRow(),
                  TextButton(
                    style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(0),
                      ),
                      animationDuration: Duration.zero,
                    ),
                    onPressed: () {
                      print(taskName.text);
                      print(taskPrice.text);
                      print(description.text);
                      if (taskName.text.isEmpty) {
                        taskName.text = task['name'];
                      }
                      if (taskPrice.text.isEmpty) {
                        taskPrice.text = task['reward'].toString();
                      }
                      updateTask(
                          taskName.text,
                          description.text,
                          int.parse(taskPrice.text),
                          task['routineId'],
                          widget.userData,
                          task);
                      Get.back(result: "Changed Task");
                    },
                    child: Text("Save",
                        style: Theme.of(context).textTheme.labelLarge),
                  )
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: taskName,
                        decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            hintText: "rename task...",
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                )),
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLength: 30,
                      ),
                    ],
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () {
              //     setState(() {
              //       changePermanent();
              //     });
              //   },
              //   child: Padding(
              //     // Hinzufügen von Padding um den Container
              //     padding: const EdgeInsets.only(
              //         top: 40), // Verschieben Sie den Slider nach unten
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: const Color(0x7FD9D9D9),
              //         borderRadius: BorderRadius.circular(7),
              //       ),
              //       child: Stack(
              //         alignment: Alignment.center,
              //         children: [
              //           AnimatedAlign(
              //             alignment: isPermanent
              //                 ? Alignment.centerLeft
              //                 : Alignment.centerRight,
              //             duration: const Duration(milliseconds: 200),
              //             curve: Curves.easeInOut,
              //             child: FractionallySizedBox(
              //               widthFactor: 0.5,
              //               child: Container(
              //                 height: 50,
              //                 decoration: BoxDecoration(
              //                   color: const Color(0xFFD9D9D9),
              //                   borderRadius: BorderRadius.circular(7),
              //                 ),
              //               ),
              //             ),
              //           ),
              //           Row(
              //             children: [
              //               Expanded(
              //                 child: Center(
              //                   child: Text(
              //                     'repeat_txt'.tr,
              //                     style: TextStyle(
              //                       color: isPermanent
              //                           ? Colors.black
              //                           : const Color(0xFF4A4646),
              //                       fontSize: 20,
              //                       fontFamily: 'Karla',
              //                       fontWeight: isPermanent
              //                           ? FontWeight.w700
              //                           : FontWeight.w300,
              //                       height: 0,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //               Expanded(
              //                 child: Center(
              //                   child: Text(
              //                     'only_once_txt'.tr,
              //                     style: TextStyle(
              //                       color: !isPermanent
              //                           ? Colors.black
              //                           : const Color(0xFF4A4646),
              //                       fontSize: 20,
              //                       fontFamily: 'Karla',
              //                       fontWeight: !isPermanent
              //                           ? FontWeight.w700
              //                           : FontWeight.w300,
              //                       height: 0,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 20),
                    child: Icon(CupertinoIcons.person,
                        size: 40,
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  Text("assigned to:",
                      style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  Text(
                      widget.assigned != null
                          ? widget.assigned!
                          : "anyone_txt".tr,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              isPermanent
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 10, right: 20, bottom: 10),
                          child: Icon(
                            CupertinoIcons.clock_fill,
                            size: 40,
                            color:  Theme.of(context).colorScheme.tertiary
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
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20),
                    child: Icon(
                      CupertinoIcons.add_circled,
                      size: 40,
                      color:  Theme.of(context).colorScheme.tertiary
                    ),
                  ),
                  Text(
                    'price:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Expanded(
                    child: TextField(
                        cursorColor: Theme.of(context).colorScheme.onSecondary,
                        textAlign: TextAlign.end,
                        controller: taskPrice,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            hintText: "change reward...",
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                            border: InputBorder.none),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.calendar,
                      size: 40, color: Theme.of(context).colorScheme.tertiary),
                  const SizedBox(width: 20, height: 60),
                  Text("deadline:",
                      style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  TextButton(
                    style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            color: Theme.of(context).colorScheme.background,
                            height: 400,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: DateTime.now(),
                              maximumYear: DateTime.now().year + 3,
                              minimumYear: DateTime.now().year,
                              onDateTimeChanged: (DateTime newDateTime) {
                                print(newDateTime);
                                setState(() {
                                  deadline = newDateTime;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      deadline != null
                          ? DateFormat('dd-MM-yyyy').format(deadline!)
                          : "none",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  deadline != null ? IconButton(
                    style: ButtonStyle(alignment: Alignment.centerRight,
                    animationDuration: Duration.zero, 
                    padding: MaterialStateProperty.all(EdgeInsets.zero)),
                    icon: Icon(CupertinoIcons.clear,
                        color: Theme.of(context).colorScheme.tertiary),
                    onPressed: () {
                      setState(() {
                        deadline = null; 
                      });
                    },
                  )
                  : Container(),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, bottom: 10, right: 20),
                        child: Icon(
                          CupertinoIcons.text_aligncenter,
                          size: 40,
                          color:  Theme.of(context).colorScheme.tertiary
                        ),
                      ),
                      Expanded(
                          child: Text(
                        'description:',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodySmall,
                      )),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextField(
                          textInputAction:
                              TextInputAction.done, // Add this line
                          onEditingComplete: () =>
                              FocusScope.of(context).unfocus(), // Add this line
                          cursorColor:
                              Theme.of(context).colorScheme.onSecondary,
                          maxLines: 4,
                          controller: description,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              counterText: '',
                              hintText: "change description...",
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                              border: InputBorder.none),
                          maxLength: 100,
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,)))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
