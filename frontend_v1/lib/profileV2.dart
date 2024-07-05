import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/household_tasks.dart' as ht;
import 'package:frontend_v1/login.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/settings.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'household_tasks.dart';

String getDueDaysInText(int days) {
  if (days == 1) {
    return 'day_txt'.tr;
  } else {
    return 'days_txt'.tr;
  }
}

late bool didUserDataChange;

Future<Map<String, dynamic>> updateUserProfile(
    String emoji, String colorPrimary, String colorSecondary) async {
  final Map<String, dynamic> variables = {
    'input': {
      'emoji': emoji,
      'colorPrimary': colorPrimary,
      'colorSecondary': colorSecondary,
    }
  };

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(r'''
  mutation UpdateUserStyle($input: UpdateUserStyleInput!) {
    updateUserStyle(input: $input) {
      emoji
      colorPrimary
      colorSecondary
    }
  }
'''),
    variables: variables,
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    print(result.exception.toString());
    return {};
  } else {
    // Handle the updated user data
    return result.data!['updateUserStyle'];
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? avatar;
  late Color colorPrimary;
  late Color colorSecondary;
  bool useSecondaryColor = false;

//brauchen wir für die Levle
//main usercolor gemischte Farbe -> usercolor
  final List<int> levelList = [
    0,
    200,
    400,
    600,
    800,
    1000,
    1300,
    1600,
    1900,
    2200,
    2400,
    2700,
    3000,
    3400,
    3800,
    4200,
    4600,
    5000,
    5500,
    6000,
    6500,
    7000,
    7600,
    8200,
    8800,
    9400,
    10000,
    11000,
    12000,
    13500,
  ];

  //get correct next level xp
  int getLevelProgress() {
    // Use the null-aware operator `??` to provide a default value if `widget.userData['level']` is null
    int level = widget.userData['level'] ?? 0;
    // Check if `levelList` contains the key before accessing it to prevent a runtime error
    // Provide a default value if the key is not found
    return levelList[level];
  }

  int getPreviousLevelProgress() {
    // Use the null-aware operator `??` to provide a default value if `widget.userData['level']` is null
    int level = widget.userData['level'] - 1 ?? 0;
    // Check if `levelList` contains the key before accessing it to prevent a runtime error
    // Provide a default value if the key is not found
    return levelList[level + 1] - levelList[level];
  }

  //to get the previous level progress
  double getPreviousLevelProgressValue() {
    int experience = widget.userData['experience'] ?? 0;
    // Ensure `getLevelProgress` does not return null or 0 to avoid division by zero error
    int levelProgress = getPreviousLevelProgress();
    if (levelProgress == 0) {
      return 0.0; // Return 0.0 or handle appropriately if level progress is 0 to avoid division by zero
    }
    return ((experience - levelList[widget.userData['level'] - 1]) /
            levelProgress)
        .toDouble();
  }

  double getLevelProgressValue() {
    int experience = widget.userData['experience'] ?? 0;
    // Ensure `getLevelProgress` does not return null or 0 to avoid division by zero error
    int levelProgress = getLevelProgress();
    if (levelProgress == 0) {
      return 0.0; // Return 0.0 or handle appropriately if level progress is 0 to avoid division by zero
    }
    return (experience / levelProgress).toDouble();
  }

  @override
  void initState() {
    super.initState();
    didUserDataChange = false;
    avatar = widget.userData['emoji'];
    colorPrimary = hexToColor(widget.userData['colorPrimary']);
    colorSecondary = hexToColor(widget.userData['colorSecondary']);
  }

  @override
  void dispose() {
    // Add your disposal code here
    super.dispose();
  }

  void openColorPicker() {
    didUserDataChange = true;
    Color oldColorPrimary = colorPrimary;
    Color oldColorSecondary = colorSecondary;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('ChooseProfileColor_txt'.tr),
          actions: [
            CupertinoActionSheetAction(
              child: Text('SaveChanges_txt'.tr,
                  style: TextStyle(color: Colors.blue)),
              onPressed: () {
                setState(() {
                  Get.back();
                });
              },
            ),
            CupertinoActionSheetAction(
              child: Text('DiscardChanges_txt'.tr,
                  style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  didUserDataChange = false;
                  colorPrimary = oldColorPrimary;
                  colorSecondary = oldColorSecondary;
                  Get.back();
                });
              },
            ),
          ],
          message: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 10),
                ColorPicker(
                  paletteType: PaletteType.hsv,
                  labelTypes: const [],
                  pickerAreaHeightPercent: 0.35,
                  enableAlpha: false,
                  pickerAreaBorderRadius:
                      const BorderRadius.all(Radius.circular(20)),
                  pickerColor: colorPrimary,
                  onColorChanged: ((value) {
                    setState(() {
                      colorPrimary = value;
                      if(userColor != Theme.of(context).colorScheme.tertiary){
                        userColor = Color.lerp(colorPrimary, colorSecondary, 0.5)!;
                      }
                    });
                  }),
                ),
                const SizedBox(height: 20),
                ColorPicker(
                  paletteType: PaletteType.hsv,
                  labelTypes: [],
                  pickerAreaHeightPercent: 0.35,
                  enableAlpha: false,
                  pickerAreaBorderRadius:
                      const BorderRadius.all(Radius.circular(15)),
                  pickerColor: colorSecondary, // Changed to colorSecondary
                  onColorChanged: ((value) {
                    print(value);
                    setState(() {
                      colorSecondary = value; // Changed to colorSecondary
                      if(userColor != Theme.of(context).colorScheme.tertiary){
                        userColor = Color.lerp(colorPrimary, colorSecondary, 0.5)!;
                      }
                    });
                  }),
                ),
                // Row(
                //   children: [
                //     TextButton(
                //       onPressed: () {
                //         setState(() {
                //           Get.back();
                //         });
                //       },
                //       child: const Text('Save',
                //           style: TextStyle(color: Colors.blue)),
                //     ),
                //     TextButton(
                //       onPressed: () {
                //         setState(() {
                //           colorPrimary = oldColorPrimary;
                //           colorSecondary = oldColorSecondary;
                //           Get.back();
                //         });
                //       },
                //       child: const Text('Back',
                //           style: TextStyle(color: Colors.red)),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 30;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  BackAndUpdateIcon(
                      avatar: avatar!,
                      colorPrimary: colorPrimary.toString(),
                      colorSecondary: colorSecondary.toString()),
                  const Spacer(),
                  IconButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(0)),
                    ),
                    icon: Icon(CupertinoIcons.sparkles,
                        size: iconSize, color: userColor),
                    onPressed: () {
                      openColorPicker();
                    },
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(0)),
                    ),
                    icon: Icon(CupertinoIcons.gear_solid,
                        size: iconSize, color: userColor),
                    onPressed: () async {
                      Get.to(() => Settings(userData: ht.userData));
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      if (prefs.getBool('useUserColor') == true) {
                        userColor = Color.lerp(
                            hexToColor(ht.userData['colorPrimary']),
                            hexToColor(ht.userData['colorSecondary']),
                            0.5)!;
                      } else {
                        userColor = Theme.of(context).colorScheme.tertiary;
                      }
                    },
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(0)),
                    ),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('Log_out?_txt'.tr),
                            content: Text('Logout_desc_txt'.tr),
                            actions: [
                              CupertinoDialogAction(
                                child: Text(
                                  'Cancel_txt'.tr,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text(
                                  'Continue_txt'.tr,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.remove('token');
                                  Get.offAll(() => const LoginWidget());
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(
                      CupertinoIcons.square_arrow_right,
                      color: Colors.red.withOpacity(0.5),
                      size: iconSize,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const KeyboardEmojiPickerWrapper(child: SizedBox(height: 0)),
                  //Profile Picture
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: TextButton(
                      onPressed: () async {
                        final hasEmojiKeyboard =
                            await KeyboardEmojiPicker().checkHasEmojiKeyboard();
                        if (hasEmojiKeyboard) {
                          didUserDataChange = true;
                          final pickedEmoji =
                              await KeyboardEmojiPicker().pickEmoji();
                          setState(() {
                            avatar = pickedEmoji;
                          });
                        } else {
                          showCupertinoModalPopup(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: Text('Emoji_Disabled_txt'.tr),
                                content: Text('EnableEmojiKeyboard_txt'.tr),
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
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorPrimary, colorSecondary],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Center(
                            child: avatar == null
                                ? Text(
                                    'addIcon_txt'.tr,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 130,
                                    ),
                                  )
                                : Text(
                                    avatar ?? 'addIcon_txt'.tr,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 130,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                        '${widget.userData['forename']} ${widget.userData['surname']}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 10,
                        //dreisatz für das berechnen des values
                        value: widget.userData['level'] <= 1
                            ? getLevelProgressValue()
                            : getPreviousLevelProgressValue(),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        valueColor: AlwaysStoppedAnimation<Color>(userColor),
                      ),
                    ),
                    SizedBox(height: 5),
                    //Text('Progress_txt'.tr(args: {'Experience': '20', 'Total': '100'}),
                    Text(
                        '${'Progress_1_txt'.tr}${widget.userData['experience']} xp ${'Progress_2_txt'.tr}${getLevelProgress()} xp.',
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 20),
                    Text(
                      '@${widget.userData['username']}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: ('part_household'.tr),
                              style: Theme.of(context).textTheme.bodySmall),
                          TextSpan(
                              text: '"${widget.userData['householdName']}"',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(() => MainHouseholdOverview(
                                      pUserData: widget.userData));
                                },
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50, right: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 27, vertical: 9),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.3),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/relatee.svg",
                                  height: 20,
                                  width: 20,
                                  color: userColor,
                                ),
                                const SizedBox(width: 5),
                                Text('${widget.userData['coins']}',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 27, vertical: 9),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.3),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Text('lvl ${widget.userData['level']}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ]),
              // const Divider(
              //     color: Color.fromARGB(238, 126, 126, 126),
              //     height: 100,
              //     thickness: 2),
              const SizedBox(height: 80),
              TaskOverview(userData: widget.userData, tasks: widget.tasks),
            ],
          ),
        ),
      ),
    );
  }
}

