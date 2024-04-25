import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

class Settings extends StatelessWidget {
  const Settings({super.key, required this.username});

  final String username;

  final Color colLight = const Color.fromARGB(255, 243, 243, 243);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackIconRow(username: username),
                const SettingsWidget(),
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
  const OneSetting({super.key, required this.settingname, required this.setter});

  final String settingname;
  final Widget setter;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}