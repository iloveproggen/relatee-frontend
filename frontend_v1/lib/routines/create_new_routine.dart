import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_v1/tasks/completed_tasks.dart';
import 'package:frontend_v1/tasks/detailed_task_view.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profile/profile_v2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';
import 'package:frontend_v1/core/logging/app_logger.dart';

late Map<String, dynamic> userData;
DateTime? deadline;
DateTime startDate = DateTime.now();
int interval = 1;

int refreshDays() {
  if (deadline != null) {
    final DateTime now = DateTime.now();
    final int difference = deadline!.difference(now).inDays;
    return difference;
  } else {
    return 0;
  }
}

// create routine, wie muss ich daten formatieren?
Future<void> createRoutine(
    String name, String emoji, DateTime refreshDate) async {
  final String formattedStartDate =
      '${startDate.toIso8601String().split('.')[0]}Z';
  final String formattedRefreshDate =
      '${refreshDate.toIso8601String().split('.')[0]}Z';

  final Map<String, dynamic> variables = {
    'input': {
      'name': name,
      'emoji': emoji,
      'interval': interval,
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
      AppLogger.info(result.exception.toString());
    } else if (result.isLoading) {
      AppLogger.info('Loading');
    } else {
      // Handle the result
      AppLogger.info(result.data);
      AppLogger.info("Pushed the new routine to the db: $variables");
    }
  } catch (e) {
    AppLogger.info(e.toString());
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

  String? weekday;
  int? startMonthDay;
  DateTime? yearStartDate;

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
      AppLogger.info("ping");
      interval = int.tryParse(customIntervalAmount.text) ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    customIntervalAmount.addListener(_updateRequired);

    required = false;
    emojiDisplay = null;

    weekday = null;
    startMonthDay = null;
    yearStartDate = null;

    startDate = DateTime.now();
    customIntervalPicker = false;

    userData = widget.pUserData;
    name.addListener(_updateRequired);
    deadline = DateTime.now();
    interval = 1;
    customIntervalPicker = false;
  }

  void startDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
            color: Theme.of(context).colorScheme.primary,
            height: 300,
            child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                    initialItem: DateTime.now().day - 1),
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  setState(() {
                    startDate = DateTime(
                        DateTime.now().year, DateTime.now().month, index + 1);
                    startMonthDay = index + 1;
                  });
                },
                children: List.generate(31, (index) {
                  return Center(
                    child: Text((index + 1).toString(),
                        style: Theme.of(context).textTheme.bodySmall),
                  );
                })));
      },
    );
  }

  void yearlyrefreshDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Theme.of(context).colorScheme.primary,
          height: 300,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            minimumYear: DateTime.now().year,
            maximumYear: DateTime.now().year,
            initialDateTime: DateTime.now(),
            onDateTimeChanged: (DateTime newDateTime) {
              AppLogger.info(newDateTime);
              setState(() {
                startDate = newDateTime;
                yearStartDate = newDateTime;
              });
            },
          ),
        );
      },
    );
  }

  void weekdayPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Theme.of(context).colorScheme.primary,
          height: 300,
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(
                initialItem: DateTime.now().weekday -
                    1), // Set the initial item to the current day
            itemExtent: 50, // Increase the item extent to make the items bigger
            onSelectedItemChanged: (int index) {
              AppLogger.info(index);
              setState(() {
                if (DateTime.now()
                    .add(Duration(days: index - 1))
                    .isAfter(DateTime.now())) {
                  startDate = DateTime.now().add(Duration(days: index - 1));
                } else {
                  startDate = DateTime.now()
                      .add(Duration(days: index - 1))
                      .add(const Duration(days: 7));
                }
                //startDate = DateTime.now().add(Duration(days: index-1));
                weekday = getWeekdayFromInt(index);
              });
              AppLogger.info(startDate);
            },
            children: [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday'
            ]
                .map(
                  (String item) => Center(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
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
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(0),
                      ),
                    ),
                    onPressed: () async {
                      if (required) {
                        await createRoutine(name.text, emojiDisplay ?? "",
                            startDate.add(Duration(days: interval)));
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
                      padding: WidgetStateProperty.all<EdgeInsets>(
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
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
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
                                      startDate = DateTime.now();
                                      interval = 1;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = false;
                                    });
                                    AppLogger.info('daily');
                                    break;
                                  case 1:
                                    setState(() {
                                      startDate = DateTime.now();
                                      interval = 7;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = false;
                                    });
                                    AppLogger.info('weekly');
                                    break;
                                  case 2:
                                    setState(() {
                                      startDate = DateTime.now();
                                      interval = 14;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = false;
                                    });
                                    AppLogger.info('bi-weekly');
                                    break;
                                  case 3:
                                    setState(() {
                                      startDate = DateTime.now();
                                      interval = 31;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = false;
                                    });
                                    AppLogger.info('monthly');
                                    break;
                                  case 4:
                                    setState(() {
                                      startDate = DateTime.now();
                                      interval = 365;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = false;
                                    });
                                    AppLogger.info('yearly');
                                    break;
                                  default:
                                    setState(() {
                                      startDate = DateTime.now();
                                      interval = 0;
                                      customIntervalAmount.text = '';
                                      customIntervalPicker = true;
                                    });
                                    AppLogger.info('custom');
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
                            cursorColor:
                                Theme.of(context).colorScheme.onSecondary,
                            decoration: InputDecoration(
                              hintText: 'add interval...',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                            ),
                            textAlign: TextAlign
                                .right, // Add this line to align the text to the right
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              interval == 31 ||
                      interval == 7 ||
                      interval == 14 ||
                      interval == 365
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.clock,
                            size: iconSize,
                            color: Theme.of(context).colorScheme.tertiary),
                        SizedBox(width: paddingRight),
                        Text('start date:',
                            style: Theme.of(context).textTheme.bodySmall),
                        const Spacer(),
                        TextButton(
                          style: ButtonStyle(
                            alignment: Alignment.centerRight,
                            padding: WidgetStateProperty.all(EdgeInsets.zero),
                          ),
                          onPressed: () {
                            if (interval == 31) {
                              startDatePicker(context);
                            } else if (interval == 7 || interval == 14) {
                              weekdayPicker(context);
                            } else if (interval == 365) {
                              yearlyrefreshDatePicker(context);
                            } else {
                              Container();
                            }
                          },
                          child: Text(
                            interval == 7 || interval == 14
                                ? weekday ??
                                    getWeekdayFromInt(startDate.weekday)
                                : interval == 365
                                    ? "${startDate.day}-${startDate.month}-${startDate.year}"
                                    : startMonthDay?.toString() ??
                                        startDate.day.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              const SizedBox(height: 20),

              // switch (interval) {
              //   1 => Text("pick daily start day"),
              //   7 => Text("pick weekly start day"),
              //   14 => Text("pick bi-weekly start day"),
              //   31 => Text("pick monthly start day"),
              //   365 => Text("pick yearly start day"),
              //   _ => Text("normal date picker"),
              // },

              const SizedBox(height: 30),
              _buildRefreshText(context),
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
              //           AppLogger.info(newDateTime);
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

Widget _buildRefreshText(BuildContext context) {
  if (interval <= 0) {
    return Container();
  } else if (interval == 1) {
    return Text(
      'RoutineRefresh_txt'.tr,
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
    );
  } else {
    //String languageCode = Localizations.localeOf(context).languageCode;
    String languageCode = Get.locale!.languageCode;
    AppLogger.info(languageCode);
    return Column(
      children: [
        Text(
          languageCode == 'de-DE'
              ? 'The Routine start on ${getWeekdayFromInt(startDate.weekday)}, the ${startDate.day}${ordinal(startDate.day)} of ${getMonthFromInt(startDate.month)} ${startDate.year.toString().substring(2)}. ${'RoutineRefreshVar_txt'.tr}$interval${'RoutineRefreshVarGermanAdd_txt'.tr}' // German translation
              : 'The Routine will start on ${getWeekdayFromInt(startDate.weekday)}, the ${startDate.day}${ordinal(startDate.day)} of ${getMonthFromInt(startDate.month)} ${startDate.year.toString().substring(2)}. ${'It will refresh every '}$interval ${'days_txt'.tr}', // English translation
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

String getWeekdayFromInt(int weekday) {
  switch (weekday) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return 'Monday';
  }
}

String getMonthFromInt(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return 'January';
  }
}

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
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
