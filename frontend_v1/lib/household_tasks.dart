import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/detailed_task_view.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

late List<Map<String, dynamic>> tasks;
late List<Map<String, dynamic>> users;

class MainHouseholdOverview extends StatelessWidget {
  const MainHouseholdOverview({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
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
    print('\n\n\ntest: ${userData['id']}');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const ButtonCompleted(
        //     who: "Marvin", what: "do the dishes", time: "today"),
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
                  print(users);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your Household",
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 20),
                      HouseholdMembers(userData: userData),
                      const SizedBox(height: 20),
                      Text("Tasks",
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 10),
                      Column(
                        children: tasks.map((task) {
                          return MoreDetailsTask(
                              task: task, userData: userData);
                        }).toList(),
                      ),
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
    required this.userData,
  });

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(users.length, (index) {
            return Member(userData: users[index]);
          }),
        ),
        const SizedBox(height: 20)
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
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
        child: Text("${userData['points'].toString()} pts",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
      ),
    );
  }
}

class MoreDetailsTask extends StatelessWidget {
  const MoreDetailsTask(
      {super.key, required this.task, required this.userData});

  final Map<String, dynamic> task;
  final Map<String, dynamic> userData;

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
                    Text(task['name'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                    Builder(
                      builder: (context) {
                        switch (task['status']) {
                          case 1:
                            return SvgPicture.asset("assets/images/green.svg");
                          case 2:
                            return SvgPicture.asset("assets/images/yellow.svg");
                          case 0:
                            return SvgPicture.asset("assets/images/red.svg");
                          default:
                            return SvgPicture.asset("assets/images/red.svg");
                        }
                      },
                    ),
                  ],
                ),
                task['description'] == ""
                    ? Container()
                    : Text('"${task['description']}"',
                        style: Theme.of(context).textTheme.bodySmall),
                Text(
                    (users.firstWhere((user) => user['id'] == task['userId'])[
                                'forename']) ==
                            null
                        ? 'anyone'
                        : "assigned to ${users.firstWhere((user) => user['id'] == task['userId'])['forename']}",
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
