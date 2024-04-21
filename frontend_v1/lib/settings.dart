import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

import 'assets/LocaleStrings.dart';

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        translations: LocaleString(),
        locale: const Locale('en-US'),
        fallbackLocale: const Locale('en-US'),
        debugShowCheckedModeBanner: false,
        title: 'Relatee',
        home: Settings());
  }
}

class Settings extends StatelessWidget {
  Settings({super.key});

  final Color colLight = const Color.fromARGB(255, 243, 243, 243);

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return Settings();
      },
    );
  }

  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  final List locale = [
    {'name': 'english', 'locale': Locale('en-US')},
    {'name': 'german', 'locale': Locale('de-DE')}
  ];

  builddialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: Text('Choose_your_language_txt'.tr),
            content: Container(
              width: double.maxFinite,
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            updateLanguage(locale[index]['locale']);
                          },
                          child: Text(locale[index]['name'])),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(color: Colors.blue);
                  },
                  itemCount: locale.length),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 80, left: 40, right: 40),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            BackIconRow(),
            SettingsWidget(),
            ElevatedButton(
                onPressed: () {
                  builddialog(context);
                },
                child: Text('Change_Language_txt'.tr)),
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
