import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/household_tasks.dart';
import 'package:frontend_v1/login.dart';
import 'package:frontend_v1/main.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';

String getDueDaysInText(int days) {
  if (days == 1) {
    return 'day_txt'.tr;
  } else {
    return 'days_txt'.tr;
  }
}

late Gravatar gravatar;

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  @override
  Widget build(BuildContext context) {
    gravatar = Gravatar(userData['email']);   
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackIconRow(),
                  TextButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('Log_out?_txt'.tr),
                            content: Text('Logout_desc_txt'.tr),
                            actions: [
                              CupertinoDialogAction(
                                child: Text(
                                  'Cancel_txt'.tr,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text(
                                  'Continue_txt'.tr,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.remove('token');
                                  Get.offAll(() => const LoginWidget());
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(
                      CupertinoIcons.square_arrow_right,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 30,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  //Profile Picture
                  Container(
                    height: 200,
                    width: 200,
                    decoration: ShapeDecoration(
                      shape: CircleBorder(
                        side: BorderSide(
                          width: 6,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(gravatar.imageUrl(size: 200, defaultImage: 'mp')),
                    ),
                  ),
                ],
              ),
              Column(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text('${userData['forename']} ${userData['surname']}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 20),
                    Text(
                      '@${userData['username']}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: ('part_household'.tr),
                              style: Theme.of(context).textTheme.bodySmall),
                          TextSpan(
                              text: '"${userData['householdName']}"',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50, right: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 27, vertical: 9),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDECEC),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/relatee.svg",
                                  height: 20,
                                  width: 20,
                                  color: purple,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '${userData['coins']}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF4A4646),
                                    fontSize: 24,
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 27, vertical: 9),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDECEC),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Text(
                              'lvl ${userData['level']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4A4646),
                                fontSize: 24,
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ]),
              // const Divider(
              //     color: Color.fromARGB(238, 126, 126, 126),
              //     height: 100,
              //     thickness: 2),
              const SizedBox(height: 80),
              TaskOverview(userData: userData, tasks: tasks),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
      decoration: const BoxDecoration(
        color: Color(0xFFEDECEC),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF4A4646),
          fontSize: 24,
          fontFamily: 'Karla',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class BackIconRow extends StatelessWidget {
  const BackIconRow({super.key});

  final double padding = 20;
  final double size = 40;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: padding),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              onPressed: () async {
                Get.back();
              },
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.back,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 18,
                  ),
                  Container(width: 5),
                  // Icon(
                  //   CupertinoIcons.house_fill,
                  //   color: col,
                  //   size: 18,
                  // )
                  Text('back_button_text'.tr,
                      style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskOverview extends StatelessWidget {
  const TaskOverview({super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  final double size = 15;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: Text('Their_Tasks_txt'.tr,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        tasks.isNotEmpty
            ? Column(
                children: tasks
                    .where((task) => task['completed'] == false)
                    .map((task) {
                  return Task(task: task, userData: userData);
                }).toList(),
              )
            : Column(
                children: [
                  Text('User_no_tasks_assigned_txt'.tr,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  animationDuration: Duration.zero,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  Get.to(() => MainHouseholdOverview(pUserData: userData));
                },
                child: Row(
                  children: [
                    Text('Household_Overview_txt'.tr,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontSize: 18)),
                    const SizedBox(width: 10),
                    Icon(
                      CupertinoIcons.house,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: size,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
