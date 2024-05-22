import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/leader_board_v2.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

/*
purpose: This widget holds the back icon.
author: Michelle
date: 17.05.2024
*/

class MainHouseholdOverview extends StatelessWidget {
  const MainHouseholdOverview({super.key, required this.userData});

  final Map<String, dynamic> userData;

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

/*
purpose: icon for leaderboard + header + "msg of toay".
author: Maurice, Michelle
date: 17.05.2024
*/

class HouseholdOverview extends StatelessWidget {
  const HouseholdOverview({super.key, required this.userData});

  final Map<String, dynamic> userData;

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
                    Get.to(() => const MainLeaderboardView());
                  },
                  icon: const Icon(CupertinoIcons.chart_bar_square_fill,
                      size: 40)),
            ],
          ),
        ),
        const ButtonCompleted(
          who: "Marvin",
          what: "do the dishes",
          time: "today",
        ),
        const Task(taskName: "pick up couch", taskStatus: 0),
        HouseholdMembers(userData: userData)
      ],
    );
  }
}

/*
purpose: Displays all users with a button to their profiles -> linked with profileV2.
author: Michelle
date: 17.05.2024
*/

class HouseholdMembers extends StatelessWidget {
  const HouseholdMembers({
    super.key,
    required this.userData,
  });

  final Map<String, dynamic> userData;

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

/*
purpose: Displays a button with the name of the person who completed the task, the task and the time.
author: Michelle
date: 17.05.2024
*/

class Member extends StatelessWidget {
  const Member(
      {super.key,
      required this.name,
      required this.username,
      required this.userData});

  final String name;
  final String username;
  final Map<String, dynamic> userData;

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
