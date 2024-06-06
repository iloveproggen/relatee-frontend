import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/create_new_task_v1.dart';
import 'package:frontend_v1/completed_tasks.dart';
import 'package:frontend_v1/detailed_task_view.dart';
import 'package:frontend_v1/household_invitation.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:frontend_v1/profile_public.dart';
import 'package:get/get.dart';

late List<Map<String, dynamic>> tasks;
late List<Map<String, dynamic>> users;
late Map<String, dynamic> userData;

class MainHouseholdOverview extends StatelessWidget {
  const MainHouseholdOverview({super.key, required this.pUserData});

  final Map<String, dynamic> pUserData;

  @override
  Widget build(BuildContext context) {
    userData = pUserData;
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
      child: Column(
        children: [const BackIconRow(), HouseholdOverview(userData: userData)],
      ),
    )));
  }
}

class HouseholdOverview extends StatelessWidget {
  const HouseholdOverview({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: getHouseholdData(userData['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  users = snapshot.data!['users'];
                  tasks = snapshot.data!['tasks'];
                  print(tasks);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your Household",
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 20),
                      const HouseholdMembers(),
                      const InviteButton(),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tasks",
                              style: Theme.of(context).textTheme.bodyMedium),
                          IconButton(
                            onPressed: () {
                              Get.to(() => NewTaskMain(userData: userData));
                            },
                            icon: Icon(CupertinoIcons.add,
                                color: Theme.of(context).colorScheme.tertiary,
                                size: 30),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: tasks
                                .where((task) => task['completed'] == false)
                                .isEmpty
                            ? [
                                Text("No tasks left todo :)",
                                    style:
                                        Theme.of(context).textTheme.bodySmall)
                              ]
                            : tasks
                                .where((task) => task['completed'] == false)
                                .toList()
                                .map((task) {
                                return Dismissible(
                                  key: Key(task.toString()),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) {
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          CupertinoAlertDialog(
                                        title: const Text('Delete Task'),
                                        content: Text(
                                            'Are you sure you want to delete "${task['name']}"?'),
                                        actions: [
                                          CupertinoDialogAction(
                                              child: Text('Cancel_txt'.tr,
                                                  style: const TextStyle(
                                                      color: Colors.blue)),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Get.forceAppUpdate();
                                              }),
                                          CupertinoDialogAction(
                                            onPressed: () {
                                              deleteTask(task['id']);
                                              tasks.removeWhere(
                                                  (t) => t['id'] == task['id']);
                                              Navigator.pop(context);
                                              Get.forceAppUpdate();
                                            },
                                            isDestructiveAction: true,
                                            child: Text('Delete_txt'.tr,
                                                style: const TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  background: Container(
                                    margin: const EdgeInsets.only(
                                        right: 30, bottom: 22),
                                    alignment: Alignment.centerRight,
                                    child: const Icon(CupertinoIcons.delete,
                                        color: Colors.red, size: 30),
                                  ),
                                  child: MoreDetailsTask(task: task),
                                );
                              }).toList(),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                          style: ButtonStyle(
                              animationDuration: Duration.zero,
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(0),
                              )),
                          onPressed: () {
                            Get.to(() => CompletedTaskList(
                                tasks: tasks
                                    .where((task) => task['completed'] == true)
                                    .toList(),
                                userData: users));
                          },
                          child: Text("See completed Tasks",
                              style: Theme.of(context).textTheme.labelSmall)),
                      const SizedBox(height: 40)
                    ],
                  );
                }
              },
            ),
          ],
        )
      ],
    );
  }
}

class HouseholdMembers extends StatelessWidget {
  const HouseholdMembers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(users.length, (index) {
            print(users[index]['householdName']);
            return Member(userData: users[index]);
          }),
        ),
      ],
    );
  }
}

class Member extends StatelessWidget {
  const Member({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon(CupertinoIcons.person_fill, size: 50, color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),),
        // const SizedBox(width: 10),
        TextButton(
          style: ButtonStyle(
              animationDuration: Duration.zero,
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.all(0),
              )),
          onPressed: () {
            Get.to(() => PublicProfile(
                userData: userData,
                tasks: tasks
                    .where((task) => task['userId'] == userData['id'])
                    .toList()));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userData['forename'] + " " + userData['surname'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                Text("@${userData['username']}",
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const Spacer(),
        UserPoints(userData: userData)
      ],
    );
  }
}

class UserPoints extends StatelessWidget {
  const UserPoints({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text("lvl ${userData['level'].toString()}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
      ),
    );
  }
}

class MoreDetailsTask extends StatelessWidget {
  const MoreDetailsTask({super.key, required this.task});

  final Map<String, dynamic> task;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Text(task['name'],
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                    ),
                    Builder(
                      builder: (context) {
                        switch (task['completed']) {
                          case true:
                            return SvgPicture.asset("assets/images/green.svg");
                          case false:
                            return SvgPicture.asset("assets/images/yellow.svg");
                          default:
                            return SvgPicture.asset("assets/images/red.svg");
                        }
                      },
                    ),
                  ],
                ),
                // task['description'] == ""
                //     ? Container()
                //     : Container(
                //         constraints: BoxConstraints(maxWidth: 160),
                //         child: Text('"${task['description']}"',
                //             style: Theme.of(context)
                //                 .textTheme
                //                 .bodySmall
                //                 ?.copyWith(
                //                   color: Theme.of(context).colorScheme.tertiary,
                //                 )),
                //       ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 180),
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
                const SizedBox(height: 10),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                          width: 1,
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        child: Text(task['reward'].toString() + " pts",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                )),
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

class InviteButton extends StatelessWidget {
  const InviteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        // TODO: Implement invite functionality
        await Get.to(() => const HouseholdInvitation());
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)),
      ),
      child: Row(
        children: [
          Text('Invite Members', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 10),
          Icon(CupertinoIcons.arrow_right,
              color: Theme.of(context).colorScheme.tertiary, size: 20)
        ],
      ),
    );
  }
}
