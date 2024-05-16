import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

class Settings extends StatelessWidget {
  const Settings({super.key, required this.userData});

  final Future<List<Map<String, dynamic>>> userData;

  final Color colLight = const Color.fromARGB(255, 243, 243, 243);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const BackIconRow(),
            const SettingsWidget(),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                          strokeAlign: BorderSide.strokeAlignInside,
                          width: 5,
                          color: Theme.of(context).colorScheme.tertiary),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
              child: TextButton(
                onPressed: () {
                    cupertinoBuildDialog(context);
                  },
                child: Padding(
                    padding: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 15, right: 15),
                    child: Text('Change_Language_txt'.tr, style: const TextStyle(
                                color: Color.fromARGB(255, 74, 70, 70),
                                fontFamily: "Karla",
                                fontSize: 20,)),
                  ),
              ),
            ),
          const SizedBox(height: 20),
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                          strokeAlign: BorderSide.strokeAlignInside,
                          width: 5,
                          color: Theme.of(context).colorScheme.tertiary),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
              child: TextButton(
                onPressed: () {
                    cupertinoModeDialog(context);
                  },
                child: const Padding(
                    padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 15, right: 15),
                    child: Text('Change Mode', style: TextStyle(
                                color: Color.fromARGB(255, 74, 70, 70),
                                fontFamily: "Karla",
                                fontSize: 20,)),
                  ),
              ),
            ),
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
          title: const Text('Select Language', style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('German', style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
              onPressed: () {
                updateLanguage(const Locale('de-DE'));
                // Add logic for selecting German language
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('English', style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
              onPressed: () {
                // Add logic for selecting English language
                Navigator.pop(context);
                updateLanguage(const Locale('en-US'));
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
        title: const Text('Select Mode', style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('Light Mode', style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
            onPressed: () {
              // Add logic for selecting Light Mode
              Get.changeThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Dark Mode', style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
            onPressed: () {
              // Add logic for selecting Dark Mode
              Get.changeThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('System Default', style: TextStyle(color: Color.fromARGB(255, 74, 70, 70))),
            onPressed: () {
              // Add logic for selecting System Default Mode
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