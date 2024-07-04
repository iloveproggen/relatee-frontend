// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/main.dart';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackIconRow(),
              Row(
                children: [
                  Text(
                    'Members_txt'.tr,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(width: 160.0),
                  TextButton(
                    style: ButtonStyle(
                        alignment: Alignment.centerRight,
                        animationDuration: Duration.zero,
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(0),
                        )),
                    child: Icon(CupertinoIcons.arrow_up_arrow_down,
                        color: userColor, size: 25),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 30),
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
purpose: This widget creates the leaderboard chart.
author: Maurice
date: 17.05.2024
*/

// ignore: must_be_immutable
class ChartLeaderboard extends StatelessWidget {
  List<Map<String, dynamic>> leaderboardusers;

  //müssen noch ab deb Farben von den themes angepasst werden
  ChartLeaderboard({super.key, required this.leaderboardusers});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final List<Color> colorPrimaryList =
        leaderboardusers.where((user) => user['username'] != null).map((user) {
      String colorCode = user['colorPrimary'].replaceAll('#', '');
      return Color(int.parse('0xFF$colorCode'));
    }).toList();

    final List<Color> colorSecondaryList =
        leaderboardusers.where((user) => user['username'] != null).map((user) {
      String colorCode = user['colorSecondary'].replaceAll('#', '');
      return Color(int.parse('0xFF$colorCode'));
    }).toList();

    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: leaderboardusers.asMap().entries.map((entry) {
          final index = leaderboardusers[entry.key]['username'] != null
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
                        child: DefaultTextStyle(
                          style: TextStyle(fontSize: 60),
                          child: Text(
                            emoji.toString(),
                          ),
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
                      gradient: LinearGradient(
                          colors: [colorPrimary, colorSecondary]),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Padding(padding: EdgeInsets.all(15.0)),
                  ),
                ),
              if (index == 1)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: width * 0.2,
                    height: height * 0.2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorPrimary,
                          colorSecondary,
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
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
                      gradient: LinearGradient(
                          colors: [colorPrimary, colorSecondary]),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
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

// ignore: must_be_immutable
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
                children: [
                  if (leaderboardusers[index]['coins'] != null &&
                      leaderboardusers[index]['level'] != null)
                    Row(
                      children: [
                        Icon(iconData),
                        const SizedBox(width: 8.0),
                        Container(
                          width: 100,
                          child: Text(
                            //'Name ${index + 1}',
                            leaderboardusers[index]['forename'] ??
                                leaderboardusers[index]['surname'] ??
                                leaderboardusers[index]['username'],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(width: 20),
                  if (leaderboardusers[index]['coins'] != null)
                    Container(
                      width: 50,
                      child: Text(
                        //'$pts pts',
                        leaderboardusers[index]['coins'].toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  //SizedBox(width: 5),
                  SvgPicture.asset(
                    "assets/images/relatee.svg",
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      userColor ??
                          Colors
                              .transparent, // Provide a default color if _colorAnimation.value is null
                      BlendMode.srcIn,
                    ),
                  ),
                  Spacer(),
                  if (leaderboardusers[index]['level'] != null)
                    Row(
                      children: [
                        //const Icon(CupertinoIcons.checkmark_circle_fill),
                        //const SizedBox(width: 8.0),
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
