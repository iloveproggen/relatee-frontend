import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold)),
                ],
              )),
        ),
      ],
    );
  }
}

class OneSetting extends StatelessWidget {
  const OneSetting(
      {super.key, required this.settingname, required this.setter});

  final String settingname;
  final Widget setter;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
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
          title: const Text('Select Language'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('German'),
              onPressed: () {
                updateLanguage(const Locale('de-DE'));
                // Add logic for selecting German language
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('English'),
              onPressed: () {
                // Add logic for selecting English language
                Navigator.pop(context);
                updateLanguage(const Locale('en-US'));
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
}

