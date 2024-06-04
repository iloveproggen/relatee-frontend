import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/routine_overview.dart';
import 'package:get/get.dart';

class Routine extends StatelessWidget {
  const Routine({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: getHouseholdData(userData['id']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                print(snapshot.data!['routines']);
                List<Map<String, dynamic>> users = snapshot.data!['users'];
                List<Map<String, dynamic>> tasks = snapshot.data!['tasks'];
                if (snapshot.data!['routines'] != null) {
                  List<Map<String, dynamic>> routines =
                      List<Map<String, dynamic>>.from(
                          snapshot.data!['routines']);
                  print(routines);
                  return Column(
                    children: routines.map((routine) {
                      return RoutineItem(
                        routine: routine,
                        users: users,
                        tasks: tasks,
                        userData: userData,
                      );
                    }).toList(),
                  );
                } else {
                  return Text('No_routines_found_txt'.tr,
                      style: Theme.of(context).textTheme.bodySmall);
                }
              }
            },
          )
        ]);
  }
}

class RoutineItem extends StatelessWidget {
  const RoutineItem(
      {super.key,
      required this.routine,
      required this.users,
      required this.tasks,
      required this.userData});

  final Color colLight = const Color.fromARGB(255, 243, 243, 243);
  final Color colMid = const Color.fromARGB(255, 204, 198, 196);
  final Color colText = const Color(0xFF4A4646);

  final Map<String, dynamic> routine;
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> tasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            offset: const Offset(5.0, 5.0),
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(routine['name'],
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    'routine_description_txt'.tr,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 204, 198, 196),
                        fontSize: 20,
                        fontFamily: "Karla"),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(5),
              child: IconButton(
                  style: ButtonStyle(
                    animationDuration: Duration.zero,
                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                  ),
                  onPressed: () {
                    print(tasks);
                    Get.to(() => RoutineOverview(
                          routine: routine,
                          users: users,
                          tasks: tasks
                              .where(
                                  (task) => task['routineId'] == routine['id'])
                              .toList(),
                          userData: userData,
                        ));
                  },
                  icon: Icon(
                    CupertinoIcons.info,
                    size: 25,
                    color: Theme.of(context).colorScheme.tertiary,
                  )))
        ],
      ),
    );
  }
}