class BackIconRow extends StatelessWidget {
  const BackIconRow({super.key, this.getTo, this.updateNeeded});

  final Widget? getTo;
  final bool? updateNeeded;
  final double padding = 20;
  final double size = 40;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
    bool pUpdateNeeded = false;
    if (updateNeeded != null && updateNeeded == true) {
      pUpdateNeeded = true;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: padding),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              onPressed: () async {
                if (getTo != null) {
                  print(getTo ?? "no widget found");
                  Get.offAll(() => getTo!);
                } else {
                  print(pUpdateNeeded);
                  if (pUpdateNeeded) {
                    Get.back(result: true);
                  } else {
                    Get.back();
                  }
                }
              },
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.back,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 18,
                  ),
                  Container(width: 5),
                  // Icon(
                  //   CupertinoIcons.house_fill,
                  //   color: col,
                  //   size: 18,
                  // )
                  Text('back_button_text'.tr,
                      style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackAndUpdateIcon extends StatelessWidget {
  const BackAndUpdateIcon(
      {super.key,
      required this.avatar,
      required this.colorPrimary,
      required this.colorSecondary});

  final double padding = 20;
  final double size = 40;
  final String avatar, colorPrimary, colorSecondary;

  @override
  Widget build(BuildContext context) {
    String formattedColorPrimary =
        '#${colorPrimary.split('(0xff')[1].split(')')[0]}';
    String formattedColorSecondary =
        '#${colorSecondary.split('(0xff')[1].split(')')[0]}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: padding),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              onPressed: () async {
                if (didUserDataChange){
                  print(didUserDataChange);
                  Map<String, dynamic> newUserData = await updateUserProfile(
                    avatar, formattedColorPrimary, formattedColorSecondary);
                  Get.back(result: newUserData);
                }
                else {
                  Get.back();
                }
                
              },
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.back,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 18,
                  ),
                  Container(width: 5),
                  // Icon(
                  //   CupertinoIcons.house_fill,
                  //   color: col,
                  //   size: 18,
                  // )
                  Text('back_button_text'.tr,
                      style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskOverview extends StatelessWidget {
  const TaskOverview({super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  final double size = 15;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: Text("${'Your_txt'.tr} Tasks",
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        tasks.isNotEmpty
            ? Column(
                children: tasks
                    .where((task) => task['completed'] == false)
                    .map((task) {
                  return Task(
                    task: task,
                    userData: userData,
                    isRecommended: false,
                  );
                }).toList(),
              )
            : Column(
                children: [
                  Text('No tasks.'.tr,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  animationDuration: Duration.zero,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  Get.to(() => ht.MainHouseholdOverview(pUserData: userData));
                },
                child: Row(
                  children: [
                    Text('Household_Overview_txt'.tr,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontSize: 18)),
                    const SizedBox(width: 10),
                    Icon(
                      CupertinoIcons.house,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: size,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
