import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:frontend_v1/detailed_task_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/Create_New_Task.dart';
import 'package:frontend_v1/household_tasks.dart';
import 'package:frontend_v1/login.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:frontend_v1/settings.dart';
import 'package:frontend_v1/shop.dart';
import 'package:frontend_v1/tasks.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LoginApp());
}

late Map<String, dynamic> userData;
late List<Map<String, dynamic>> tasks;

http.Client httpClient = http.Client();
bool _taskView = true;
final random = Random();

Future<GraphQLClient> getGraphQLClient() async {
  final prefs = await SharedPreferences.getInstance();

  final httpLink = HttpLink(
    'http://85.215.50.29:3000/graphql',
    httpClient: httpClient,
  );

  final AuthLink authLink = AuthLink(
    getToken: () async {
      final token = prefs.getString('token');
      print('Token: $token');
      return 'Bearer $token';
    },
  );

  final Link link = authLink.concat(httpLink);
  return GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );
}

Future<Map<String, dynamic>> getHouseholdData(int id) async {
  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql('''
  query user(\$id: Int!) {
    user(id: \$id) {
      household {
        name
        users {
          id
          forename
          surname
          username
          email
          coins
        }
        tasks {
          id
          userId
          name
          description
          deadline
          reward
          completed    
        }
      }
    }
  }
'''),
    variables: <String, dynamic>{
      'id': id,
    },
  );
  try {
    final result =
        await client.query(options).timeout(const Duration(seconds: 10));

    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      print("getting results...");
      print(result.data!['user']);
      final users = result.data!['user']['household']['users'];
      final tasks = result.data!['user']['household']['tasks'];

      final List<Map<String, dynamic>> mappedUsers =
          users.map<Map<String, dynamic>>((user) {
        return {
          'id': user['id'],
          'forename': user['forename'],
          'surname': user['surname'],
          'username': user['username'],
          'email': user['email'],
          'coins': user['coins'],
          'householdName': result.data!['user']['household']['name'],
        };
      }).toList();

      final List<Map<String, dynamic>> mappedTasks =
          tasks.map<Map<String, dynamic>>((task) {
        return {
          'id': task['id'],
          'userId': task['userId'],
          'name': task['name'],
          'description': task['description'],
          'deadline': task['deadline'],
          'reward': task['reward'],
          'completed': task['completed'],
        };
      }).toList();

      print(mappedUsers);
      print(mappedTasks);

      return {
        'users': mappedUsers,
        'tasks': mappedTasks,
      };
    }
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
  return {
    'users': [],
    'tasks': [],
  };
}

Future<Map<String, dynamic>> getUserData(int id) async {
  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql('''
  query GetUser(\$id: Int!) {
    user(id: \$id) {
      id
      householdId
      forename
      surname
      username
      email
      experience
      level
      coins
      household {
        name
      }
      tasks {
        id
        name
        deadline
        description
        reward
        completed
        completed_at
        private
      }
    }
  }
'''),
    variables: <String, dynamic>{
      'id': id,
    },
  );

  try {
    final result =
        await client.query(options).timeout(const Duration(seconds: 10));

    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      final user = result.data!['user'];
      final mappedResult = {
        'id': id,
        'forename': user['forename'],
        'surname': user['surname'],
        'username': user['username'],
        'email': user['email'],
        'coins': user['coins'],
        'experience': user['experience'],
        'level': user['level'],
        'householdName': user['household']['name'],
        'householdId': user['householdId'],
        'tasks': user['tasks']
            .map((task) => {
                  'id': task['id'],
                  'name': task['name'],
                  'deadline': task['deadline'],
                  'description': task['description'],
                  'reward': task['reward'],
                  'completed': task['completed'],
                  'completed_at': task['completed_at'],
                  'private': task['private'],
                })
            .toList(),
      };
      if (mappedResult['points'] == null) {
        mappedResult['points'] = 0;
      }

      return mappedResult;
    }
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
  return {};
}

int countToDo(List<Map<String, dynamic>> tasks) {
  int count = 0;
  for (var task in tasks) {
    if (task['completed'] == false) {
      count++;
    }
  }
  return count;
}

