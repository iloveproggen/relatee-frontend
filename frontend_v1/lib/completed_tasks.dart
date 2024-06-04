import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:intl/intl.dart';

late List<Map<String, dynamic>> completedTasks;
late List<Map<String, dynamic>> user;
final dateFormat =
    DateFormat("yyyy-MM-ddTHH:mm:ss"); // Adjust this to match your date format

String ordinal(int value) {
  if (value < 0 || value > 31) {
    throw ArgumentError('Day of month must be between 1 and 31');
  }

  if (value >= 11 && value <= 13) {
    return 'th';
  }

  switch (value % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

String formatDateWithOrdinal(DateTime date) {
  final day = date.day;
  final dayWithSuffix = '$day${ordinal(day)}';
  final month = DateFormat('MMMM').format(date);
  return '$dayWithSuffix $month';
}

class CompletedTaskList extends StatelessWidget {
  const CompletedTaskList(
      {super.key, required this.tasks, required this.userData});

  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> userData;

  @override
  Widget build(BuildContext context) {
    completedTasks = tasks;
    user = userData;
    print(userData);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackIconRow(),
                Text("Completed Tasks",
                    style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 20),
                ListBuilderCompleted()
              ],
            )),
      ),
    );
  }
}

class ListBuilderCompleted extends StatelessWidget {
  const ListBuilderCompleted({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: completedTasks.map((task) {
      print(task);
      return CompletedTaskDetailedView(
          task: task,
          userData: user.firstWhere((user) => user['id'] == task['userId'],
              orElse: () => {}));
    }).toList()
          ..sort(
            (a, b) {
              final completedAtA = a.task['completed_at'];
              final completedAtB = b.task['completed_at'];
              if (completedAtA == null && completedAtB == null) {
                return 0;
              } else if (completedAtA == null) {
                return 1;
              } else if (completedAtB == null) {
                return -1;
              } else {
                return completedAtB.compareTo(completedAtA);
              }
            },
          ));
  }
}

class CompletedTaskDetailedView extends StatelessWidget {
  const CompletedTaskDetailedView(
      {super.key, required this.task, required this.userData});

  final Map<String, dynamic> task;
  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        alignment: Alignment.topLeft,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: userData['forename'] == null
                          ? 'completed by someone'
                          : '${userData['forename']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " gained ${task['reward']} ${task['reward'] == 1 ? 'point' : 'points'} for completing '${task['name']}'",
                    style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                  task['completed_at'] == null
                      ? 'unknown'
                      : formatDateWithOrdinal(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(task['completed_at']))),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
