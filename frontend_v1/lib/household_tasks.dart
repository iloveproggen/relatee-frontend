import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/create_new_task_v1.dart';
import 'package:frontend_v1/completed_tasks.dart';
import 'package:frontend_v1/detailed_task_view.dart';
import 'package:frontend_v1/household_invitation.dart';
import 'package:frontend_v1/leader_board_v2.dart';
import 'package:frontend_v1/main.dart' as main;
import 'package:frontend_v1/profileV2.dart';
import 'package:frontend_v1/profile_public.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'main.dart';

late List<Map<String, dynamic>> tasks;
late List<Map<String, dynamic>> users;
late Map<String, dynamic> userData;

late Function update;

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

class HouseholdOverview extends StatefulWidget {
  const HouseholdOverview({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<HouseholdOverview> createState() => _HouseholdOverviewState();
}

class _HouseholdOverviewState extends State<HouseholdOverview> {
  late Future<Map<String, dynamic>> _futureHouseholdData;

  @override
  void initState() {
    super.initState();
    _futureHouseholdData = main.getHouseholdData(context);
  }

  void _updateHouseholdData() {
    setState(() {
      _futureHouseholdData = main.getHouseholdData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    update = _updateHouseholdData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _futureHouseholdData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  users = snapshot.data!['users'];
                  tasks = snapshot.data!['tasks'];
                  userData = snapshot.data!['userData'];
                  return const HouseholdWidget();
                }
              },
            ),
          ],
        )
      ],
    );
  }
}

class HouseholdWidget extends StatefulWidget {
  const HouseholdWidget({super.key});

  @override
  State<HouseholdWidget> createState() => _HouseholdWidgetState();
}

class _HouseholdWidgetState extends State<HouseholdWidget> {
  String sortBy = "deadline";
  bool isSearchBarOpen = false;

  List<Map<String, dynamic>> filteredTasks = tasks;

  late FocusNode searchBar;
  TextEditingController search = TextEditingController();

  void resort(List<Map<String, dynamic>> list) {
    list.sort((a, b) {
      // Check if either deadline is null
      if (a[sortBy] == null && b[sortBy] == null) {
        return 0; // Both are null, considered equal
      } else if (a[sortBy] == null) {
        return 1; // a should be after b
      } else if (b[sortBy] == null) {
        return -1; // b should be after a
      } else {
        // Neither is null, proceed with normal comparison
        return a[sortBy].compareTo(b[sortBy]);
      }
    });
  }

  void filter() {
    setState(() {
      filteredTasks =
          tasks.where((task) => task['name'].contains(search.text)).toList();
    });
  }

  void initState() {
    super.initState();
    resort(filteredTasks);
    searchBar = FocusNode();
    search.addListener(() {
      filter();
      print(search.text);
    });

    // Add the listener
    searchBar.addListener(() {
      if (!searchBar.hasFocus) {
        _closeSearchBar();
      }
    });
  }

  void _refreshView(String newFilterBy) {
    setState(() {
      sortBy = newFilterBy;
      resort(filteredTasks);
    });
  }

  void _reverseView() {
    setState(() {
      filteredTasks = filteredTasks.reversed.toList();
    });
  }

  void _openSearchBar() {
    setState(() {
      isSearchBarOpen = true;
      searchBar.requestFocus();
    });
  }

  void _closeSearchBar() {
    setState(() {
      isSearchBarOpen = false;
      filteredTasks = tasks;
      search.clear();
    });
  }

