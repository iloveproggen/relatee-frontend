import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend_v1/detailed_task_view.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

late Map<String, dynamic> userData;
DateTime? deadline;

int refreshDays() {
  if (deadline != null) {
    final DateTime now = DateTime.now();
    final int difference = deadline!.difference(now).inDays;
    return difference;
  } else {
    return 0;
  }
}

Future<void> createRoutine(
    String name, String emoji, DateTime refreshDate) async {
  // Format DateTime to a string that your backend can understand
  final String formattedRefreshDate =
      '${refreshDate.toIso8601String().split('.')[0]}Z';
  final String formattedStartDate =
      '${DateTime.now().toIso8601String().split('.')[0]}Z'; // Correctly formatting startDate

  final Map<String, dynamic> variables = {
    'input': {
      'name': name,
      'emoji': emoji,
      'refreshDate': formattedRefreshDate,
      'startDate': formattedStartDate, // Correctly formatted startDate
      'private': false,
    }
  };

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(r'''
mutation CreateRoutine($input: CreateRoutineInput!) {
  createRoutine(input: $input) {
    name
    emoji
    refreshDate
    startDate
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
      print("Pushed the new routine to the db: $variables");
    }
  } catch (e) {
    print(e.toString());
  }
}

class NewRoutine extends StatefulWidget {
  const NewRoutine({super.key, required this.pUserData});

  final Map<String, dynamic> pUserData;

  @override
  State<NewRoutine> createState() => _NewRoutine();
}

class _NewRoutine extends State<NewRoutine> {
  _NewRoutine();

  TextEditingController name = TextEditingController();
  TextEditingController customIntervalAmount = TextEditingController();

  bool required = false;
  String? emojiDisplay;
  late int interval;
  DateTime startDate = DateTime.now();
  bool customIntervalPicker = false;

  void _updateRequired() {
    setState(() {
      required = _checkInputs(); // Update required based on inputs
    });
  }

  bool _checkInputs() {
    return name.text.isNotEmpty && deadline != null;
  }

  void setCustomInterval() {
    setState(() {
      print("ping");
      interval = int.tryParse(customIntervalAmount.text) ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    customIntervalAmount.addListener(_updateRequired);

    userData = widget.pUserData;
    emojiDisplay = null;
    name.addListener(_updateRequired);
    deadline = DateTime.now();
    interval = 1;
    customIntervalPicker = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackIconRow(),
                  TextButton(
                    style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      animationDuration: Duration.zero,
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(0),
                      ),
                    ),
                    onPressed: () async {
                      if (required) {
                        await createRoutine(
                            name.text, emojiDisplay ?? "", DateTime.now());
                        Get.back(result: 'Task_created_txt'.tr);
                      } else {
                        Get.back();
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
              Align(
                alignment: Alignment.topLeft,
                child: Form(
                  child: Column(
                    children: [
                      TextField(
                          cursorColor:
                              Theme.of(context).colorScheme.onSecondary,
                          controller: name,
                          maxLength: 30,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            hintText: 'AddRoutineName_txt'.tr,
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color:
                                      const Color.fromARGB(255, 204, 198, 196),
                                ),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
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
                    'Icon:',
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
                            'addIcon_txt'.tr,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 20,
                            ),
                          )
                        : Text(
                            emojiDisplay ?? 'aaddIcon_txt'.tr,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 40,
                            ),
                          ),
                  ),
                  emojiDisplay != null
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              emojiDisplay = null;
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
                children: [
                  Icon(CupertinoIcons.calendar,
                      size: iconSize,
                      color: Theme.of(context).colorScheme.tertiary),
                  SizedBox(width: paddingRight),
                  Text('repeats_txt'.tr,
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
                            color: Theme.of(context).colorScheme.primary,
                            height: 300,
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                  initialItem: _getScrollController(
                                      interval)), // Set the initial item to 0
                              itemExtent:
                                  50, // Increase the item extent to make the items bigger
                              onSelectedItemChanged: (int index) {
                                switch (index) {
                                  case 0:
                                    setState(() {
                                      interval = 1;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = false;
                                    });
                                    print('daily');
                                    break;
                                  case 1:
                                    setState(() {
                                      interval = 7;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = false;
                                    });
                                    print('weekly');
                                    break;
                                  case 2:
                                    setState(() {
                                      interval = 14;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = false;
                                    });
                                    print('bi-weekly');
                                    break;
                                  case 3:
                                    setState(() {
                                      interval = 31;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = false;
                                    });
                                    print('monthly');
                                    break;
                                  case 4:
                                    setState(() {
                                      interval = 365;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = false;
                                    });
                                    print('yearly');
                                    break;
                                  default:
                                    setState(() {
                                      interval = 0;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = true;
                                    });
                                    print('custom');
                                    break;
                                }
                              },
                              children: [
                                "daily",
                                "weekly",
                                "bi-weekly",
                                "monthly",
                                "yearly",
                                "custom..."
                              ]
                                  .map(
                                    (String item) => Center(
                                      child: Text(
                                        item,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      _getIntervalStatement(interval),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              customIntervalPicker
                  ? Row(
                        children: [
                          Expanded(
                          child: TextField(
                        onChanged: (value) {
                          setCustomInterval();
                        },
                            controller: customIntervalAmount,
                            inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                            ],
                            cursorColor: Theme.of(context).colorScheme.onSecondary,
                            decoration: InputDecoration(
                            hintText: 'add interval...',
                            hintStyle: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                  .colorScheme
                                  .tertiary, fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                            ),
                            textAlign: TextAlign.right, // Add this line to align the text to the right
                            style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          ),
                      ],
                    )
                  : Container(),
                  SizedBox(height:10),
                  switch (interval) {
                    1 =>
                      Text("pick daily start day"),
                    7 =>
                      Text("pick weekly start day"),
                    14 =>
                      Text("pick bi-weekly start day"),
                    31 =>
                      Text("pick monthly start day"),
                    365 =>
                      Text("pick yearly start day"),
                    _ =>
                      Text("normal date picker"),
                  },
              
              SizedBox(height:30),
              _buildRefreshText(context, interval),
              // showCupertinoModalPopup(
              //   context: context,
              //   builder: (BuildContext context) {
              //     return Container(
              //       color: Theme.of(context).colorScheme.primary,
              //       height: 400,
              //       child: CupertinoDatePicker(
              //         mode: CupertinoDatePickerMode.date,
              //         initialDateTime:
              //             now, // Use the same 'now' DateTime object
              //         minimumDate:
              //             now, // Use the same 'now' DateTime object
              //         maximumYear: now.year + 1,
              //         minimumYear: now.year,
              //         onDateTimeChanged: (DateTime newDateTime) {
              //           print(newDateTime);
              //           setState(() {
              //             deadline = newDateTime;
              //           });
              //         },
              //       ),
              //     );
              //   },
              // );
            ],
          ),
        ),
      ),
    );
  }
}

String _getIntervalStatement(int interval) {
  switch (interval) {
    case 1:
      return 'Daily';
    case 7:
      return 'Weekly';
    case 14:
      return 'Bi-weekly';
    case 31:
      return 'Monthly';
    case 365:
      return 'Yearly';
    default:
      return 'Custom';
  }
}

int _getScrollController(int interval) {
  switch (interval) {
    case 1:
      return 0;
    case 7:
      return 1;
    case 14:
      return 2;
    case 31:
      return 3;
    case 365:
      return 4;
    default:
      return 5;
  }
}

Widget _buildRefreshText(BuildContext context, int days) {
  if (days <= 0 ) {
    return Container(); // Assuming you want to return an empty Container for case 0
  } else if (days == 1) {
    return Text(
      'RoutineRefresh_txt'.tr,
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
    );
  } else {
    //String languageCode = Localizations.localeOf(context).languageCode;
    String languageCode = Get.locale!.languageCode;
    print(languageCode);
    return Text(
      languageCode == 'de-DE'
          ? '${'RoutineRefreshVar_txt'.tr}$days${'RoutineRefreshVarGermanAdd_txt'.tr}' // German translation
          : '${'RoutineRefreshVar_txt'.tr}$days ${'days_txt'.tr}', // English translation
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
    );
  }
}

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
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
        padding: const EdgeInsets.only(top: 40),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: const Color(0x7FD9D9D9),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedAlign(
                alignment:
                    _isPermanent ? Alignment.centerLeft : Alignment.centerRight,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'permanent_txt'.tr,
                    style: TextStyle(
                      color:
                          _isPermanent ? Colors.black : const Color(0xFF4A4646),
                      fontSize: 20,
                      fontFamily: 'Karla',
                      fontWeight:
                          _isPermanent ? FontWeight.w700 : FontWeight.w300,
                      height: 0,
                    ),
                  ),
                  Text(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
