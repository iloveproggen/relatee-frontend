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
import 'package:postgres/postgres.dart';

void main() {
  runApp(const LoginApp());
}
//hi Michelle bug fising
//hi maurice
// MainWidget

bool auth = false;

Future<List<Map<String, dynamic>>> fetchUser({required String username}) async {
  final connection = PostgreSQLConnection(
    'ep-bold-snow-a2unxsbb.eu-central-1.aws.neon.tech',
    5432,
    'relateeDB',
    username: 'relateeDB_owner',
    password: 'bCTNHdw8mJL3',
    useSSL: true,
  );
  await connection.open();
  print('fetching $username\'s data');
  List<List<dynamic>> results = await connection.query(
      'SELECT users.id, users.forename, users.surname, users.username, users.email, users.balance, households.name FROM users JOIN households ON users."householdId" = households.id WHERE users.username = @username;',
      substitutionValues: {'username': username});
  await connection.close();

  List<Map<String, dynamic>> mappedResults = results
      .map((row) => {
            'id':row[0],
            'forename': row[1],
            'surname': row[2],
            'username': row[3],
            'email': row[4],
            'balance': row[5],
            'householdName': row[6],
          })
      .toList();

  print(mappedResults);
  return mappedResults;
}


class MainWidget extends StatelessWidget {
  const MainWidget({super.key, required this.user});

  final String user;
  final Color colLight = const Color.fromARGB(255, 243, 243, 243);

  @override
  Widget build(BuildContext context) {
  final Future<List<Map<String, dynamic>>> userData = fetchUser(username: user);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconRow(
              userData: userData,
            ),
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
  const IconRow({super.key, required this.userData});

  final Future<List<Map<String, dynamic>>> userData;
  

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
                  onPressed: () async {
                    Get.to(() => ProfileView(userData: userData));
                    List<Map<String, dynamic>> userDataList = await userData; 
                    print(userDataList[0]['username']);
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

  final  Future<List<Map<String, dynamic>>> userData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 50, top: 10),
            child: SizedBox(
                child: FutureBuilder<List<Map<String, dynamic>>>(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: Color.fromARGB(255, 204, 198, 196),
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                  );
                } else if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'welcome_title'.tr}, hackerman!!!!',
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      Text('welcome_message'.tr,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${'welcome_title'.tr}, ${snapshot.data?[index]['forename']}!',
                              maxLines: 2,
                              style: const TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold)),
                          Text('welcome_message'.tr,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      );
                    },
                  );
                }
              },
            ))),
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Recommended_txt'.tr,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 204, 198, 196),
                      fontSize: 20,
                      fontFamily: "Karla",
                      fontWeight: FontWeight.bold)),
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
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(task,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontFamily: "Karla",
                                  //fontWeight: FontWeight.bold
                                )),
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
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 74, 70, 70),
                                      fontFamily: "Karla",
                                      fontSize: 25),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: " \"$what\" ",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                      text: "$time.",
                                    )
                                  ]
                                  //fontWeight: FontWeight.bold
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
          child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Karla"),
                    maxLines: 2,
                    
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    child: Text(textBelow,
                        style: const TextStyle(
                            fontSize: 20,
                            height: 1,
                            fontFamily: "Karla",
                            letterSpacing: -0.5),
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

  
  final Future<List<Map<String, dynamic>>> userData;

  @override
  State<TaskOverview> createState() => _TaskState(userData: userData);
}

class _TaskState extends State<TaskOverview> {
  _TaskState({required this.userData});
  final double size = 15;
  final Color col = const Color.fromARGB(255, 204, 198, 196);
  final Future<List<Map<String, dynamic>>> userData;


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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${'Your_txt'.tr} Tasks',
                  style: Theme.of(context).textTheme.bodyLarge),
              TextButton(
                  onPressed: () {
                    Get.to(()=> NewTask(userData: userData));
                  },
                  child: Icon(CupertinoIcons.add, color: col, size: 35))
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
                        style: TextStyle(
                            color: const Color.fromARGB(255, 204, 198, 196),
                            fontSize: size,
                            fontFamily: "Karla",
                            fontWeight: FontWeight.w500)),
                    Container(width: 5),
                    Icon(
                      CupertinoIcons.arrow_right,
                      color: col,
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
                      color: col,
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
  /*final Widget green = SvgPicture.asset("assets/images/green.svg");
  final Widget yellow = SvgPicture.asset("assets/images/yellow.svg");
  final Widget red = SvgPicture.asset("assets/images/red.svg");*/

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
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
