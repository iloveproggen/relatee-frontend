// ignore: file_names
import 'package:flutter/material.dart';
import 'assets/LocaleStrings.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MainLeaderboard());
}

class MainLeaderboard extends StatelessWidget {
  const MainLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        translations: LocaleString(),
        locale: Locale('de-DE'),
        fallbackLocale: Locale('en-US'),
        home: const Scaffold(
            body: SingleChildScrollView(
          child: Column(
            children: [
              MembersText(),
              ChartLeaderboard(),
            ],
          ),
        )));
  }
}

class MembersText extends StatelessWidget {
  const MembersText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          'Members_txt'.tr,
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

class ChartLeaderboard extends StatelessWidget {
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
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 2,
                  bottom: 2,
                ),
                child: Container(
                    width: width * 0.2,
                    height: height * 0.4,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    )),
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
                    height: height * 0.4,
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
                    height: height * 0.4,
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
    );
  }
}
