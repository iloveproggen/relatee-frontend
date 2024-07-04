import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool changedColorSetting = false;
bool useUserColor = false;

class Settings extends StatefulWidget {
  const Settings({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    changedColorSetting = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const BackIconRow(getTo: MainWidget()),
            const SettingsWidget(),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
              ),
              child: TextButton(
                onPressed: () {
                  cupertinoBuildDialog(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 15, right: 15),
                  child: Text('Change_Language_txt'.tr,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 74, 70, 70),
                        fontFamily: "Karla",
                        fontSize: 20,
                      )),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
              ),
              child: TextButton(
                onPressed: () {
                  cupertinoModeDialog(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 15, right: 15),
                  child: Text('Change_Mode_txt'.tr,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 74, 70, 70),
                        fontFamily: "Karla",
                        fontSize: 20,
                      )),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  ),
                  icon: Icon(CupertinoIcons.question_circle,
                      color: Theme.of(context).colorScheme.tertiary),
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          title: const Text('What are custom colors?'),
                          content: Column(
                            children: [
                              const Text(
                                  'This setting changes the accent colors of this app to those from your profile picture. If you disable this setting, the app will use the default colors.'),
                              SizedBox(height:10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.bell_fill,
                                      color: userColor, size: 40),
                                  SizedBox(width: 15),
                                  Icon(CupertinoIcons.heart_fill,
                                      color: userColor, size: 40),
                                  SizedBox(width: 15),
                                  Icon(CupertinoIcons.gear_solid,
                                      color: userColor, size: 40),
                                ],
                              )
                            ],
                          ),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('OK',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                Expanded(
                  child: Text(
                    "Use custom colors?",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                FutureBuilder<bool>(
                  future: SharedPreferences.getInstance()
                      .then((prefs) => prefs.getBool('useUserColor') ?? false),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else {
                      bool useUserColor = snapshot.data ?? false;
                      return CupertinoSwitch(
                        trackColor: Theme.of(context).colorScheme.tertiary,
                        thumbColor: Theme.of(context).colorScheme.primary,
                        value: useUserColor,
                        activeColor: Color.lerp(
                            hexToColor(userData['colorPrimary']),
                            hexToColor(userData['colorSecondary']),
                            0.5)!,
                        onChanged: (value) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('useUserColor', value);
                          setState(() {
                            changedColorSetting = true;
                            useUserColor = value;
                            if (value) {
                              userColor = Color.lerp(
                                  hexToColor(userData['colorPrimary']),
                                  hexToColor(userData['colorSecondary']),
                                  0.5)!;
                            } else {
                              userColor =
                                  Theme.of(context).colorScheme.tertiary;
                            }
                          });
                        },
                      );
                    }
                  },
                )
              ],
            ),
            // const SizedBox(height: 20),
            // changedColorSetting
            //     ? Container(
            //         width: double.infinity,
            //         decoration: const BoxDecoration(
            //           borderRadius: BorderRadius.all(Radius.circular(10)),
            //         ),
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.start,
            //           crossAxisAlignment: CrossAxisAlignment.end,
            //           children: [
            //             Row(
            //               children: [
            //                 Text("This is how your Icons will look: ",
            //                     style: Theme.of(context).textTheme.labelSmall),
            //                 IconButton(
            //                   icon:
            //                       Icon(CupertinoIcons.xmark, color: userColor),
            //                   onPressed: () {
            //                     setState(() {
            //                       changedColorSetting = false;
            //                     });
            //                   },
            //                 ),
            //               ],
            //             ),
            //             const SizedBox(height: 10),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Icon(CupertinoIcons.bell_fill,
            //                     color: userColor, size: 40),
            //                 SizedBox(width: 15),
            //                 Icon(CupertinoIcons.heart_fill,
            //                     color: userColor, size: 40),
            //                 SizedBox(width: 15),
            //                 Icon(CupertinoIcons.gear_solid,
            //                     color: userColor, size: 40),
            //               ],
            //             ),
            //           ],
            //         ))
            //     : Container()
          ]),
        ),
      ),
    );
  }
}

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 50, top: 10),
          child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(('settings_txt'.tr),
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              )),
        ),
      ],
    );
  }
}

updateLanguage(Locale locale) {
  Get.back();
  Get.updateLocale(locale);
}

cupertinoBuildDialog(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text('Select Language',
            style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('German',
                style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
            onPressed: () async {
              updateLanguage(const Locale('de-DE'));
              String languageCode = 'de';
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', languageCode);
              Navigator.pop(context);
              print("changed language to German");
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('English',
                style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
            onPressed: () async {
              updateLanguage(const Locale('en-US'));
              String languageCode = 'en';
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', languageCode);
              Navigator.pop(context);
              print("changed language to English");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
      );
    },
  );
}

cupertinoModeDialog(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text('Select Mode',
            style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('Light Mode',
                style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('brightness', 'light');
              Get.changeThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Dark Mode',
                style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('brightness', 'dark');
              Get.changeThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('System Default',
                style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('brightness');
              Get.changeThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
      );
    },
  );
}