  @override
  void dispose() {
    // Remove the listener and dispose of the focus node
    searchBar.removeListener(_closeSearchBar);
    searchBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your_Household_txt'.tr,
                style: Theme.of(context).textTheme.bodyLarge),
            IconButton(
              onPressed: () {
                if (users.length == 1) {
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('LeaderBoardMessage_txt'.tr),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('Okay',  style: TextStyle(color: Colors.blue)),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                          CupertinoDialogAction(
                            child: Text('Invite More!', style: TextStyle(color: Colors.blue)),
                            onPressed: () async {
                              Get.back();
                              await Get.to(() => const HouseholdInvitation());
                              update();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Get.to(() => MainLeaderboardView(users: users, tasks: tasks));
                }
              },
              icon: Icon(
                CupertinoIcons.chart_bar_alt_fill,
                size: 40,
                color: main.userColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const HouseholdMembers(),
        const InviteButton(),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tasks", style: Theme.of(context).textTheme.bodyMedium),
                IconButton(
                  onPressed: () async {
                    var result =
                        await Get.to(() => NewTaskMain(userData: userData));
                    if (result != null) {
                      update();
                    }
                  },
                  icon:
                      Icon(CupertinoIcons.add, color: main.userColor, size: 30),
                ),
              ],
            ),
            tasks.where((task) => task['completed'] == false).isEmpty
                ? Container()
                : isSearchBarOpen
                    ? Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: TextField(
                              controller: search,
                              focusNode: searchBar,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 20),
                                hintText: 'Search tasks',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: main.userColor,
                                    ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: main.userColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    width: 1.5,
                                    color: main.userColor,
                                  ),
                                ),
                                focusColor: main.userColor.withOpacity(0.5),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: main.userColor),
                            ),
                          ),
                        ),
                        IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _closeSearchBar();
                            },
                            icon: Icon(CupertinoIcons.xmark,
                                color: main.userColor, size: 20))
                      ])
                    : Row(
                        children: [
                          TextButton(
                            style: ButtonStyle(
                                alignment: Alignment.centerLeft,
                                animationDuration: Duration.zero,
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(0),
                                )),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: main.userColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(100)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 10),
                                child: Text('Sort',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: main.userColor)),
                              ),
                            ),
                            onPressed: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoActionSheet(
                                    title: const Text('Sort tasks by...'),
                                    actions: [
                                      for (var sortOption in [
                                        'Deadline (default)',
                                        'Reward',
                                        'Assigned to',
                                        'Task name'
                                      ])
                                        CupertinoActionSheetAction(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            switch (sortOption) {
                                              case 'Deadline (default)':
                                                _refreshView('deadline');
                                                print("sort by deadline");
                                              case 'Reward':
                                                _refreshView('reward');
                                                print("sort by reward");
                                              case 'Assigned to':
                                                _refreshView('userId');
                                                print("sort by assigned to");
                                              case 'Task name':
                                                _refreshView('name');
                                                print("sort by task name");
                                              default:
                                                _refreshView('deadline');
                                                print("sort by deadline");
                                            }
                                          },
                                          child: Text(sortOption,
                                              style: const TextStyle(
                                                  color: Colors.blue)),
                                        ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          TextButton(
                            style: ButtonStyle(
                                alignment: Alignment.centerLeft,
                                animationDuration: Duration.zero,
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(0),
                                )),
                            child: Icon(CupertinoIcons.arrow_up_arrow_down,
                                color: main.userColor, size: 25),
                            onPressed: () {
                              _reverseView();
                            },
                          ),
                          const Spacer(),
                          TextButton(
                            style: ButtonStyle(
                                alignment: Alignment.centerRight,
                                animationDuration: Duration.zero,
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(0),
                                )),
                            child: Icon(CupertinoIcons.search,
                                color: main.userColor, size: 25),
                            onPressed: () {
                              _openSearchBar();
                            },
                          ),
                          const SizedBox(width: 10)
                        ],
                      )
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: tasks.where((task) => task['completed'] == false).isEmpty
              ? [
                  Text('No_tasks_left_txt'.tr,
                      style: Theme.of(context).textTheme.bodySmall)
                ]
              : filteredTasks
                  .where((task) => task['completed'] == false)
                  .toList()
                  .map((task) {
                  return Dismissible(
                    direction: DismissDirection.horizontal,
                    key: ValueKey(task['id']),
                    onDismissed: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoAlertDialog(
                            title: Text(
                                "${"${'Delete_Task_txt'.tr} " + task['name']}?"),
                            content: Text('Sure_delete_task?_txt'.tr),
                            actions: [
                              CupertinoDialogAction(
                                  child: Text('Cancel_txt'.tr,
                                      style:
                                          const TextStyle(color: Colors.blue)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    update();
                                  }),
                              CupertinoDialogAction(
                                onPressed: () async {
                                  await deleteTask(task['id']);
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
                      } else {
                        print("${'Task_completed!_txt'.tr} ${task['reward']}");
                        tasks.removeWhere((t) => t['id'] == task['id']);
                        completeTask(task['id']);
                        // addPoints(
                        //     task['reward'].toString());
                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text('Congratulations!_txt'.tr),
                              content: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  // Image.network(
                                  //   "https://i.giphy.com/media/Wvh1de6cFXcWc/200.gif",
                                  //   scale: 1.3,
                                  // ),
                                ],
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK',
                                      style: TextStyle(
                                        color: Colors.blue,
                                      )),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    update();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    secondaryBackground: Container(
                      margin: const EdgeInsets.only(right: 30, bottom: 22),
                      alignment: Alignment.centerRight,
                      child: const Icon(CupertinoIcons.delete,
                          color: Colors.red, size: 30),
                    ),
                    background: Container(
                      margin: const EdgeInsets.only(left: 30, bottom: 22),
                      alignment: Alignment.centerLeft,
                      child: Icon(CupertinoIcons.check_mark,
                          color: userColor, size: 30),
                    ),
                    child: Task(
                        task: task,
                        userData: userData,
                        isRecommended: false,
                        showAssignedUser: true),
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
              List<Map<String, dynamic>> completedTasks =
                  tasks.where((task) => task['completed'] == true).toList();
              Get.to(() =>
                  CompletedTaskList(tasks: completedTasks, userData: users));
            },
            child: Text('See_completed_Tasks_txt'.tr,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.tertiary))),
        const SizedBox(height: 40)
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
            return GestureDetector(
              onLongPress: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoActionSheet(
                      title: Text(
                          "Manage User ${users[index]['forename']} ${users[index]['surname']}"),
                      actions: [
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Get.to(() => PublicProfile(
                                userData: users[index],
                                tasks: tasks
                                    .where((task) =>
                                        task['userId'] == users[index]['id'])
                                    .toList()));
                          },
                          child: const Text('View Profile',
                              style: TextStyle(color: Colors.blue)),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            kickUser(users[index], context);
                          },
                          child: const Text('Kick from Household',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.blue)),
                      ),
                    );
                  },
                );
              },
              child: Member(userData: users[index]),
            );
          }),
        ),
      ],
    );
  }

  void kickUser(Map<String, dynamic> user, BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Confirm Kick'),
          content: Text(
              'Are you sure you want to kick ${user['forename']} ${user['surname']} from the household? All tasks assigned to this user will also be deleted.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              onPressed: () async {
                queryKickUser(user['id']);
                Navigator.pop(context);
                Get.back();
              },
              isDestructiveAction: true,
              child: const Text('Kick', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

Future<void> queryKickUser(int id) async {
  final client = await main.getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql('''
      mutation kickUserFromHousehold(\$userId: Int!) {
        kickUserFromHousehold(userId: \$userId) {}
      }
    '''),
    variables: <String, dynamic>{
      'userId': id,
    },
  );
  final QueryResult result = await client.mutate(options);
  if (result.hasException) {
    print(result.exception.toString());
  } else if (result.isLoading) {
    print('Loading');
  } else {
    print("User was kicked.");
  }
}

class Member extends StatelessWidget {
  const Member({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon(CupertinoIcons.person_fill, size: 50, color:main.userColor.withOpacity(0.5),),
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
                userData['forename'] != null && userData['surname'] != null
                    ? Text(userData['forename'] + " " + userData['surname'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ))
                    : Container(),
                userData['forename'] != null && userData['surname'] == null
                    ? Text(userData['forename'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ))
                    : Container(),
                userData['forename'] == null && userData['surname'] != null
                    ? Text(userData['surname'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ))
                    : Container(),
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
                      child: Text(
                          task['emoji'] != null && task['emoji'] != ""
                              ? "${task['emoji']} ${task['name']}"
                              : task['name'],
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                    ),
                    task["deadline"] != null
                        ? main.getIndicator(task, context)
                        : SvgPicture.asset("assets/images/gray.svg"),
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
                //                   color:main.userColor,
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
                      border: Border.all(width: 1, color: main.userColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        child: Text(task['reward'].toString() + " pts",
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: main.userColor,
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
        update();
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)),
      ),
      child: Row(
        children: [
          Text('Invite_Members_txt'.tr,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  )),
          const SizedBox(width: 10),
          Icon(CupertinoIcons.arrow_right,
              color: Theme.of(context).colorScheme.tertiary, size: 20)
        ],
      ),
    );
  }
}
