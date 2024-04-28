// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MainLeaderboardView());
}

class MainLeaderboardView extends StatelessWidget {
  const MainLeaderboardView({super.key});

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return const MainLeaderboardView();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          children: [
            BackIconRow(username: ""),
            SizedBox(height: 10),
            MembersText(),
            ChartLeaderboard(),
            WeeklyInfo(),
          ],
        ),
      ),
    ));
  }
}

class MembersText extends StatelessWidget {
  const MembersText({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Text(
        'Members_txt'.tr,
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.left,
      ),
    );
  }
}

class ChartLeaderboard extends StatelessWidget {
  const ChartLeaderboard({super.key});

final Color col = const Color.fromARGB(255, 204, 198, 196);


  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 2,
                    bottom: 2,
                  ),
                  child: Container(
                      width: width * 0.2,
                      height: width * 0.2,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      )),
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                      width: width * 0.2,
                      height: height * 0.1,
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          'rd',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                  ),
                  child: Container(
                      width: width * 0.2,
                      height: width * 0.2,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      )),
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: width * 0.2,
                    height: height * 0.3,
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'st',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                  ),
                  child: Container(
                      width: width * 0.2,
                      height: width * 0.2,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      )),
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: width * 0.2,
                    height: height * 0.2,
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'nd',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
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
                    Text('Name ${index + 1}'),
                  ],
                ),
                Text('${index * 10 + 86} pts'),
                Row(
                  children: [
                    Icon(CupertinoIcons.checkmark_circle_fill),
                    const SizedBox(width: 8.0),
                    Text('${index * 4 + 3} tasks'),
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