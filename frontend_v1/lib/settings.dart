import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

class Settings extends StatelessWidget {
  const Settings({super.key, required this.username});

  final String username;
  @override
  Widget build(BuildContext context) {

  //final Color primColor = Theme.of(context).colorScheme.primary;
  //const Color.fromARGB(255, 243, 243, 243); g
  //test
  final Color textColor = Theme.of(context).colorScheme.secondary;


    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
              child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
             BackIconRow(username: username),
             SettingsWidget(),
             ElevatedButton(
                 onPressed: () {
                   builddialog(context);
                 },
                 child: Text('Change_Language_txt'.tr,
                 style: TextStyle(
                  color: textColor
                 ),)),
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

  final Color textColor = Theme.of(context).colorScheme.secondary;

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
                      style: TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold,
                          color: textColor)),
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

updateLanguage(Locale locale) {
     Get.back();
     Get.updateLocale(locale);
   }

   final List locale = [
     {'name': 'english', 'locale': Locale('en-US')},
     {'name': 'german', 'locale': Locale('de-DE')}
   ];

   builddialog(BuildContext context) {

  final Color textColor = Theme.of(context).colorScheme.secondary;
  final Color primColor = Theme.of(context).colorScheme.primary;


     showDialog(
         context: context,
         builder: (builder) {
           return AlertDialog(
            backgroundColor: primColor,
             title: Text('Choose_your_language_txt'.tr,
            style: TextStyle(color: textColor),),
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
                           child: Text(locale[index]['name'],
                           style: TextStyle(color: textColor),)),
                     );
                   },
                   separatorBuilder: (context, index) {
                     return Divider(color: textColor);
                   },
                   itemCount: locale.length),
             ),
           );
         });
   }