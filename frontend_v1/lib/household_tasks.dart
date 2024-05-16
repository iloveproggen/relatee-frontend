import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/leader_board_v2.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

class MainHouseholdOverview extends StatelessWidget {
  const MainHouseholdOverview({super.key, required this.userData});

  final Future<List<Map<String, dynamic>>> userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
      child: Column(
        children: [const BackIconRow(), HouseholdOverview(userData: userData)],
      ),
    )));
  }
}

class HouseholdOverview extends StatelessWidget {
  const HouseholdOverview({super.key, required this.userData});

  final Future<List<Map<String, dynamic>>> userData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${'Household_txt'.tr}Tasks',
                  style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                  onPressed: () {
                    Get.to(() =>
                        const MainLeaderboardView()); //triggert einen error (navigated nicht zum screen)
                  },
                  icon: const Icon(CupertinoIcons.chart_bar_square_fill,
                      size: 40)),
            ],
          ),
        ),
        const ButtonCompleted(
            who: "Marvin", what: "do the dishes", time: "today"),
        const Task(taskName: "pick up couch", taskStatus: 0),
        HouseholdMembers(userData: userData)
      ],
    );
  }
}

class HouseholdMembers extends StatelessWidget {
  const HouseholdMembers({
    super.key,
    required this.userData,
  });

  final Future<List<Map<String, dynamic>>> userData;

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
        Member(
            name: "Marvin Trost", username: "@trostmarvin", userData: userData),
        Member(
            name: "Maurice Halilovic",
            username: "@lugia75",
            userData: userData),
        Member(
            name: "Rene Schomburg", username: "@mrmagnas", userData: userData),
        const SizedBox(height: 50)
      ],
    );
  }
}

class Member extends StatelessWidget {
  const Member(
      {super.key,
      required this.name,
      required this.username,
      required this.userData});

  final String name;
  final String username;
  final Future<List<Map<String, dynamic>>> userData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          Get.to(() => ProfileView(
                userData: userData,
              ));
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
                      color: Color.fromARGB(255, 197, 191, 189),
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
                Text(name,
                    style: const TextStyle(
                      fontFamily: "Karla",
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 74, 70, 70),
                    )),
                Text(username,
                    style: const TextStyle(
                        fontFamily: "Karla",
                        color: Color.fromARGB(255, 204, 198, 196))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyInfo extends StatelessWidget {
  WeeklyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primColor = Theme.of(context).colorScheme.primary;
    final Color secColor = Theme.of(context).colorScheme.secondary;

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height,
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          IconData iconData;
          if (index == 0) {
            iconData = Icons.looks_one;
          } else if (index == 1) {
            iconData = Icons.looks_two;
          } else {
            iconData = Icons.looks_3;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(iconData),
                    const SizedBox(width: 8.0),
                    Text(
                      'Name ${index + 1}',
                      style: TextStyle(color: secColor),
                    ),
                  ],
                ),
                Text(
                  '${index * 10 + 86} pts',
                  style: TextStyle(color: secColor),
                ),
                Row(
                  children: [
                    Icon(CupertinoIcons.checkmark_circle_fill),
                    const SizedBox(width: 8.0),
                    Text(
                      '${index * 4 + 3} tasks',
                      style: TextStyle(color: secColor),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
