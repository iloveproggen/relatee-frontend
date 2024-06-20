// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_v1/profileV2.dart';

/*
purpose: This file contains the leaderboard view of the app.
author: Maurice
date: 17.05.2024
*/
class MainLeaderboardView extends StatelessWidget {
  const MainLeaderboardView({super.key, required this.users});

  final List<Map<String, dynamic>> users;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> leaderboardusers =
        users.where((user) => user['coins'] != null).toList();
    leaderboardusers
        .sort((a, b) => (b['coins'] ?? 0).compareTo(a['coins'] ?? 0));
    leaderboardusers = leaderboardusers.take(3).toList();
    if (leaderboardusers.length < 3) {
      while (leaderboardusers.length < 3) {
        leaderboardusers.add({});
      }
    }

    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40, top: 80),
          child: Column(
            children: [
              const MembersText(),
              ChartLeaderboard(
                leaderboardusers: leaderboardusers,
              ),
              WeeklyInfo(
                leaderboardusers: leaderboardusers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
purpose: This widget holdas the back method and header.
author: Maurice
date: 17.05.2024
*/

class MembersText extends StatelessWidget {
  const MembersText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          const BackIconRow(),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 60),
            child: Text(
              'Members_txt'.tr,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

/*
purpose: This widget creates the leaderboard chart.
author: Maurice
date: 17.05.2024
*/

class ChartLeaderboard extends StatelessWidget {
  List<Map<String, dynamic>> leaderboardusers;

  //müssen noch ab deb Farben von den themes angepasst werden
  ChartLeaderboard({super.key, required this.leaderboardusers});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final List<Color> colorPrimaryList = leaderboardusers
        .where((user) => user['forename'] != null && user['surname'] != null)
        .map((user) {
      String colorCode = user['colorPrimary'].replaceAll('#', '');
      return Color(int.parse('0xFF$colorCode'));
    }).toList();

    final List<Color> colorSecondaryList = leaderboardusers
        .where((user) => user['forename'] != null && user['surname'] != null)
        .map((user) {
      String colorCode = user['colorSecondary'].replaceAll('#', '');
      return Color(int.parse('0xFF$colorCode'));
    }).toList();

    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: leaderboardusers.asMap().entries.map((entry) {
          final index = leaderboardusers[entry.key]['forename'] != null &&
                  leaderboardusers[entry.key]['surname'] != null
              ? entry.key
              : null;
          final user = entry.value;
          final colorPrimary = index != null && index < colorPrimaryList.length
              ? colorPrimaryList[index]
              : Colors.transparent;
          final colorSecondary =
              index != null && index < colorSecondaryList.length
                  ? colorSecondaryList[index]
                  : Colors.transparent;
          final emoji = user['emoji'];

          return Column(
            children: [
              if (emoji != null && emoji.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 2,
                    bottom: 2,
                  ),
                  child: Container(
                    width: width * 0.2,
                    height: width * 0.2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        colorPrimary,
                        colorSecondary,
                      ]),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: height * 0.05,
              ),
              if (index == 0)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: width * 0.2,
                    height: height * 0.3,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'st',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              if (index == 1)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: width * 0.2,
                    height: height * 0.2,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'nd',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              if (index == 2)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: width * 0.2,
                    height: height * 0.1,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'rd',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/*
purpose: This widget creates the weekly info.
author: Maurice
date: 17.05.2024
*/

class WeeklyInfo extends StatelessWidget {
  List<Map<String, dynamic>> leaderboardusers;

  WeeklyInfo({super.key, required this.leaderboardusers});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    print(leaderboardusers);
    return SizedBox(
      width: width,
      height: height * 0.2,
      child: ListView.builder(
        //dynamisch machen
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
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (leaderboardusers[index]['forename'] != null &&
                      leaderboardusers[index]['coins'] != null &&
                      leaderboardusers[index]['level'] != null)
                    Row(
                      children: [
                        Icon(iconData),
                        const SizedBox(width: 8.0),
                        Text(
                          //'Name ${index + 1}',
                          leaderboardusers[index]['forename'].toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  if (leaderboardusers[index]['coins'] != null)
                    Text(
                      //'$pts pts',
                      leaderboardusers[index]['coins'].toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (leaderboardusers[index]['level'] != null)
                    Row(
                      children: [
                        Icon(CupertinoIcons.checkmark_circle_fill),
                        const SizedBox(width: 8.0),
                        Text(
                          //'$tasks tasks',
                          leaderboardusers[index]['level'].toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
