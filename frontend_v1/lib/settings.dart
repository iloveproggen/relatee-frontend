import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

import 'assets/LocaleStrings.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        translations: LocaleString(),
        locale: const Locale('en-US'),
        fallbackLocale: const Locale('en-US'),
        debugShowCheckedModeBanner: false,
        title: 'Relatee',
        home: const Settings());
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  final Color colLight = const Color.fromARGB(255, 243, 243, 243);

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return const Settings();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackIconRow(),
                Icon(
                  CupertinoIcons.add,
                ),
                SettingsWidget(),
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
                  Text('${'welcome_title'.tr} Michelle!',
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold)),
                  Text('welcome_message'.tr,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              )),
        ),
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Recommended_txt'.tr,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 204, 198, 196),
                      fontSize: 20,
                      fontFamily: "Karla")),
            )),
      ],
    );
  }
}
