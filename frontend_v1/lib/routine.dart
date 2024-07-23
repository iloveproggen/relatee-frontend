import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/create_new_routine.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/routine_overview.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

Future<void> deleteRoutine(int id) async {
  final client = await getGraphQLClient();
  print("deleting routine $id");
  final MutationOptions options = MutationOptions(
    document: gql('''
      mutation deleteRoutine(\$routineId: Int!) {
        deleteRoutine(routineId: \$id)
      }
    '''),
    variables: <String, dynamic>{
      'routineId': id,
    },
  );
  try {
    await client.mutate(options).timeout(const Duration(seconds: 10));
  } on SocketException catch (e) {
    print('Network error: $e');
    // Handle network error
  } on TimeoutException catch (e) {
    print('Request timed out: $e');
    // Handle timeout
  } catch (e) {
    print('Unexpected error: $e');
    // Handle other errors
  }
}

class Routine extends StatefulWidget {
  const Routine({super.key, required this.householdData});

  final Map<String, dynamic> householdData;

  @override
  State<Routine> createState() => _RoutineState();
}

class _RoutineState extends State<Routine> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userData = widget.householdData['userData'];
    final List<Map<String, dynamic>> routines = widget.householdData['routines'];
    final List<Map<String, dynamic>> tasks = widget.householdData['tasks'];
    final List<Map<String, dynamic>> users = widget.householdData['users'];

    print("all tasks??? $tasks");

    if (routines.isNotEmpty) {
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
      return TextButton(
          onPressed: () async {
            await Get.to(() => NewRoutine(
                  pUserData: userData,
                ));
            update();
          },

          style: ButtonStyle(
              padding:
                  WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(0))),
          child: Text('No_routines_found_txt'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.tertiary)));
    }
  }
}

class RoutineItem extends StatelessWidget {
  const RoutineItem(
      {super.key,
      required this.routine,
      required this.users,
      required this.tasks,
      required this.userData});

  final Map<String, dynamic> routine;
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> tasks;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(routine['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text(
                "Delete Routine?"),
            content: Text(
                "Are you sure you want to delete this routine? The tasks assigned to this won't be deleted."
                    .tr),
            actions: [
              CupertinoDialogAction(
                  child: Text('Cancel_txt'.tr,
                      style: const TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context);
                    update();
                  }),
              CupertinoDialogAction(
                onPressed: () async {
                  await deleteRoutine(routine['id']);
                  Get.back();
                  update();
                },
                isDestructiveAction: true,
                child: Text('Delete_txt'.tr,
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        deleteRoutine(routine['id']);
      },
      background: Container(
        margin: const EdgeInsets.only(right: 30, bottom: 22),
        alignment: Alignment.centerRight,
        child: const Icon(CupertinoIcons.delete, color: Colors.red, size: 30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${routine['emoji']} ${routine['name']}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text("${routine['refreshDate'] != null ? DateFormat("dd-MM-yyy").format(routine['refreshDate']) : 'No refresh date set'}",
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: userColor))
                ],
              ),
              IconButton(
                  style: ButtonStyle(
                      animationDuration: Duration.zero,
                      padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                      alignment: Alignment.centerRight),
                  onPressed: () async {
                    print(tasks);
                    await Get.to(() => RoutineOverview(
                          routine: routine,
                          users: users,
                          tasks: tasks
                              .where(
                                  (task) => task['routineId'] == routine['id'])
                              .toList(),
                          userData: userData,
                        ));
                    updateWithoutReload();
                  },
                  icon: Icon(
                    CupertinoIcons.info,
                    size: 25,
                    color: Theme.of(context).colorScheme.tertiary,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
