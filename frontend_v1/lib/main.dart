import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:frontend_v1/create_new_routine.dart';
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
import 'package:frontend_v1/shop.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CheckLoggedIn());
}

late Color userColor;
late VoidCallback update;
const Color purple = Color(0xFF7C4ACA);
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

Future<Map<String, dynamic>> getHouseholdData(BuildContext context) async {
  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql('''
      query CombinedQuery {
        household {
          id
          name
          emoji
          users {
            id
            forename
            surname
            username
            email
            level
            coins
            emoji
            colorPrimary
            colorSecondary
          }
          routines {
            id
            name
            emoji
          }
          tasks {
            id
            name
            emoji
            deadline
            description
            reward
            completed
            completedAt
            private
            user {
              id
              forename
              surname
              username
              email
              level
              coins
            }
            owner {
              id
              forename
              surname
              username
            }
            routine {
              id
              name
            }
          }
          rewards {
            id
            name
            price
            emoji
            stock
            description
          }
        }
        me {
          id
          username
          forename
          surname
          email
          coins
          experience
          level
          emoji
          colorPrimary
          colorSecondary
        }
      }
    '''),
  );
  try {
    final result =
        await client.query(options).timeout(const Duration(seconds: 10));

    if (result.hasException) {
      print(result.exception.toString());
    } else {
      print(result.data);
      final householdData = result.data!['household'];
      final userData = result.data!['me'];

      // Extracting users, tasks, and routines from household data
      final users = householdData['users'];
      final tasks = householdData['tasks'];
      final routines = householdData['routines'];

      final rewardsData = result.data!['household']['rewards'] ?? [];
      final List<Map<String, dynamic>> mappedRewards =
          rewardsData.map<Map<String, dynamic>>((reward) {
        return {
          'id': reward['id'],
          'name': reward['name'],
          'price': reward['price'],
          'stock': reward['stock'] ??
              '0', // Provide a default value for stock if null
          'emoji': reward['emoji'] ?? '0',
          'description': reward['description'] ??
              '', // Provide a default value for description if null
        };
      }).toList();

      print("rewards: $mappedRewards");
      // Filtering tasks for the logged-in user
      final myTasks =
          tasks.where((task) => task['user']?['id'] == userData['id']).toList();
      final otherTasks =
          tasks.where((task) => task['user']?['id'] != userData['id']).toList();

      // Mapping users to a new structure
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
          'emoji': user['emoji'],
          'colorPrimary': user['colorPrimary'],
          'colorSecondary': user['colorSecondary'],
          'householdName': householdData['name'],
          'householdId': result.data!['household']['id'],
        };
      }).toList();

      // Mapping tasks to a new structure
      final List<Map<String, dynamic>> mappedTasks =
          tasks.map<Map<String, dynamic>>((task) {
        return {
          'id': task['id'],
          'name': task['name'],
          'emoji': task['emoji'],
          'deadline': task['deadline'],
          'description': task['description'],
          'reward': task['reward'],
          'completed': task['completed'],
          'completedAt': task['completedAt'],
          'private': task['private'],
          'userId': task['user'] != null ? task['user']['id'] : null,
          'userForename':
              task['user'] != null ? task['user']['forename'] : null,
          'userSurname': task['user'] != null ? task['user']['surname'] : null,
          'userUsername':
              task['user'] != null ? task['user']['username'] : null,
          'ownerId': task['owner']['id'],
          'ownerForename': task['owner']['forename'],
          'routineId': task['routine'] != null ? task['routine']['id'] : null,
          'routineName':
              task['routine'] != null ? task['routine']['name'] : null,
        };
      }).toList();

      // Mapping routines to a new structure
      final List<Map<String, dynamic>> mappedRoutines =
          routines.map<Map<String, dynamic>>((routine) {
        return {
          'id': routine['id'],
          'name': routine['name'],
        };
      }).toList();

      // Mapping the logged-in user's data
      final mappedUserData = {
        'id': userData['id'],
        'forename': userData['forename'],
        'surname': userData['surname'],
        'username': userData['username'],
        'email': userData['email'],
        'coins': userData['coins'],
        'experience': userData['experience'],
        'level': userData['level'],
        'emoji': userData['emoji'],
        'colorPrimary': userData['colorPrimary'],
        'colorSecondary': userData['colorSecondary'],
        'householdName': householdData['name'],
        'householdId': result.data!['household']['id'],
        'tasks': myTasks
            .map<Map<String, dynamic>>((task) => {
                  'id': task['id'],
                  'userId': userData['id'],
                  'name': task['name'],
                  'deadline': task['deadline'],
                  'description': task['description'],
                  'reward': task['reward'],
                  'completed': task['completed'],
                  'completed_at': task['completedAt'],
                  'emoji': task['emoji'],
                  'private': task['private'],
                  'ownerId': task['owner']['id'],
                  'ownerForename': task['owner']['forename'],
                  'ownerSurname': task['owner']['surname'],
                })
            .toList(),
        'otherTasks': otherTasks
            .map<Map<String, dynamic>>((task) => {
                  'id': task['id'],
                  'userId': null,
                  'name': task['name'],
                  'deadline': task['deadline'],
                  'description': task['description'],
                  'reward': task['reward'],
                  'completed': task['completed'],
                  'completed_at': task['completedAt'],
                  'emoji': task['emoji'],
                  'private': task['private'],
                  'ownerId': task['owner']['id'],
                  'ownerForename': task['owner']['forename'],
                  'ownerSurname': task['owner']['surname'],
                })
            .toList(),
      };
      print(mappedUsers);
      print(mappedUsers);

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('useUserColor') == true) {
        userColor = Color.lerp(hexToColor(mappedUserData['colorPrimary']),
            hexToColor(mappedUserData['colorSecondary']), 0.5)!;
      } else {
        userColor = Theme.of(context).colorScheme.tertiary;
      }

      return {
        'users': mappedUsers,
        'tasks': mappedTasks,
        'routines': mappedRoutines,
        'userData': mappedUserData,
        'rewards': mappedRewards,
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
    'routines': [],
    'userData': {},
    'rewards': [],
  };
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