Future<void> deleteTask(int id) async {
  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql('''
      mutation DeleteTask(\$id: Int!) {
        deleteTask(id: \$id) {
        }
      }
    '''),
    variables: <String, dynamic>{
      'id': id,
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

Future<void> addPoints(String coinsToAdd) async {
  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql('''
    mutation updateUser(\$id: Int!, \$coins: Int, \$email: String) {
      updateUser(
        id: \$id
        coins: \$coins
        email: \$email
      ) {
        id
        coins
        email
      }
    }
  '''),
    variables: <String, dynamic>{
      'id': userData['id'],
      'coins': userData['coins'] + int.parse(coinsToAdd),
      'email': userData['email'],
    },
  );
  try {
    final result =
        await client.query(options).timeout(const Duration(seconds: 10));
    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      print('Points added successfully');
    }
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

class MainWidget extends StatelessWidget {
  const MainWidget({super.key, required this.userId});

  final int userId;
  final Color colLight = const Color.fromARGB(255, 243, 243, 243);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(userId),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          tasks = List<Map<String, dynamic>>.from(snapshot.data!['tasks']);
          userData = snapshot.data!;
          print('\nhere is all the data: ${snapshot.data}');
          print('\nhere is the userdata: $userData');
          print('\nhere are the tasks: $tasks');

          return const MainView();
        }
      },
    );
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  void _updateTasks() {
    setState(() {
      // Add your code here to update the tasks
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
            child: Column(
              children: [
                IconRow(),
                WelcomeText(),
                ButtonRecommended(),
                TaskOverview(),
              ],
            )),
      ),
    );
  }
}

class IconRow extends StatelessWidget {
  const IconRow({super.key});

  final double padding = 20;
  final double size = 40;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: padding),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: size,
                  onPressed: () {
                    Get.to(() => ProfileView(userData: userData, tasks: tasks));
                  },
                  icon: Icon(
                    CupertinoIcons.person_fill,
                    color: col,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: padding),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: size,
                  onPressed: () {
                    Get.to(() => Settings(userData: userData));
                  },
                  icon: Icon(
                    CupertinoIcons.gear_solid,
                    color: col,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            padding: EdgeInsets.zero,
            iconSize: size,
            onPressed: () {
              Get.to(() => ShopView(userData: userData));
            },
            icon: Icon(
              CupertinoIcons.cart_fill,
              color: col,
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 50, top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'welcome_title'.tr}, ${userData['forename'] ?? ''}!',
                  maxLines: 2, style: Theme.of(context).textTheme.bodyLarge),
              Text('welcome_message'.tr,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('Recommended_txt'.tr,
                style: Theme.of(context).textTheme.labelSmall),
          ),
        ),
      ],
    );
  }
}

class ButtonRecommended extends StatelessWidget {
  const ButtonRecommended({super.key});

