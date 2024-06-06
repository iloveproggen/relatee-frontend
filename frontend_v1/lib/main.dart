import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:frontend_v1/create_new_task_v1.dart';
import 'package:frontend_v1/detailed_task_view.dart';
import 'package:frontend_v1/join_household.dart';
import 'package:frontend_v1/routine.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/household_tasks.dart';
import 'package:frontend_v1/login.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:frontend_v1/settings.dart';
import 'package:frontend_v1/shop.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(CheckLoggedIn());
}

late VoidCallback update;

late Map<String, dynamic> userData;
late List<Map<String, dynamic>> tasks;

http.Client httpClient = http.Client();
bool _taskView = true;
final random = Random();

Future<GraphQLClient> getGraphQLClient() async {
  String? token;
  final prefs = await SharedPreferences.getInstance();

  final httpLink = HttpLink(
    'http://85.215.50.29:3000/graphql',
    httpClient: httpClient,
  );

  final AuthLink authLink = AuthLink(
    getToken: () async {
      token = prefs.getString('token');
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
          level
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
          completed_at
          routineId
        }
        routines {
          id
          name
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
      //} else if (result.isLoading) {
    } else {
      final users = result.data!['user']['household']['users'];
      final tasks = result.data!['user']['household']['tasks'];
      final routines = result.data!['user']['household']['routines'];

      final List<Map<String, dynamic>> mappedUsers =
          users.map<Map<String, dynamic>>((user) {
        return {
          'id': user['id'],
          'forename': user['forename'],
          'surname': user['surname'],
          'username': user['username'],
          'email': user['email'],
          'level': user['level'],
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
          'completed_at': task['completed_at'],
          'routineId': task['routineId']
        };
      }).toList();

      final List<Map<String, dynamic>> mappedRoutines =
          routines.map<Map<String, dynamic>>((routine) {
        return {
          'id': routine['id'],
          'name': routine['name'],
        };
      }).toList();

      return {
        'users': mappedUsers,
        'tasks': mappedTasks,
        'routines': mappedRoutines,
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
    'rewards': [],
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
                  'userId': id,
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

void updateTask(int taskId, bool status) async {
  final Map<String, dynamic> variables = {
    'id': taskId,
    'completed': status,
    'completed_at': DateTime.now().toIso8601String().split('.')[0] + 'Z',
  };
  print(
    DateTime.now().toIso8601String().split('.')[0] + 'Z',
  );

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(
        r'''mutation UpdateTask($id: Int!, $completed: Boolean!, $completed_at: String) {
  updateTask(id: $id, completed: $completed, completed_at: $completed_at) {
    id
    completed
    completed_at
  }
}
'''),
    variables: variables,
  );

  try {
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      // Handle the result
      print(result.data);
      print("Updated the task in the db: $variables");
    }
  } catch (e) {
    print(e);
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

Builder getIndicator(Map<String, dynamic> task, BuildContext context) {
  DateTime now = DateTime.now();
  DateTime? deadline =
      DateTime.fromMillisecondsSinceEpoch(int.parse(task['deadline']));

  Widget green = SvgPicture.asset("assets/images/green.svg");
  Widget yellow = SvgPicture.asset("assets/images/yellow.svg");
  Widget red = SvgPicture.asset("assets/images/red.svg");
  Widget overdue = const Icon(CupertinoIcons.exclamationmark_circle,
      color: Colors.red, size: 23);

  return Builder(
    builder: (context) {
      if (deadline.isBefore(now)) {
        return overdue;
      } else if (deadline.year == now.year && deadline.month == now.month) {
        switch (deadline.day - now.day) {
          case 0:
          case 1:
          case 2:
            return red;
          default:
            return yellow;
        }
      } else {
        return green;
      }
    },
  );
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key, required this.userId});

  final int userId;

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final Color colLight = const Color.fromARGB(255, 243, 243, 243);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MainView(userId: widget.userId));
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key, required this.userId});

  final int userId;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late Future<Map<String, dynamic>> _futureUserData;

  @override
  void initState() {
    super.initState();
    _futureUserData = getUserData(widget.userId);
  }

  void _updateUserData() {
    setState(() {
      _futureUserData = getUserData(userData['id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    update = _updateUserData;
    return FutureBuilder<Map<String, dynamic>>(
        future: _futureUserData,
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error.toString());
            return const Placeholder();
          } else if (snapshot.data!['householdName'] == null) {
            return const JoinHouseholdView();
          } else {
            print(snapshot.data!);
            tasks = List<Map<String, dynamic>>.from(snapshot.data!['tasks']);
            userData = snapshot.data!;
            print(userData);
            return  const SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.only(top: 80, left: 40, right: 40),
                        child: Column(
                          children: [
                            IconRow(),
                            WelcomeText(),
                            ButtonRecommended(),
                            TaskOverview(),
                          ],
                        )));
          }
        });
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
                  onPressed: () async {
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
            onPressed: () async {
              Get.to(() => ShopView(userData: userData));
              update();
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
    List<Map<String, dynamic>> completedTasks =
        tasks.where((task) => task['completed'] == false).toList();
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
                      completedTasks.isNotEmpty
                          ? completedTasks[
                              random.nextInt(completedTasks.length)]['name']
                          : 'No tasks found,\n have a nice day!',
                          : 'No tasks found,\n have a nice day!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
            ),
          ],
        ),
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
    return Column(
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
                maxLines: 1,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
        const SizedBox(height: 30),
      ],
    );
  }
}