Future<void> deleteTask(int taskId) async {
  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql('''
      mutation DeleteTask(\$taskId: Int!) {
        deleteTask(taskId: \$taskId)
      }
    '''),
    variables: <String, dynamic>{
      'taskId': taskId,
    },
  );
  try {
    final result =
        await client.mutate(options).timeout(const Duration(seconds: 10));
    print(result.data);
    if (result.hasException) {
      print('GraphQL error: ${result.exception.toString()}');
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

Future<void> completeTask(int taskId) async {
  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql('''
    mutation CompleteTask(\$taskId: Int!) {
      completeTask(taskId: \$taskId) {
      }
    }
  '''),
    variables: <String, dynamic>{
      'taskId': taskId,
    },
  );
  try {
    final result =
        await client.mutate(options).timeout(const Duration(seconds: 10));
    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
    } else {}
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
  DateTime? deadline;

  // Check if 'deadline' is not null and is a String before parsing
  if (task['deadline'] != null && task['deadline'] is String) {
    try {
      deadline = DateTime.parse(task['deadline']);
    } catch (e) {
      // Handle the case where 'deadline' cannot be parsed into a DateTime
      print('Error parsing deadline: $e');
      // Return a default widget or handle the error appropriately
      return Builder(builder: (context) => const Text('Invalid deadline'));
    }
  } else {
    // Handle the case where 'deadline' is null or not a String
    return Builder(builder: (context) => const Text('No deadline'));
  }

  Widget green = SvgPicture.asset("assets/images/green.svg");
  Widget yellow = SvgPicture.asset("assets/images/yellow.svg");
  Widget red = SvgPicture.asset("assets/images/red.svg");
  Widget overdue = const Icon(CupertinoIcons.exclamationmark_circle,
      color: Colors.red, size: 23);

  return Builder(
    builder: (context) {
      if (deadline!.isBefore(now)) {
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

Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final Color colLight = const Color.fromARGB(255, 243, 243, 243);

  @override
  Widget build(BuildContext context) {
    checkLastLoginDate();
    return const Scaffold(body: MainView());
  }
}

class MainView extends StatefulWidget {
  const MainView({
    super.key,
  });

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late Future<Map<String, dynamic>> _futureUserData;

  @override
  void initState() {
    super.initState();
    _futureUserData = getHouseholdData(context);
  }

  void _updateUserData() {
    setState(() {
      _futureUserData = getHouseholdData(context);
    });
  }

  void _updateWithoutReload() {
    setState(() {});
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
          } else if (snapshot.data!['userData']['householdId'] == null) {
            return const JoinHouseholdView();
          } else {
            tasks = List<Map<String, dynamic>>.from(
                snapshot.data!['userData']['tasks']);
            userData = snapshot.data!['userData'];
            return SingleChildScrollView(
                child: Padding(
                    padding:
                        const EdgeInsets.only(top: 80, left: 40, right: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IconRow(),
                        // const NotificationCentre(),
                        const WelcomeText(),
                        ButtonRow(tasks: tasks),
                        //ButtonRecommended(),
                        const TaskOverview(),
                      ],
                    )));
          }
        });
  }
}

