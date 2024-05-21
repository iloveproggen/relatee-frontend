import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/household_tasks.dart';
import 'package:frontend_v1/login.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/tasks.dart';
import 'package:get/get.dart';

String getDueDaysInText(int days) {
  if (days == 1) {
    return 'day_txt'.tr;
  } else {
    return 'days_txt'.tr;
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.userData});

  final Map<String, dynamic>? userData;

  @override
  Widget build(BuildContext context) {
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
                            title: const Text('Log out?'),
                            content: const Text(
                                'To access your tasks, you need to log in. Do you want to continue?'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text('Continue'),
                                onPressed: () {
                                  Get.to(() => const LoginWidget());
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, left: 10, right: 10),
                            child: /*Text("log out",
                              style: TextStyle(
                                  height: 1,
                                  color: Color.fromARGB(255, 243, 243, 243),
                                  fontSize: 15,
                                  fontFamily: "Karla",
                                  fontWeight: FontWeight.w700)),*/
                                Icon(
                              CupertinoIcons.arrowshape_turn_up_right_fill,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ))),
                  ),
                ],
              ),
              Column(
                children: [
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
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50, right: 10),
                        child: _buildInfoContainer('1150 pts'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: _buildInfoContainer('lvl 25'),
                      ),
                    ],
                  ),
                ],
              ),
              ListView(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${userData?['forename']} ${userData?['surname']}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: ('part_household'.tr),
                              style: Theme.of(context).textTheme.bodySmall),
                          TextSpan(
                              text: '"${userData?['householdName']}"',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '@${userData?['username']}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              ]),
              const Divider(
                  color: Color.fromARGB(238, 126, 126, 126),
                  height: 100,
                  thickness: 2),
              TaskOverview(userData: userData),
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
                    CupertinoIcons.arrowtriangle_left_fill,
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
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 15,
                          fontFamily: "Karla",
                          fontWeight: FontWeight.bold)),
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
  const TaskOverview({super.key, required this.userData});

  final Map<String, dynamic>? userData;

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
          child: Text('Their Tasks',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        const Task(taskName: "do the dishes", taskStatus: 2),
        const Task(taskName: "mop the floor", taskStatus: 1),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Get.to(() => const SeeAllTasks());
                },
                child: Row(
                  children: [
                    Text('SeeAllTasks_txt'.tr,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontSize: 15)),
                    Container(width: 5),
                    Icon(
                      CupertinoIcons.arrow_right,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: size,
                    )
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => MainHouseholdOverview(userData: userData));
                },
                child: Row(
                  children: [
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