class ButtonRow extends StatelessWidget {
  const ButtonRow({super.key, required this.tasks});

  final List<Map<String, dynamic>> tasks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: ButtonShort(
              number: tasks == [] ? '0' : countToDo(tasks).toString(),
              textBelow: 'left to do',
              textBelow: 'left to do',
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: ButtonShort(
              number: tasks == []
                  ? '0'
                  : (tasks.length - countToDo(tasks)).toString(),
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

  late ConfettiController _centerController;

  @override
  void initState() {
    super.initState();

    // initialize confettiController
    _centerController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    // dispose the controller
    _centerController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> toDo =
      tasks.where((task) => task['completed'] == false).toList()
        ..sort((a, b) {
          if (a['deadline'] == null && b['deadline'] == null) {
            return 0;
          } else if (a['deadline'] == null) {
            return 1;
          } else if (b['deadline'] == null) {
            return -1;
          } else {
            return a['deadline'].compareTo(b['deadline']);
          }
        });

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
              ConfettiWidget(
                confettiController: _centerController,
                blastDirection: pi / 2,
                maxBlastForce: 9,
                minBlastForce: 5,
                emissionFrequency: 0.03,
                numberOfParticles: 10,
                shouldLoop: true,
                gravity: 0.2,
              ),
              IconButton(
                onPressed: () async {
                  var result =
                      await Get.to(() => NewTaskMain(userData: userData));
                  if (result != null) {
                    update();
                  }
                },
                icon: Icon(CupertinoIcons.add,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                        )
                                    : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary)),
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
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                        )
                                    : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary)),
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
                children: [
                  Column(
                    children: _taskView
                        ? [
                            ButtonRow(tasks: tasks),
                            toDo.isEmpty
                                ? Container()
                                : Column(
                                    children: [
                                      Column(
                                        children: toDo.map((task) {
                                          return Dismissible(
                                            direction:
                                                DismissDirection.horizontal,
                                            key: ValueKey(task['id']),
                                            onDismissed: (direction) async {
                                              if (direction ==
                                                  DismissDirection.endToStart) {
                                                showCupertinoDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          CupertinoAlertDialog(
                                                    title: const Text(
                                                        'Delete Task'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this task?'),
                                                    actions: [
                                                      CupertinoDialogAction(
                                                          child: const Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue)),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            update();
                                                          }),
                                                      CupertinoDialogAction(
                                                        onPressed: () {
                                                          deleteTask(
                                                              task['id']);
                                                          tasks.removeWhere(
                                                              (t) =>
                                                                  t['id'] ==
                                                                  task['id']);
                                                          Navigator.pop(
                                                              context);
                                                          update();
                                                        },
                                                        isDestructiveAction:
                                                            true,
                                                        child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                _centerController.play();
                                                print(
                                                    "Task completed! ${task['reward']}");
                                                updateTask(task['id'], true);
                                                tasks.removeWhere((t) =>
                                                    t['id'] == task['id']);
                                                addPoints(
                                                    task['reward'].toString());
                                                await Future.delayed(
                                                    const Duration(seconds: 3));
                                                showCupertinoDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CupertinoAlertDialog(
                                                      title: const Text(
                                                          'Congratulations!'),
                                                      content: const Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          // SizedBox(height: 10),
                                                          // Image.network(
                                                          //     "https://i.giphy.com/media/Wvh1de6cFXcWc/200.gif", scale: 1.3,),
                                                        ],
                                                      ),
                                                      actions: [
                                                        CupertinoDialogAction(
                                                          child: const Text(
                                                              'OK',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                              )),
                                                          onPressed: () async {
                                                            Navigator.pop(
                                                                context);
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
                          ]
                        : [
                            Routine(userData: userData),
                            const SizedBox(height: 10)
                          ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(0))),
                          onPressed: () async {
                            await Get.to(() =>
                                MainHouseholdOverview(pUserData: userData));
                            update();
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
        onPressed: () async {
          var result = await Get.to(() => DetailedTaskView(
                task: task,
                userData: userData,
                assigned: userData['forename'],
              ));
          if (result != null) {
            update();
          }
        },
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(task['name'],
                            style: task['deadline'] != null &&
                                    DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(task['deadline']))
                                        .isBefore(DateTime.now())
                                ? Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold))),
                    const SizedBox(height: 10),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          border: Border.all(
                              width: 2,
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              "${task['reward']} pts",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                            ))),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: task["deadline"] != null
                      ? getIndicator(task, context)
                      : SvgPicture.asset("assets/images/gray.svg"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
