import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend_v1/detailed_task_view.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

class RoutineOverview extends StatelessWidget {
  const RoutineOverview(
      {super.key,
      required this.routine,
      required this.users,
      required this.tasks,
      required this.userData});

  final Map<String, dynamic> routine;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> tasks;
  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackIconRow(),
              Text(routine['name'],
                  style: Theme.of(context).textTheme.bodyLarge),
              Text("Routine description",
                  style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: 30),
              tasks.isEmpty
                  ? Text("No tasks found.",
                      style: Theme.of(context).textTheme.bodySmall)
                  : Column(
                      children: tasks
                          .where((task) => task['completed'] == false)
                          .map((task) {
                        return RoutineTask(
                            task: task, users: users, userData: userData);
                      }).toList(),
                    ),
              SizedBox(height: 30),
            ],
          )),
    ));
  }
}

class RoutineTask extends StatelessWidget {
  const RoutineTask(
      {super.key,
      required this.task,
      required this.users,
      required this.userData});

  final Map<String, dynamic> task;
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> users;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextButton(
        style: ButtonStyle(
            animationDuration: Duration.zero,
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(0),
            )),
        onPressed: () => Get.to(() => DetailedTaskView(
              task: task,
              userData: userData,
              assigned: users.firstWhere((user) => user['id'] == task['userId'],
                  orElse: () => {'forename': null})['forename'],
            )),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary,
                offset: const Offset(5.0, 5.0),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 240),
                  child: Text(task['name'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 180),
                  child: (users.firstWhere(
                              (user) => user['id'] == task['userId'],
                              orElse: () => {'forename': null})['forename']) ==
                          null
                      ? Text('anyone',
                          style: Theme.of(context).textTheme.bodySmall)
                      : Text(
                          "${users.firstWhere((user) => user['id'] == task['userId'], orElse: () => {
                                'forename': null
                              })['forename']}",
                          style: Theme.of(context).textTheme.bodySmall),
                ),
                SizedBox(height: 10),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        child: Text(task['reward'].toString() + " pts",
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
