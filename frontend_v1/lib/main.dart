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
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LoginApp());
}

Map<String, dynamic> userData = {};

bool auth = false;

Future<GraphQLClient> getGraphQLClient() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final HttpLink httpLink = HttpLink(
    'http://localhost:3000/graphql',
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer $token',
  );

  final Link link = authLink.concat(httpLink);

  return GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );
}

Future<Map<String, dynamic>> getUserData(int id) async {
  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql('''
      query GetUser(\$id: ID!) {
        user(id: \$id) {
          id
          householdId
          forename
          surname
          username
          password
          email
          balance
          household {
            name
            ownerId
          }
        }
      }
    '''),
    variables: <String, dynamic>{
      'id': id,
    },
  );

  final result = await client.query(options);

  if (result.hasException) {
    print(result.exception.toString());
  } else if (result.isLoading) {
    print('Loading');
  } else {
    final user = result.data!['user'];
    final mappedResult = {
      'id': user['id'],
      'forename': user['forename'],
      'surname': user['surname'],
      'username': user['username'],
      'email': user['email'],
      'balance': user['balance'],
      'householdName': user['household']['name'],
    };
    print('Mapped user data: $mappedResult');
    return mappedResult;
  }
  return {};
}

Future<void> loadUserData(int id) async {
  userData = await getUserData(id);
}

class MainWidget extends StatelessWidget {
  const MainWidget({super.key, required this.userId});

  final int userId;
  final Color colLight = const Color.fromARGB(255, 243, 243, 243);

  @override
  Widget build(BuildContext context) {
  loadUserData(userId);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const IconRow(),
            WelcomeText(userData: userData),
            const ButtonRecommended(task: "do the dishes"),
            TaskOverview(userData: userData),
          ]),
        ),
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
      padding: const EdgeInsets.only(bottom: 10),
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
                    Get.to(() => ProfileView(userData: userData));
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

// TextWidget
class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key, required this.userData});

  final  Map<String, dynamic>? userData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 50, top: 10),
            child: SizedBox(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${'welcome_title'.tr}, ${userData?['forename']}!',
                              maxLines: 2,
                              style: Theme.of(context).textTheme.bodyLarge),
                          Text('welcome_message'.tr,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      );
                    },
                  ),)),
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Recommended_txt'.tr,
                  style: Theme.of(context).textTheme.labelSmall),
            )),
      ],
    );
  }
}

// ButtonWidget
class ButtonRecommended extends StatelessWidget {
  const ButtonRecommended({super.key, required this.task});

  final String task;
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
                ]),
            child: Column(
                //color: Colors.amber,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(task,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 30)),
                          ),
                        ],
                      )),
                ]),
          ),
        ],
      )),
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
              ]),
          child: Column(
              //color: Colors.amber,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 35, right: 35),
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: "$who completed",
                                  style: Theme.of(context).textTheme.bodySmall,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: " \"$what\" ",
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                    TextSpan(
                                      text: "$time.",
                                    )
                                  ]
                                  )),
                        ),
                      ],
                    )),
              ]),
        ),
        const SizedBox(height: 30)
      ],
    ));
  }
}

class ButtonShort extends StatelessWidget {
  const ButtonShort({super.key, required this.number, required this.textBelow});

  final double height = 150;
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
              ]),
          child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    number,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 60),
                    maxLines: 2,
                    
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    child: Text(textBelow,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2),
                  )
                ],
              )),
        ),
        const SizedBox(height: 30)
      ],
    ));
  }
}

//ButtonRow containing Button Widgets
class ButtonRow extends StatelessWidget {
  const ButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Row(
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: ButtonShort(
            number: "10",
            textBelow: 'leftThisWeek_txt'.tr,
          ),
        )),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: ButtonShort(
            number: "2",
            textBelow: ('doneThisWeek_txt'.tr),
          ),
        )),
      ],
    ));
  }
}

class TaskOverview extends StatefulWidget {
  const TaskOverview({super.key, required this.userData});

  
  final Map<String, dynamic> userData;

  @override
  State<TaskOverview> createState() => _TaskState(userData: userData);
}

class _TaskState extends State<TaskOverview> {
  _TaskState({required this.userData});
  final double size = 15;
  final Map<String, dynamic> userData;


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
                    Get.to(()=> NewTask(userData: userData));
                  },
                  child: Icon(CupertinoIcons.add, color: Theme.of(context).colorScheme.tertiary, size: 30))
            ],
          ),
        ),
        Container(height: 10),
        const ButtonRow(),
        const Task(taskName: "do the dishes", taskStatus: 2),
        const Task(taskName: "mop the floor", taskStatus: 1),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Get.to(()=> const SeeAllTasks());
                },
                child: Row(
                  children: [
                    Text('SeeAllTasks_txt'.tr,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 15)),
                    Container(width: 5),
                    Icon(
                      CupertinoIcons.arrow_right,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: size,
                    )
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => MainHouseholdOverview(userData: userData));
                },
                child: Row(
                  children: [
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
    );
  }
}

class Task extends StatelessWidget {
  const Task({super.key, required this.taskName, required this.taskStatus});

  final String taskName;
  final int taskStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
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
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 30, left: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(taskName, style: Theme.of(context).textTheme.bodySmall),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Builder(builder: (context) {
                  switch (taskStatus) {
                    case 0:
                      return SvgPicture.asset("assets/images/green.svg");
                    case 1:
                      return SvgPicture.asset("assets/images/yellow.svg");
                    case 2:
                      return SvgPicture.asset("assets/images/red.svg");
                    default:
                      return SvgPicture.asset("assets/images/red.svg");
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