class IconRow extends StatefulWidget {
  const IconRow({super.key});

  @override
  State<IconRow> createState() => _IconRowState();
}

class _IconRowState extends State<IconRow> {
  final double padding = 20;

  final double size = 30;

  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
    final Color colorPrimary = hexToColor(userData['colorPrimary']);
    final Color colorSecondary = hexToColor(userData['colorSecondary']);
    // slider in den einstellungen
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: padding),
                child: SizedBox(
                  height: 45,
                  width: 45,
                  child: TextButton(
                    style: ButtonStyle(
                        padding: WidgetStateProperty.all<EdgeInsets>(
                            EdgeInsets.zero)),
                    onPressed: () async {
                      var result = await Get.to(
                          () => ProfileView(userData: userData, tasks: tasks));
                      if (result != null) {
                        setState(() {
                          userData = result;
                        },);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorPrimary, colorSecondary],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Center(
                          child: Text(
                            userData['emoji'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.only(right: padding),
              //   child: IconButton(
              //     padding: EdgeInsets.zero,
              //     iconSize: size,
              //     onPressed: () {
              //       Get.to(() => Settings(userData: userData));
              //     },
              //     icon: Icon(
              //       CupertinoIcons.gear_solid,
              //       color: userColor,
              //     ),
              //   ),
              // ),
            ],
          ),
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                iconSize: size,
                onPressed: () async {
                  bool? result = await Get.to(() => MainShopView(userData: userData));
                  if (result == true) {
                    print("main page was updated");
                    update();
                  }
                },
                icon: Icon(
                  CupertinoIcons.cart_fill,
                  color: userColor,
                  size: size,
                ),
              ),
              SizedBox(width: 5),
              IconButton(
                padding: EdgeInsets.zero,
                iconSize: size,
                onPressed: () async {
                  await Get.to(() => MainHouseholdOverview(
                        pUserData: userData,
                      ));
                  update();
                },
                icon: Icon(
                  CupertinoIcons.house_fill,
                  color: userColor,
                  size: size,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> completedTasks =
    tasks.where((task) => task['completed'] == false).toList();

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 40, top: 10),
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
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('Recommended'.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall),
          ),
        ),
        Padding(
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
                              : '${'No_tasks_found_txt'.tr} \n ${'Nice_day!_txt'.tr}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
            child: GestureDetector(
              onTap: () {
                // Navigate to another screen
              },
              child: ButtonShort(
                number: tasks == [] ? '0' : countToDo(tasks).toString(),
                textBelow: 'left_to_do_txt'.tr,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
              onTap: () {
                // Navigate to another screen
              },
              child: ButtonShort(
                number: tasks == []
                    ? '0'
                    : (tasks.length - countToDo(tasks)).toString(),
                textBelow: 'doneThisWeek_txt'.tr,
              ),
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
  bool showTasks = true;
  bool showRoutines = true;
  bool showOtherTasks = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleTasks() {
    setState(() {
      showTasks = !showTasks;
    });
  }

  void _toggleRoutines() {
    setState(() {
      showRoutines = !showRoutines;
    });
  }

  void _toggleOtherTasks() {
    setState(() {
      showOtherTasks = !showOtherTasks;
    });
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

  List<Map<String, dynamic>> otherTasks = userData['otherTasks']
      .where((task) => task['completed'] == false)
      .toList();

  @override
  Widget build(BuildContext context) {
    otherTasks.sort((a, b) {
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
    print(userData['otherTasks']);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(0))),
                onPressed: () {
                  _toggleTasks();
                },
                child: Row(
                  children: [
                    Icon(
                        showTasks
                            ? CupertinoIcons.arrow_down
                            : CupertinoIcons.arrow_up,
                        color: userColor,
                        size: 25),
                    const SizedBox(width: 5),
                    Text('${'Your_txt'.tr} Tasks',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  var result =
                      await Get.to(() => NewTaskMain(userData: userData));
                  if (result != null) {
                    update();
                  }
                },
                icon: Icon(CupertinoIcons.add, color: userColor, size: 30),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   height: 50,
            //   decoration: BoxDecoration(
            //     color: const Color(0x7FD9D9D9),
            //     borderRadius: BorderRadius.circular(7),
            //   ),
            //   child: Stack(
            //     children: [
            //       AnimatedAlign(
            //         alignment: _taskView
            //             ? Alignment.centerLeft
            //             : Alignment.centerRight,
            //         duration: const Duration(milliseconds: 200),
            //         curve: Curves.easeInOut,
            //         child: Container(
            //           width: MediaQuery.of(context).size.width / 2 - 40,
            //           height: 50,
            //           decoration: BoxDecoration(
            //             color: const Color(0xFFD9D9D9),
            //             borderRadius: BorderRadius.circular(7),
            //           ),
            //         ),
            //       ),
            //       Row(
            //         children: [
            //           Expanded(
            //             child: Center(
            //               child: TextButton(
            //                 onPressed: () {
            //                   setState(() {
            //                     _taskView = true;
            //                   });
            //                 },
            //                 child: Text('task view',
            //                     style: _taskView
            //                         ? Theme.of(context)
            //                             .textTheme
            //                             .bodySmall
            //                             ?.copyWith(
            //                               fontWeight: FontWeight.bold,
            //                               color: Theme.of(context)
            //                                   .colorScheme
            //                                   .inversePrimary,
            //                             )
            //                         : Theme.of(context)
            //                             .textTheme
            //                             .bodySmall
            //                             ?.copyWith(
            //                                 color: Theme.of(context)
            //                                     .colorScheme
            //                                     .inversePrimary)),
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             child: Center(
            //               child: TextButton(
            //                 onPressed: () {
            //                   setState(() {
            //                     _taskView = false;
            //                   });
            //                 },
            //                 child: Text('routine view',
            //                     style: _taskView
            //                         ? Theme.of(context)
            //                             .textTheme
            //                             .bodySmall
            //                             ?.copyWith(
            //                               color: Theme.of(context)
            //                                   .colorScheme
            //                                   .inversePrimary,
            //                             )
            //                         : Theme.of(context)
            //                             .textTheme
            //                             .bodySmall
            //                             ?.copyWith(
            //                                 fontWeight: FontWeight.bold,
            //                                 color: Theme.of(context)
            //                                     .colorScheme
            //                                     .inversePrimary)),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            Column(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  toDo.isEmpty
                      ? showTasks
                          ? Column(
                              children: [
                                TextButton(
                                  style: ButtonStyle(
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              const EdgeInsets.all(0))),
                                  child: Text(
                                    'NoTaskCreateOne_txt'.tr,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  onPressed: () async {
                                    var result = await Get.to(
                                        () => NewTaskMain(userData: userData));
                                    if (result != null) {
                                      update();
                                    }
                                  },
                                ),
                                OtherTasks(otherTasks: otherTasks),
                              ],
                            )
                          : Container()
                      : showTasks
                          ? Column(
                              children: [
                                Column(
                                  children: toDo
                                      .asMap()
                                      .map((index, task) {
                                        if (index == 0 && toDo.length > 1) {
                                          return MapEntry(
                                              index,
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "Recommended_txt"
                                                          .tr
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelSmall
                                                          ?.copyWith(
                                                              fontSize: 16)),
                                                  const SizedBox(height: 10),
                                                  Dismissible(
                                                    direction: DismissDirection
                                                        .horizontal,
                                                    key: ValueKey(task['id']),
                                                    onDismissed:
                                                        (direction) async {
                                                      if (direction ==
                                                          DismissDirection
                                                              .endToStart) {
                                                        showCupertinoDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              CupertinoAlertDialog(
                                                            title: Text(
                                                                "${"${'Delete_Task_txt'.tr} " + task['name']}?"),
                                                            content: Text(
                                                                'Sure_delete_task?_txt'
                                                                    .tr),
                                                            actions: [
                                                              CupertinoDialogAction(
                                                                  child: Text(
                                                                      'Cancel_txt'
                                                                          .tr,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.blue)),
                                                                  onPressed: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    update();
                                                                  }),
                                                              CupertinoDialogAction(
                                                                onPressed:
                                                                    () async {
                                                                  Get.back();
                                                                  await deleteTask(
                                                                      task[
                                                                          'id']);
                                                                  update();
                                                                },
                                                                isDestructiveAction:
                                                                    true,
                                                                child: Text(
                                                                    'Delete_txt'
                                                                        .tr,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .red)),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        // addPoints(
                                                        //     task['reward'].toString());
                                                        showCupertinoDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return CupertinoAlertDialog(
                                                              title: Text(
                                                                  'Congratulations!_txt'
                                                                      .tr),
                                                              content:
                                                                  const Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  SizedBox(
                                                                      height:
                                                                          10),
                                                                  // Image.network(
                                                                  //   "https://i.giphy.com/media/Wvh1de6cFXcWc/200.gif",
                                                                  //   scale: 1.3,
                                                                  // ),
                                                                ],
                                                              ),
                                                              actions: [
                                                                CupertinoDialogAction(
                                                                  child: const Text(
                                                                      'OK',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                      )),
                                                                  onPressed:
                                                                      () async {
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
                                                    secondaryBackground:
                                                        Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 30,
                                                              bottom: 22),
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: const Icon(
                                                          CupertinoIcons.delete,
                                                          color: Colors.red,
                                                          size: 30),
                                                    ),
                                                    background: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 30,
                                                              bottom: 22),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: const Icon(
                                                          CupertinoIcons
                                                              .check_mark,
                                                          color: purple,
                                                          size: 30),
                                                    ),
                                                    child: Task(
                                                      task: task,
                                                      userData: userData,
                                                      isRecommended: true,
                                                    ),
                                                  ),
                                                  Divider(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    thickness: 2,
                                                  ),
                                                ],
                                              )); // Assuming CustomFirstTaskWidget is your custom widget for the first item
                                        } else {
                                          return MapEntry(
                                              index,
                                              Column(
                                                children: [
                                                  const SizedBox(height: 10),
                                                  Dismissible(
                                                    direction: DismissDirection
                                                        .horizontal,
                                                    key: ValueKey(task['id']),
                                                    onDismissed:
                                                        (direction) async {
                                                      if (direction ==
                                                          DismissDirection
                                                              .endToStart) {
                                                        showCupertinoDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              CupertinoAlertDialog(
                                                            title: Text(
                                                                "${"${'Delete_Task_txt'.tr} " + task['name']}?"),
                                                            content: Text(
                                                                'Sure_delete_task?_txt'
                                                                    .tr),
                                                            actions: [
                                                              CupertinoDialogAction(
                                                                  child: Text(
                                                                      'Cancel_txt'
                                                                          .tr,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.blue)),
                                                                  onPressed: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    update();
                                                                  }),
                                                              CupertinoDialogAction(
                                                                onPressed:
                                                                    () async {
                                                                  await deleteTask(
                                                                      task[
                                                                          'id']);
                                                                  Get.back();
                                                                  update();
                                                                },
                                                                isDestructiveAction:
                                                                    true,
                                                                child: Text(
                                                                    'Delete_txt'
                                                                        .tr,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .red)),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        print(
                                                            "${'Task_completed!_txt'.tr} ${task['reward']}");
                                                        tasks.removeWhere((t) =>
                                                            t['id'] ==
                                                            task['id']);
                                                        completeTask(
                                                            task['id']);
                                                        // addPoints(
                                                        //     task['reward'].toString());
                                                        showCupertinoDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return CupertinoAlertDialog(
                                                              title: Text(
                                                                  'Congratulations!_txt'
                                                                      .tr),
                                                              content:
                                                                  const Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  SizedBox(
                                                                      height:
                                                                          10),
                                                                  // Image.network(
                                                                  //   "https://i.giphy.com/media/Wvh1de6cFXcWc/200.gif",
                                                                  //   scale: 1.3,
                                                                  // ),
                                                                ],
                                                              ),
                                                              actions: [
                                                                CupertinoDialogAction(
                                                                  child: const Text(
                                                                      'OK',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                      )),
                                                                  onPressed:
                                                                      () async {
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
                                                    secondaryBackground:
                                                        Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 30,
                                                              bottom: 22),
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: const Icon(
                                                          CupertinoIcons.delete,
                                                          color: Colors.red,
                                                          size: 30),
                                                    ),
                                                    background: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 30,
                                                              bottom: 22),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: const Icon(
                                                          CupertinoIcons
                                                              .check_mark,
                                                          color: purple,
                                                          size: 30),
                                                    ),
                                                    child: Task(
                                                      task: task,
                                                      userData: userData,
                                                      isRecommended: false,
                                                    ),
                                                  ),
                                                ],
                                              ));
                                        }
                                      })
                                      .values
                                      .toList(),
                                ),
                                OtherTasks(otherTasks: otherTasks),
                                // Column(
                                //   children: toDo.map((task) {
                                //     return Dismissible(
                                //       direction: DismissDirection.horizontal,
                                //       key: ValueKey(task['id']),
                                //       onDismissed: (direction) async {
                                //         if (direction ==
                                //             DismissDirection.endToStart) {
                                //           showCupertinoDialog(
                                //             context: context,
                                //             builder: (BuildContext context) =>
                                //                 CupertinoAlertDialog(
                                //               title: Text(
                                //                   "${"${'Delete_Task_txt'.tr} " + task['name']}?"),
                                //               content:
                                //                   Text('Sure_delete_task?_txt'.tr),
                                //               actions: [
                                //                 CupertinoDialogAction(
                                //                     child: Text('Cancel_txt'.tr,
                                //                         style: const TextStyle(
                                //                             color: Colors.blue)),
                                //                     onPressed: () {
                                //                       Navigator.pop(context);
                                //                       update();
                                //                     }),
                                //                 CupertinoDialogAction(
                                //                   onPressed: () async {
                                //                     await deleteTask(task['id']);
                                //                     Get.back();
                                //                     update();
                                //                   },
                                //                   isDestructiveAction: true,
                                //                   child: Text('Delete_txt'.tr,
                                //                       style: const TextStyle(
                                //                           color: Colors.red)),
                                //                 ),
                                //               ],
                                //             ),
                                //           );
                                //         } else {
                                //           print(
                                //               "${'Task_completed!_txt'.tr} ${task['reward']}");
                                //           tasks.removeWhere(
                                //               (t) => t['id'] == task['id']);
                                //           completeTask(task['id']);
                                //           // addPoints(
                                //           //     task['reward'].toString());
                                //           showCupertinoDialog(
                                //             context: context,
                                //             builder: (BuildContext context) {
                                //               return CupertinoAlertDialog(
                                //                 title:
                                //                     Text('Congratulations!_txt'.tr),
                                //                 content: Column(
                                //                   mainAxisAlignment:
                                //                       MainAxisAlignment.center,
                                //                   children: [
                                //                     const SizedBox(height: 10),
                                //                     Image.network(
                                //                       "https://i.giphy.com/media/Wvh1de6cFXcWc/200.gif",
                                //                       scale: 1.3,
                                //                     ),
                                //                   ],
                                //                 ),
                                //                 actions: [
                                //                   CupertinoDialogAction(
                                //                     child: const Text('OK',
                                //                         style: TextStyle(
                                //                           color: Colors.blue,
                                //                         )),
                                //                     onPressed: () async {
                                //                       Navigator.pop(context);
                                //                       update();
                                //                     },
                                //                   ),
                                //                 ],
                                //               );
                                //             },
                                //           );
                                //         }
                                //       },
                                //       secondaryBackground: Container(
                                //         margin: const EdgeInsets.only(
                                //             right: 30, bottom: 22),
                                //         alignment: Alignment.centerRight,
                                //         child: const Icon(CupertinoIcons.delete,
                                //             color: Colors.red, size: 30),
                                //       ),
                                //       background: Container(
                                //         margin: const EdgeInsets.only(
                                //             left: 30, bottom: 22),
                                //         alignment: Alignment.centerLeft,
                                //         child: const Icon(CupertinoIcons.check_mark,
                                //             color: purple, size: 30),
                                //       ),
                                //       child: Task(task: task, userData: userData),
                                //     );
                                //   }).toList(),
                                // ),
                              ],
                            )
                          : Container(),
                  const SizedBox(height: 30),
                  // Divider(
                  //   color: Theme.of(context).colorScheme.secondary,
                  //   thickness: 2,
                  // ),
                ]),
                Row(
                  children: [
                    TextButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(0))),
                      onPressed: () => _toggleRoutines(),
                      child: Row(
                        children: [
                          Icon(
                              showRoutines
                                  ? CupertinoIcons.arrow_down
                                  : CupertinoIcons.arrow_up,
                              color: userColor,
                              size: 25),
                          const SizedBox(width: 5),
                          Text('${'Your_txt'.tr} Routines',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        var result =
                            await Get.to(() => NewRoutine(pUserData: userData));
                        if (result != null) {
                          update();
                        }
                      },
                      icon:
                          Icon(CupertinoIcons.add, color: userColor, size: 30),
                    ),
                  ],
                ),
                showRoutines ? Routine(userData: userData) : Container(),
                const SizedBox(height: 30),
                // Padding(
                //   padding: const EdgeInsets.only(top: 10, bottom: 60),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       TextButton(
                //         style: ButtonStyle(
                //             padding: MaterialStateProperty.all<EdgeInsets>(
                //                 const EdgeInsets.all(0))),
                //         onPressed: () async {
                //           await Get.to(
                //               () => MainHouseholdOverview(pUserData: userData));
                //           update();
                //         },
                //         child: Row(
                //           children: [
                //             Text('Household_Overview_txt'.tr,
                //                 style: Theme.of(context)
                //                     .textTheme
                //                     .labelSmall
                //                     ?.copyWith(fontSize: 18)),
                //             const SizedBox(width: 10),
                //             Icon(
                //               CupertinoIcons.house,
                //               color: Theme.of(context).colorScheme.tertiary,
                //               size: size,
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 50),
              ],
            )
          ],
        ),
      ],
    );
  }
}

