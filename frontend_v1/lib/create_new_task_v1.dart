import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';

double paddingRight = 10;
double iconSize = 30;

class MaxLengthNumberInputFormatter extends TextInputFormatter {
  final int maxDigits;

  MaxLengthNumberInputFormatter(this.maxDigits);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > maxDigits) {
      return oldValue;
    }
    return newValue;
  }
}

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

Map<String, dynamic> assignedToUser = nullUser;

DateTime? deadline;

String? deadlineString;

bool isPermanent = false;

Future<void> createNewTask(
    int? userId,
    String name,
    String description,
    int reward,
    int? routineId,
    String emoji,
    Map<String, dynamic> userData) async {
  String? deadlineString;
  if (deadline == null) {
    deadlineString = null;
  } else {
    deadlineString = '${deadline?.toIso8601String().split('.')[0]}Z';
  }
  final Map<String, dynamic> variables = {
    'input': {
      'userId': userId,
      'name': name.trim(),
      'deadline': deadlineString,
      'description': description,
      'reward': reward,
      'routineId': routineId,
      'emoji': emoji,
    }
  };

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(r'''
mutation CreateTask($input: CreateTaskInput!) {
  createTask(input: $input) {
    user {
      id
    }
    name
    deadline
    description
    reward
    routine {
      id
    }
    emoji
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

class NewTaskMain extends StatelessWidget {
  const NewTaskMain({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: NewTaskFuture(userData: userData));
  }
}

class NewTaskFuture extends StatelessWidget {
  const NewTaskFuture({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getHouseholdData(context),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          print(snapshot.data);
          List<Map<String, dynamic>> householdUsers = [];
          householdUsers.add(nullUser);
          householdUsers
              .addAll(List<Map<String, dynamic>>.from(snapshot.data!['users']));
          List<Map<String, dynamic>> routines = [];
          routines.add(nullRoutine);
          // routines.addAll(
          //     List<Map<String, dynamic>>.from(snapshot.data!['routines']));
          return NewTask(
              userData: userData,
              householdUsers: householdUsers,
              routines: routines);
        }
      },
    );
  }
}

class NewTask extends StatefulWidget {
  const NewTask(
      {super.key,
      required this.userData,
      required this.householdUsers,
      required this.routines});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> householdUsers;
  final List<Map<String, dynamic>> routines;

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  bool required = false;

  TextEditingController taskName = TextEditingController();
  TextEditingController taskPrice = TextEditingController();
  TextEditingController description = TextEditingController();

  String? emojiDisplay;
  bool useTime = true;

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
    emojiDisplay = null;
    // Add listener to text controllers to update required variable
    taskName.addListener(_updateRequired);
    taskPrice.addListener(_updateRequired);
    description.addListener(_updateRequired);

    assignedToUser = widget.householdUsers[0];
    pickedRoutine = widget.routines[0];
    deadline = null;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackIconRow(),
                  TextButton(
                    style: ButtonStyle(
                        alignment: Alignment.centerRight,
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                        animationDuration: Duration.zero),
                    onPressed: () async {
                      if (required) {
                        print(taskName.text);
                        print(taskPrice.text);
                        print(assignedToUser);
                        print(description.text);
                        await createNewTask(
                            assignedToUser['id'],
                            taskName.text,
                            description.text,
                            int.parse(taskPrice.text),
                            pickedRoutine['id'],
                            emojiDisplay ?? '',
                            widget.userData);
                        Get.back(result: "Task created");
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text('Confirmation_txt'.tr),
                              content: Text('CancelPopUp_txt'.tr),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text('No_txt'.tr,
                                      style: TextStyle(color: Colors.blue)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text('Yes_txt'.tr,
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Get.back();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text(required ? 'Confirm_txt'.tr : 'Cancel_txt'.tr,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: required
                                ? Theme.of(context).colorScheme.onSecondary
                                : const Color.fromARGB(255, 204, 198, 196))),
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
                              text: ('AddTaskName_txt'.tr),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                            ),
                            TextSpan(
                              text: ' *',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
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
              //const SliderWidgetWho(),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, right: paddingRight),
                    child: Icon(
                      CupertinoIcons.add_circled,
                      size: iconSize,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    'reward_txt'.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(" *",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.red.withOpacity(0.8))),
                  Expanded(
                      child: TextField(
                    cursorColor: Theme.of(context).colorScheme.onSecondary,
                    textAlign: TextAlign.end,
                    controller: taskPrice,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      MaxLengthNumberInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      hintText: 'add_reward_txt'.tr,
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.tertiary),
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  )),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, right: paddingRight),
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
                    child: emojiDisplay == null
                        ? Text(
                            "addIcon_txt".tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
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
                  emojiDisplay != null
                      ? TextButton(
                          style: ButtonStyle(
                              animationDuration: Duration.zero,
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero)),
                          onPressed: () {
                            setState(() {
                              emojiDisplay = null;
                            });
                          },
                          child: Icon(CupertinoIcons.clear,
                              color: Theme.of(context).colorScheme.tertiary),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              AssignTo(
                userData: widget.userData,
                callback: _updateRequired,
                householdUsers: widget.householdUsers,
              ),
              RoutinePicker(
                  callback: _updateRequired, routines: widget.routines),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.calendar,
                      size: iconSize,
                      color: Theme.of(context).colorScheme.tertiary),
                  SizedBox(width: paddingRight),
                  Text('deadline_txt'.tr,
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
                              mode: useTime
                                  ? CupertinoDatePickerMode.dateAndTime
                                  : CupertinoDatePickerMode.date,
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
                            : 'none_txt'.tr,
                        style: deadline != null
                            ? Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold)
                            : Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary)),
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
              Row(
                children: [
                  Icon(CupertinoIcons.clock,
                      size: iconSize,
                      color: Theme.of(context).colorScheme.tertiary),
                  SizedBox(width: paddingRight),
                  Text("Use time?",
                      style: Theme.of(context).textTheme.bodySmall),
                  Spacer(),
                  IconButton(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.zero,
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent), // Removes ripple effect
                    ),
                    icon: Icon(useTime ? CupertinoIcons.checkmark : CupertinoIcons.xmark, size: 20),
                    onPressed: () {
                      setState(() {
                        useTime = !useTime;
                      });
                    },
                  )
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
                        child: Icon(
                          CupertinoIcons.text_aligncenter,
                          size: iconSize,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Expanded(
                          child: Text(
                        'description_txt'.tr,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodySmall,
                      )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextField(
                      cursorColor: Theme.of(context).colorScheme.onSecondary,
                      maxLines: 4,
                      keyboardType:
                          TextInputType.visiblePassword, // Add this line

                      controller: description,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          counterText: "",
                          hintText: 'add_description_txt'.tr,
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
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLength: 100,
                    ),
                  )
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

class RoutinePicker extends StatefulWidget {
  const RoutinePicker(
      {super.key, required this.callback, required this.routines});

  final VoidCallback callback;
  final List<Map<String, dynamic>> routines;

  @override
  State<RoutinePicker> createState() => _RoutinePickerState();
}

class _RoutinePickerState extends State<RoutinePicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: 10, right: paddingRight, bottom: 10),
              child: Icon(
                CupertinoIcons.archivebox,
                size: iconSize,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            Text(('routine:'.tr), style: Theme.of(context).textTheme.bodySmall),
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
                      scrollController:
                          FixedExtentScrollController(initialItem: 0),

                      itemExtent:
                          50, // Increase the item extent to make the items bigger
                      onSelectedItemChanged: (int index) {
                        print(
                            'Selected routine: ${widget.routines[index]['name'] ?? ''}');
                        setState(() {
                          pickedRoutine = widget.routines[index];
                          widget.callback;
                        });
                      },
                      children: widget.routines.map((routine) {
                        return Center(
                          child: Text(
                            routine['name'],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
            child: Text(
                pickedRoutine['name'] == null
                    ? 'none_txt'.tr
                    : "${pickedRoutine['name']}",
                textAlign: TextAlign.end,
                style: pickedRoutine['name'] == null
                    ? Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold)
                    : Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary))),
      ],
    );
  }
}

class AssignTo extends StatefulWidget {
  const AssignTo(
      {super.key,
      required this.userData,
      required this.callback,
      required this.householdUsers});

  final Map<String, dynamic> userData;
  final VoidCallback callback;
  final List<Map<String, dynamic>> householdUsers;

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
            Padding(
              padding:
                  EdgeInsets.only(top: 10, right: paddingRight, bottom: 10),
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
              padding: WidgetStateProperty.all(EdgeInsets.zero),
            ),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    color: Theme.of(context).colorScheme.background,
                    height: 300,
                    child: CupertinoPicker(
                      scrollController:
                          FixedExtentScrollController(initialItem: 0),

                      itemExtent:
                          50, // Increase the item extent to make the items bigger
                      onSelectedItemChanged: (int index) {
                        print(
                            'Selected member: ${widget.householdUsers[index]['forename'] ?? ''}');
                        setState(() {
                          assignedToUser = widget.householdUsers[index];
                          widget.callback;
                        });
                      },
                      children: widget.householdUsers.map((member) {
                        return Center(
                          child: Text(
                            member['forename'] ??
                                member['surname'] ??
                                member['username'] ??
                                "user not found",
                            style: Theme.of(context).textTheme.bodySmall,
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
                    : "${assignedToUser['forename'] ?? assignedToUser['surname'] ?? assignedToUser['username']}",
                textAlign: TextAlign.end,
                style: assignedToUser['id'] != null
                    ? Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold)
                    : Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary))),
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
