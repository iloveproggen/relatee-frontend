import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/household_tasks.dart';
import 'package:frontend_v1/login.dart';
import 'package:frontend_v1/main.dart';
import 'package:get/get.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

String getDueDaysInText(int days) {
  if (days == 1) {
    return 'day_txt'.tr;
  } else {
    return 'days_txt'.tr;
  }
}

updateProfilePicture(userData, newEmoji) {}

late Gravatar gravatar;

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? avatar;
  late Color bgColor;

  @override
  void initState() {
    super.initState();
    avatar = widget.userData['emoji'];
    if (widget.userData['color'] != "#000000") {
      String bgColorString =
          '0xFF' + widget.userData['color'].replaceAll('#', '');
      bgColor = Color(int.parse(bgColorString));
    }
    // Add your initialization code here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.userData['color'] == "#000000") {
      bgColor = Theme.of(context).colorScheme.primary;
    }
  }

  @override
  void dispose() {
    // Add your disposal code here
    super.dispose();
  }

  void openColorPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text("Change Profile color"),
            message: Column(
              children: [
                SizedBox(height:10),
                ColorPicker(
                  paletteType: PaletteType.hsl,
                  labelTypes: [],
                  pickerAreaHeightPercent: 0.35,
                  enableAlpha: false,
                  pickerAreaBorderRadius:
                      const BorderRadius.all(Radius.circular(20)),
                  pickerColor: bgColor,
                  onColorChanged: ((value) {
                    print(value);
                    setState(() {
                      bgColor = value;
                    });
                  }),
                ),
              ],
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  setState(() {
                    String oldColor = '0xFF' + widget.userData['color'].replaceAll('#', '');
                    print(oldColor);
                    if (oldColor == "0xFF000000"){
                      bgColor = Theme.of(context).colorScheme.primary;}
                    else{
                      bgColor = Color(int.parse(oldColor));}
                    Get.back();
                    
                  });
              
                },
                child: const Text('Back', style: TextStyle(color: Colors.red)),
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    gravatar = Gravatar(widget.userData['email']);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BackAndUpdateIcon(userData: widget.userData, avatar: avatar!),
                  const Spacer(),
                  TextButton(
                    child: Icon(CupertinoIcons.paintbrush,
                        size: 30,
                        color: Theme.of(context).colorScheme.tertiary),
                    onPressed: () {
                      openColorPicker();
                    },
                  ),
                  TextButton(
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
                    child: Icon(
                      CupertinoIcons.square_arrow_right,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 30,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const KeyboardEmojiPickerWrapper(child: SizedBox(height: 0)),
                  //Profile Picture
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 200,
                    width: 200,
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //   width: 7,
                    //   color: Theme.of(context).colorScheme.onPrimary,
                    //   strokeAlign: BorderSide.strokeAlignOutside
                    //   ),
                    //   borderRadius: BorderRadius.circular(100),
                    // ),
                    child: TextButton(
                      onPressed: () async {
                        final hasEmojiKeyboard =
                            await KeyboardEmojiPicker().checkHasEmojiKeyboard();
                        if (hasEmojiKeyboard) {
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
                      child: CircleAvatar(
                        backgroundColor: bgColor,
                        radius: 200,
                        child: avatar == null
                            ? Text(
                                "add icon",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 130,
                                ),
                              )
                            : Text(
                                avatar ?? 'add icon',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 130,
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
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDECEC),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/relatee.svg",
                                  height: 20,
                                  width: 20,
                                  color: purple,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${widget.userData['coins']}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF4A4646),
                                    fontSize: 24,
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 27, vertical: 9),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDECEC),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Text(
                              'lvl ${widget.userData['level']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4A4646),
                                fontSize: 24,
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
  const BackIconRow({super.key});

  final double padding = 20;
  final double size = 40;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
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
                Get.back();
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
      {super.key, required this.userData, required this.avatar});

  final double padding = 20;
  final double size = 40;
  final Map<String, dynamic> userData;
  final String avatar;

  @override
  Widget build(BuildContext context) {
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
                if (avatar != userData['emoji']) {
                  await updateProfilePicture(userData['id'], avatar);
                }
                Get.back();
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
          child: Text('Their_Tasks_txt'.tr,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        tasks.isNotEmpty
            ? Column(
                children: tasks
                    .where((task) => task['completed'] == false)
                    .map((task) {
                  return Task(task: task, userData: userData);
                }).toList(),
              )
            : Column(
                children: [
                  Text('User_no_tasks_assigned_txt'.tr,
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
                  Get.to(() => MainHouseholdOverview(pUserData: userData));
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
