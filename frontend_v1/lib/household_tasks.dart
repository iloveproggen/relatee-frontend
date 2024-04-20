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
            children: [
              BackIconRow(),
              HouseholdOverview()
            ],
          ),
        )
      )
    );
  }
}

class HouseholdOverview extends StatefulWidget {
  const HouseholdOverview({super.key});

  @override
  State<HouseholdOverview> createState() => _HouseholdTaskState();
}

class _HouseholdTaskState extends State<HouseholdOverview> {
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
        const Task(taskName: "pick up couch", taskStatus: 0)
      ],
    );
  }
}
