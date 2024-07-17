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

late List<Map<String, dynamic>> leaderboardusers;
late List<Map<String, dynamic>> leaderboardtasks;

class MainLeaderboardView extends StatefulWidget {
  const MainLeaderboardView(
      {super.key, required this.users, required this.tasks});

  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> users;

  @override
  State<MainLeaderboardView> createState() => _MainLeaderboardViewState();
}

class _MainLeaderboardViewState extends State<MainLeaderboardView> {
  String sortBy = "coins";

  void _refreshView(String newFilterBy) {
    sortBy = newFilterBy;
  }

  void resort(List<Map<String, dynamic>> list) {
    list.sort((a, b) {
      if (a[sortBy] == null && b[sortBy] == null) {
        return 0;
      } else if (a[sortBy] == null) {
        return 1;
      } else if (b[sortBy] == null) {
        return -1;
      } else {
        return b[sortBy].compareTo(a[sortBy]);
      }
    });
  }

  void _changeSort(String newSortBy) {
    setState(() {
      sortBy = newSortBy;
      resort(leaderboardusers);
    });
  }

  void _reverseView() {
    setState(() {
      leaderboardusers = leaderboardusers.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    leaderboardtasks =
        widget.tasks.where((task) => task['completed'] == true).toList();
    // print('Here sind die tasks (liste)');
    // print(leaderboardtasks);

    leaderboardusers =
        widget.users.where((user) => user['coins'] != null).toList();
    resort(leaderboardusers); // Sort the list here
    leaderboardusers = leaderboardusers.toList();
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
                  Spacer(),
                  TextButton(
                    style: ButtonStyle(
                        alignment: Alignment.centerLeft,
                        animationDuration: Duration.zero,
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(0),
                        )),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: userColor, width: 1.5),
                          borderRadius: BorderRadius.circular(100)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 10),
                        child: Text('Sort',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: userColor)),
                      ),
                    ),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoActionSheet(
                            title: const Text('Sort leaderboard by...'),
                            actions: [
                              for (var sortOption in [
                                'Coins (default)',
                                'Level',
                                'Tasks',
                              ])
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    switch (sortOption) {
                                      case 'Coins (default)':
                                        _changeSort('coins');
                                        print("sort by coins");
                                      case 'Level':
                                        _changeSort('level');
                                        print("sort by level");
                                      case 'Tasks':
                                        _changeSort('tasks');
                                        print("sort by tasks");
                                      default:
                                        _changeSort('deadline');
                                        print("sort by deadline");
                                    }
                                  },
                                  child: Text(sortOption,
                                      style:
                                          const TextStyle(color: Colors.blue)),
                                ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  //SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 30),
              ChartLeaderboard(),
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
class ChartLeaderboard extends StatefulWidget {
  //müssen noch ab deb Farben von den themes angepasst werden
  ChartLeaderboard({Key? key}) : super(key: key);

  @override
  _ChartLeaderboardState createState() => _ChartLeaderboardState();
}

class _ChartLeaderboardState extends State<ChartLeaderboard> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final List<Color> colorPrimaryList = leaderboardusers
        .take(3)
        .where((user) => user['username'] != null)
        .map((user) {
      String colorCode = user['colorPrimary'].replaceAll('#', '');
      return Color(int.parse('0xFF$colorCode'));
    }).toList();

    final List<Color> colorSecondaryList = leaderboardusers
        .take(3)
        .where((user) => user['username'] != null)
        .map((user) {
      String colorCode = user['colorSecondary'].replaceAll('#', '');
      return Color(int.parse('0xFF$colorCode'));
    }).toList();

    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            leaderboardusers.take(3).toList().asMap().entries.map((entry) {
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
class WeeklyInfo extends StatefulWidget {
  List<Map<String, dynamic>> leaderboardusers;

  WeeklyInfo({Key? key, required this.leaderboardusers}) : super(key: key);

  @override
  State<WeeklyInfo> createState() => _WeeklyInfoState();
}

class _WeeklyInfoState extends State<WeeklyInfo> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    print(widget.leaderboardusers);
    return SizedBox(
      width: width,
      height: height * 0.2,
      child: ListView.builder(
        itemCount: leaderboardusers.length,
        itemBuilder: (context, index) {
          List<IconData> iconDataList = [
            Icons.looks_one,
            Icons.looks_two,
            Icons.looks_3,
          ];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  if (widget.leaderboardusers[index]['coins'] != null &&
                      widget.leaderboardusers[index]['level'] != null)
                    Row(
                      children: [
                        if (index < 3)
                          Icon(iconDataList[index])
                        else
                          Stack(
                            children: [
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                bottom: -0.5,
                                child: Text('${index + 1}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontSize: 15)),
                              )
                            ],
                          ),
                        const SizedBox(width: 8.0),
                        Container(
                          width: 100,
                          child: Text(
                            //'Name ${index + 1}',
                            widget.leaderboardusers[index]['forename'] ??
                                widget.leaderboardusers[index]['surname'] ??
                                widget.leaderboardusers[index]['username'],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(width: 20),
                  if (widget.leaderboardusers[index]['coins'] != null)
                    Container(
                      width: 80,
                      child: Text(
                        //'$pts pts',
                        widget.leaderboardusers[index]['coins'].toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  //SizedBox(width: 5),
                  SvgPicture.asset(
                    "assets/images/relatee.svg",
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      userColor, // Provide a default color if _colorAnimation.value is null
                      BlendMode.srcIn,
                    ),
                  ),
                  Spacer(),
                  if (widget.leaderboardusers[index]['level'] != null)
                    Row(
                      children: [
                        //const Icon(CupertinoIcons.checkmark_circle_fill),
                        //const SizedBox(width: 8.0),
                        Text(
                          //'$tasks tasks',
                          widget.leaderboardusers[index]['level'].toString(),
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