  final double height = 150;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: SizedBox(
        child: Column(
          children: [
            Container(
              height: height,
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
                  )
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    tasks.isNotEmpty
                        ? tasks[random.nextInt(tasks.length)]['name']
                        : 'No tasks found, have a nice day!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonCompleted extends StatelessWidget {
  const ButtonCompleted(
      {super.key, required this.who, required this.what, required this.time});

  final String who;
  final String what;
  final String time;
  final double height = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Container(
            height: height,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Color.fromARGB(255, 243, 243, 243),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(61, 109, 103, 103),
                  offset: Offset(5.0, 5.0),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                )
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "$who completed",
                    style: Theme.of(context).textTheme.bodySmall,
                    children: <TextSpan>[
                      TextSpan(
                        text: " \"$what\" ",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "$time."),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class ButtonShort extends StatelessWidget {
  const ButtonShort({super.key, required this.number, required this.textBelow});

  final double height = 160;
  final String number;
  final String textBelow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Container(
            height: height,
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
                )
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    number,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 60),
                    maxLines: 2,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    child: Text(
                      textBelow,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class ButtonRow extends StatelessWidget {
  const ButtonRow({super.key, required this.tasks});

  final List<Map<String, dynamic>> tasks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: ButtonShort(
              number: countToDo(tasks).toString(),
              textBelow: 'leftThisWeek_txt'.tr,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: ButtonShort(
              number: (tasks.length - countToDo(tasks)).toString(),
              textBelow: 'doneThisWeek_txt'.tr,
            ),
          ),
        ),
      ],
    );
  }
}

class TaskOverview extends StatefulWidget {
  const TaskOverview({super.key});

  @override
  State<TaskOverview> createState() => _TaskState();
}

class _TaskState extends State<TaskOverview> {
  _TaskState();
  final double size = 15;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${'Your_txt'.tr} Tasks',
                  style: Theme.of(context).textTheme.bodyMedium),
              TextButton(
                onPressed: () {
                  Get.to(() => NewTask(userData: userData));
                },
                child: Icon(CupertinoIcons.add,
                    color: Theme.of(context).colorScheme.tertiary, size: 30),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 20),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0x7FD9D9D9),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    alignment: _taskView
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 - 40,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _taskView = true;
                              });
                            },
                            child: Text('task view',
                                style: _taskView
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        )
                                    : Theme.of(context).textTheme.bodySmall),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _taskView = false;
                              });
                            },
                            child: Text('routine view',
                                style: _taskView
                                    ? Theme.of(context).textTheme.bodySmall
                                    : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: _taskView
                    ? [
                        ButtonRow(tasks: tasks),
                        tasks.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                    "Hooray, no tasks! \nCreate a new one or enjoy the day!",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              )
                            : Column(
                                children: [
                                  Column(
                                    children: tasks.map((task) {
                                      return Dismissible(
                                        direction: DismissDirection.horizontal,
                                        key: ValueKey(task['id']),
                                        onDismissed: (direction) {
                                          if (direction ==
                                              DismissDirection.endToStart) {
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  CupertinoAlertDialog(
                                                title:
                                                    const Text('Delete Task'),
                                                content: const Text(
                                                    'Are you sure you want to delete this task?'),
                                                actions: [
                                                  CupertinoDialogAction(
                                                      child: const Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue)),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Get.forceAppUpdate();
                                                      }),
                                                  CupertinoDialogAction(
                                                    onPressed: () {
                                                      deleteTask(task['id']);
                                                      tasks.removeWhere((t) =>
                                                          t['id'] ==
                                                          task['id']);
                                                      Navigator.pop(context);
                                                      Get.forceAppUpdate();
                                                    },
                                                    isDestructiveAction: true,
                                                    child: const Text('Delete',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            print(
                                                "Task completed! ${task['points']}");
                                            deleteTask(task['id']);
                                            tasks.removeWhere(
                                                (t) => t['id'] == task['id']);
                                            addPoints(
                                                task['points'].toString());
                                            Get.forceAppUpdate();
                                          }
                                        },
                                        secondaryBackground: Container(
                                          margin: const EdgeInsets.only(
                                              right: 30, bottom: 22),
                                          alignment: Alignment.centerRight,
                                          child: const Icon(
                                              CupertinoIcons.delete,
                                              color: Colors.red,
                                              size: 30),
                                        ),
                                        background: Container(
                                          margin: const EdgeInsets.only(
                                              left: 30, bottom: 22),
                                          alignment: Alignment.centerLeft,
                                          child: const Icon(
                                              CupertinoIcons.check_mark,
                                              color: Colors.green,
                                              size: 30),
                                        ),
                                        child: Task(
                                            task: task, userData: userData),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // TextButton(
                              //   onPressed: () {
                              //     Get.to(() => SeeAllTasks(
                              //         userData: userData, tasks: tasks));
                              //   },
                              //   child: Row(
                              //     children: [
                              //       Text('SeeAllTasks_txt'.tr,
                              //           style: Theme.of(context)
                              //               .textTheme
                              //               .labelSmall
                              //               ?.copyWith(fontSize: 15)),
                              //       const SizedBox(width: 5),
                              //       Icon(
                              //         CupertinoIcons.arrow_right,
                              //         color: Theme.of(context)
                              //             .colorScheme
                              //             .tertiary,
                              //         size: size,
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              TextButton(
                                onPressed: () {
                                  Get.to(() => MainHouseholdOverview(
                                      userData: userData));
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      size: size,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : [const RoutineWidget()],
              ),
            )
          ],
        ),
      ],
    );
  }
}

class Task extends StatelessWidget {
  const Task({super.key, required this.task, required this.userData});

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
            padding: const EdgeInsets.only(top: 30, bottom: 30, left: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task['name'],
                    style: Theme.of(context).textTheme.bodySmall),
                Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Builder(
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
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
