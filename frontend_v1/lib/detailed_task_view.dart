import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';

DateTime? deadline;

double paddingRight = 10;
double iconSize = 30;

bool isPermanent = false;

Map<String, dynamic> nullUser = {
  'forename': 'anyone',
  'surname': '...',
  'id': null,
  'username': '...',
};

Map<String, dynamic> nullRoutine = {
  'name': 'none',
  'id': null,
};

Map<String, dynamic> pickedRoutine = nullRoutine;

List<Map<String, dynamic>> householdUsers = [nullUser];

Map<String, dynamic> assignedToUser = nullUser;

late List<Map<String, dynamic>> users;

Future<void> updateTask(int id, String name, String? description, int reward,
    int? routineId, int assignTo, String emoji, DateTime? deadline) async {
  // Update task to match the GraphQL schema
  final Map<String, dynamic> input = {
    'taskId': id, // Use 'taskId' instead of 'id'
    'name': name,
    'emoji': emoji, // Added emoji field
    'deadline': deadline != null ? '${deadline.toIso8601String().split('.')[0]}Z' : null, // Adjusted deadline format
    'description': description ?? "",
    'reward': reward,
    'routineId': routineId,
    'userId': assignTo, // Added userId field
    'private': false, // Added private field
  };

  final Map<String, dynamic> variables = {
    'input': input,
  };

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(r'''mutation UpdateTask($input: UpdateTaskInput!) {
  updateTask(input: $input) {
    id
    routine {
      id
    }
    name
    emoji
    deadline
    description
    reward
    private
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
    }
  } catch (e) {
    print(e);
  }
}

class DetailedTaskView extends StatelessWidget {
  const DetailedTaskView({super.key,
      required this.task,
      required this.userData,
      required this.assigned});


  final Map<String, dynamic> task;
  final Map<String, dynamic> userData;
  final String? assigned;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getHouseholdData(context), // Ensure this returns Future<List<Map<String, dynamic>>>
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: const CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          print(snapshot.data!);
          users = snapshot.data!['users'];
          users.insert(0, nullUser);
          return Scaffold(
            body: DetailedTask(
              task: task,
              userData: userData,
              assigned: assigned,
            ),
          );
        } else {
          return Text('No data available');
        }
      },
    );
  }
}

class DetailedTask extends StatefulWidget {
  const DetailedTask(
      {super.key,
      required this.task,
      required this.userData,
      required this.assigned});

  final Map<String, dynamic> task;
  final Map<String, dynamic> userData;
  final String? assigned;

  @override
  State<DetailedTask> createState() => _DetailedTaskState(task: task);
}

class _DetailedTaskState extends State<DetailedTask> {
  _DetailedTaskState({required this.task});

  bool required = false;
  final Map<String, dynamic> task;

  late TextEditingController taskName = TextEditingController();
  late TextEditingController taskPrice = TextEditingController();
  late TextEditingController description = TextEditingController();

  String? emojiDisplay;

  void _updateRequired() {
    setState(() {
      required = _checkInputs(); // Update required based on inputs
    });
  }

  bool _checkInputs() {
    return taskName.text.isNotEmpty && taskPrice.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    taskName.addListener(_updateRequired);
    taskPrice.addListener(_updateRequired);
    description.addListener(_updateRequired);
    assignedToUser = users.where((user) => user['id'] == task['userId']).first;

    taskName.text = task['name'];
    taskPrice.text = task['reward'].toString();
    description.text = task['description'] ?? "";
    print("task emoji: ${task['emoji']}");
    if (task['emoji'] == "") {
      emojiDisplay = null;
    }
    emojiDisplay = task['emoji'];
    deadline = task['deadline'] != null ? DateTime.parse(task['deadline']) : null;
  }

  void changePermanent() {
    setState(() {});
    isPermanent = !isPermanent;
  }

  @override
  Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    onPressed: () async {
                      print(taskName.text);
                      print(taskPrice.text);
                      print(description.text);
                      if (taskName.text.isEmpty) {
                        taskName.text = task['name'];
                      }
                      if (taskPrice.text.isEmpty) {
                        taskPrice.text = task['reward'].toString();
                      }
                      await updateTask(
                          task['id'],
                          taskName.text,
                          description.text,
                          int.parse(taskPrice.text),
                          task['routineId'],
                          assignedToUser['id'] ?? task['userId'],
                          emojiDisplay ?? task['emoji'], deadline);
                      Get.back(result: "Changed Task");
                    },
                    child: Text("Save",
                        style: Theme.of(context).textTheme.labelLarge),
                  )
                ],
              ),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextFormField(
                    controller: taskName,
                    cursorColor: Theme.of(context).colorScheme.onSecondary,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLength: 30,
                  ),
                  IgnorePointer(
                    child: Visibility(
                      visible: taskName.text.isEmpty,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'add task name',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.tertiary,
                                  ),
                            ),
                            TextSpan(
                              text: ' *',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.red.withOpacity(0.5),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
              Text("created by ${task['ownerForename'] ?? task['ownerSurname'] ?? task['ownerUsername'] ?? 'user not found'}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                       EdgeInsets.only(top: 10, bottom: 10, right: paddingRight),
                    child: Icon(CupertinoIcons.add_circled,
                        size: iconSize,
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  Text(
                    'coins:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(" *",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red.withOpacity(0.5),
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: TextField(
                        cursorColor: Theme.of(context).colorScheme.onSecondary,
                        textAlign: TextAlign.end,
                        controller: taskPrice,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            hintText: "add coins",
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
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
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, right: paddingRight),
                    child: Icon(
                      CupertinoIcons.smiley,
                      size: iconSize,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    'icon:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  const KeyboardEmojiPickerWrapper(child: SizedBox.shrink()),
                  TextButton(
                    onPressed: () async {
                      final hasEmojiKeyboard =
                          await KeyboardEmojiPicker().checkHasEmojiKeyboard();
                      if (hasEmojiKeyboard) {
                        final pickedEmoji =
                            await KeyboardEmojiPicker().pickEmoji();
                        setState(() {
                          emojiDisplay = pickedEmoji;
                        });
                      } else {
                        showCupertinoModalPopup(
                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text('Emoji Keyboard Disabled'),
                              content: const Text(
                                  'Please enable the emoji keyboard in your device settings.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(0)),
                    ),
                    child: emojiDisplay == null || emojiDisplay == ""
                        ? Text(
                            "add icon",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontWeight: FontWeight.bold
                            ),
                          )
                        : Text(
                            emojiDisplay ?? 'add icon',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 30,
                            ),
                          ),
                  ),
                  emojiDisplay != null && emojiDisplay != ""
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              emojiDisplay = "";
                            });
                          },
                          icon: Icon(CupertinoIcons.clear,
                              color: Theme.of(context).colorScheme.tertiary),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10, right: paddingRight, bottom: 10),
                        child: Icon(
                          CupertinoIcons.person,
                          size: iconSize,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Text(('assign_to_txt'.tr),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
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
                              height: 300,
                              child: CupertinoPicker(
                                itemExtent:
                                    50, // Increase the item extent to make the items bigger
                                onSelectedItemChanged: (int index) {
                                  print(
                                      'Selected member: ${users[index]['forename'] ?? users[index]['surname'] ?? users[index]['username'] ?? 'user not found'}');
                                  setState(() {
                                    assignedToUser = users[index];
                                    // widget.callback;
                                  });
                                },
                                children: users.map((member) {
                                  return Center(
                                    child: Text(
                                      member['forename'] ?? member ['surname'] ?? member['username'] ?? "user not found",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                          assignedToUser['id'] == null
                              ? 'anyone_txt'.tr
                              : "${assignedToUser['forename'] ?? assignedToUser['surname'] ?? assignedToUser['username'] ?? 'user not found'}",
                          textAlign: TextAlign.end,
                          style: assignedToUser['id'] != null ? Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold) :Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary)
                              )),
                ],
              ),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.calendar,
                      size: iconSize, color: Theme.of(context).colorScheme.tertiary),
                  SizedBox(width: paddingRight),
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
                      style: deadline != null ? Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold)
                          : Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary)
                    ),
                  ),
                  deadline != null
                      ? IconButton(
                          style: ButtonStyle(
                              alignment: Alignment.centerRight,
                              animationDuration: Duration.zero,
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero)),
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
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, right: paddingRight),
                        child: Icon(CupertinoIcons.text_aligncenter,
                            size: iconSize,
                            color: Theme.of(context).colorScheme.tertiary),
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
                              hintText: "add description...",
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
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )))
                ],
              ),
            ],
          ),
        ),
      );
  }
}
