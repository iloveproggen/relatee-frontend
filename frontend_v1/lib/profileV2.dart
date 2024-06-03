import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/household_tasks.dart';
import 'package:frontend_v1/login.dart';
import 'package:frontend_v1/main.dart';
import 'package:get/get.dart';

String getDueDaysInText(int days) {
  if (days == 1) {
    return 'day_txt'.tr;
  } else {
    return 'days_txt'.tr;
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  @override
  Widget build(BuildContext context) {
    print(userData);
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
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Get.offAll(() => const LoginWidget());
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
              const Column(
                children: [
                  // Profile Picture
                  // Container(
                  //   height: 200,
                  //   width: 200,
                  //   decoration: ShapeDecoration(
                  //     shape: CircleBorder(
                  //       side: BorderSide(
                  //         width: 6,
                  //         color: Theme.of(context).colorScheme.tertiary,
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
                          child:
                              _buildInfoContainer('${userData['coins']} pts'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child:
                              _buildInfoContainer('lvl ${userData['level']}'),
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
              SizedBox(height: 80),
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
          child: Text('Their Tasks',
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
                  Text("This user currently has no tasks assigned to them.",
                      style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(
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
                    Text("See Household Overview",
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