class Task extends StatefulWidget {
  const Task(
      {super.key,
      required this.task,
      required this.userData,
      required this.isRecommended});

  final Map<String, dynamic> task;
  final Map<String, dynamic> userData;
  final bool isRecommended;

  @override
  State<Task> createState() => _MainTaskState();
}

class _MainTaskState extends State<Task> {
  @override
  @override
  void initState() {
    super.initState();
  }

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
                task: widget.task,
                userData: widget.userData,
                assigned: widget.userData['forename'],
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
                        child: Text(
                            widget.task['emoji'] != "" &&
                                    widget.task['emoji'] != null
                                ? '${widget.task['emoji']} ${widget.task['name']}'
                                : widget.task['name'],
                            style: widget.task['deadline'] != null &&
                                    DateTime.parse((widget.task['deadline']))
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
                          border: Border.all(width: 2, color: userColor),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              "${widget.task['reward']} pts",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: userColor,
                                  ),
                            ))),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: widget.task["deadline"] != null
                      ? getIndicator(widget.task, context)
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

class OtherTasks extends StatefulWidget {
  const OtherTasks({super.key, required this.otherTasks});

  final List<Map<String, dynamic>> otherTasks;

  @override
  State<OtherTasks> createState() => _OtherTasksState();
}

class _OtherTasksState extends State<OtherTasks> {
  bool showTasks = true;

