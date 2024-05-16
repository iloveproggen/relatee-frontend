// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_v1/profileV2.dart';

void main() {
  runApp(const MainLeaderboardView());
}

class MainLeaderboardView extends StatelessWidget {
  const MainLeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            MembersText(),
            ChartLeaderboard(),
          ],
        ),
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        MembersText(),
        ChartLeaderboard(),
      ],
    ),
  );
}

class MembersText extends StatelessWidget {
  const MembersText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          children: [
            const BackIconRow(),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 60),
              child: Text(
                'Members_txt'.tr,
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartLeaderboard extends StatelessWidget {
  //müssen noch ab deb Farben von den themes angepasst werden
  const ChartLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
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
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
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
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
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
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
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
    );
  }
}
