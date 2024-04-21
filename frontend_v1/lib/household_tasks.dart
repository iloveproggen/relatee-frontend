import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/assets/LocaleStrings.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: LocaleString(),
      locale: const Locale('en-US'),
      fallbackLocale: const Locale('en-US'),
      home: const MainHouseholdOverview(),
    );
  }
}

class MainHouseholdOverview extends StatelessWidget {
  const MainHouseholdOverview({super.key});

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return const MainHouseholdOverview();
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
        children: [BackIconRow(), HouseholdOverview()],
      ),
    )));
  }
}

class HouseholdOverview extends StatelessWidget {
  const HouseholdOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text('${'Household_txt'.tr}Tasks',
              style: Theme.of(context).textTheme.bodyLarge),
        ),
        const ButtonCompleted(
            who: "Marvin", what: "do the dishes", time: "today"),
        const Task(taskName: "pick up couch", taskStatus: 0),
        const HouseholdMembers()
      ],
    );
  }
}

class HouseholdMembers extends StatelessWidget {
  const HouseholdMembers({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('HouseholdMembers_txt'.tr,
              style: Theme.of(context).textTheme.bodyLarge),
        ),
        const Member(name: "Marvin Trost", user: "@trostmarvin"),
        const Member(name: "Maurice Halilovic", user: "@lugia75"),
        const Member(name: "Rene Schomburg", user: "@mrmagnas"),
        const SizedBox(height:50)
      ],
    );
  }
}

class Member extends StatelessWidget {
  const Member({super.key, required this.name, required this.user});

  final String name;
  final String user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:15),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(ProfileView.route());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: const ShapeDecoration(
                  shape: CircleBorder(
                    side: BorderSide(
                      width: 4,
                      color: Color.fromARGB(255, 114, 111, 110),
                    ),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                        "https://fakeimg.pl/70x70/f7f7f7/9c9390?font=bebas"),
                    fit: BoxFit.fill,
                  )),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(
                  fontFamily: "Karla",
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 74, 70, 70),
                )),
                Text(
                  user,
                  style: const TextStyle(
                    fontFamily: "Karla",
                    color: Color.fromARGB(255, 204, 198, 196)
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