  void updateView() {
    setState(() {
      showTasks = !showTasks;
      update();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.otherTasks.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(0))),
                    onPressed: () {
                      update();
                    },
                    child: Row(
                      children: [
                        Icon(
                            showTasks
                                ? CupertinoIcons.arrow_down
                                : CupertinoIcons.arrow_up,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 16),
                        const SizedBox(width: 3),
                        Text("Household tasks".toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(CupertinoIcons.info_circle,
                        size: 16,
                        color: Theme.of(context).colorScheme.tertiary),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: const Text('What are household tasks?'),
                          content: const Text(
                              'Household tasks are tasks that have no user that they\'re assigned to. You can claim them yourself or reassign them.'),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('OK',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
              showTasks
                  ? Column(
                      children: widget.otherTasks.map((task) {
                        return Column(
                          children: [
                            const SizedBox(height: 10),
                            Dismissible(
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
                                                style: const TextStyle(
                                                    color: Colors.blue)),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              update();
                                            }),
                                        CupertinoDialogAction(
                                          onPressed: () async {
                                            await deleteTask(task['id']);
                                            print("deleted task");
                                            Get.back();
                                            print("updating now");
                                            update();
                                          },
                                          isDestructiveAction: true,
                                          child: Text('Delete_txt'.tr,
                                              style: const TextStyle(
                                                  color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  print(
                                      "${'Task_completed!_txt'.tr} ${task['reward']}");
                                  tasks.removeWhere(
                                      (t) => t['id'] == task['id']);
                                  completeTask(task['id']);
                                  // addPoints(
                                  //     task['reward'].toString());
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: Text('Congratulations!_txt'.tr),
                                        content: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                margin: const EdgeInsets.only(
                                    right: 30, bottom: 22),
                                alignment: Alignment.centerRight,
                                child: const Icon(CupertinoIcons.delete,
                                    color: Colors.red, size: 30),
                              ),
                              background: Container(
                                margin:
                                    const EdgeInsets.only(left: 30, bottom: 22),
                                alignment: Alignment.centerLeft,
                                child: const Icon(CupertinoIcons.check_mark,
                                    color: purple, size: 30),
                              ),
                              child: Task(
                                task: task,
                                userData: userData,
                                isRecommended: false,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    )
                  : Container(),
            ],
          );
  }
}
