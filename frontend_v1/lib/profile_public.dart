import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/main.dart' as main;
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

String getDueDaysInText(int days) {
  if (days == 1) {
    return 'day_txt'.tr;
  } else {
    return 'days_txt'.tr;
  }
}

class PublicProfile extends StatelessWidget {
  const PublicProfile({super.key, required this.userData, required this.tasks});

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
              const BackIconRow(),
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
                    child: Icon(CupertinoIcons.smiley, size: 100, color: Theme.of(context).colorScheme.tertiary),
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
              PublicTaskOverview(userData: userData, tasks: tasks),
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

class PublicTaskOverview extends StatelessWidget {
  const PublicTaskOverview({super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  final double size = 15;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> taskLeft = tasks.where((task) => task['completed'] == false).toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: Text('Their Tasks',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        taskLeft.isNotEmpty
            ? Column(
                children: taskLeft.map((task) {
                  return main.Task(task: task, userData: userData);
                }).toList(),
              )
            : Column(
                children: [
                  Text("This user currently has no tasks assigned to them.",
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
      ],
    );
  }
}
