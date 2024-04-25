import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/household_tasks.dart';
import 'package:frontend_v1/login.dart';
import 'package:frontend_v1/main.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

String getDueDaysInText(int days) {
  if (days == 1) {
    return 'day_txt'.tr;
  } else {
    return 'days_txt'.tr;
  }
}

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
  print(' fetching $username\'s data');
  List<List<dynamic>> results = await connection.query(
      'SELECT users.forename, users.surname, users.username FROM users WHERE username = @username',
      substitutionValues: {'username': username});
  await connection.close();

  print(results);
  print(results.isNotEmpty);
  print(
    'SELECT users.forename, users.surname, users.username FROM users WHERE username = $username',
  );

  return results
      .map((row) => {
            'id': row[0],
            'forename': row[1],
            'surname': row[2],
            'username': row[3],
          })
      .toList();
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.username});

  final String username;

  static Route<dynamic> route({required String username}) {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return ProfileView(username: username);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackIconRow(username: username),
                  TextButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: const Text('Log out?'),
                            content: const Text(
                                'To access your tasks, you need to log in. Do you want to continue?'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text('Continue'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(LoginWidget.route());
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 204, 198, 196),
                        ),
                        child: const Padding(
                            padding: EdgeInsets.only(
                                top: 10, bottom: 10, left: 10, right: 10),
                            child: /*Text("log out",
                              style: TextStyle(
                                  height: 1,
                                  color: Color.fromARGB(255, 243, 243, 243),
                                  fontSize: 15,
                                  fontFamily: "Karla",
                                  fontWeight: FontWeight.w700)),*/
                                Icon(
                              CupertinoIcons.arrowshape_turn_up_right_fill,
                              color: Color.fromARGB(255, 243, 243, 243),
                              size: 20,
                            ))),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: const ShapeDecoration(
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 6,
                            color: Color.fromARGB(255, 114, 111, 110),
                          ),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                              "https://fakeimg.pl/200x200/f7f7f7/9c9390?font=bebas"),
                          fit: BoxFit.fill,
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50, right: 10),
                        child: _buildInfoContainer('1150 pts'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: _buildInfoContainer('lvl 25'),
                      ),
                    ],
                  ),
                ],
              ),
              // FutureBuilder<List<Map<String, dynamic>>>(
              //   future: fetchUser(username: username),
              //   builder: (context, snapshot) {
              //     return ListView.builder(
              //       shrinkWrap: true,
              //       physics: const NeverScrollableScrollPhysics(),
              //       itemCount: snapshot.data?.length,
              //       itemBuilder: (context, index) {
              //         return Column(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             Text(
              //               '${snapshot.data?[index]['forename']} ${snapshot.data?[index]['surname']}',
              //               style: const TextStyle(
              //                 color: Color(0xFF4A4646),
              //                 fontSize: 32,
              //                 fontWeight: FontWeight.w700,
              //               ),
              //           ),
              //           ],
              //         );
              //       },
              //     );
              //   },
              // ),
              // const Text(
              //   'Michelle Gerwald',
              //   style: TextStyle(
              //     color: Color(0xFF4A4646),
              //     fontSize: 32,
              //     fontWeight: FontWeight.w700,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: ('part_household'.tr),
                      style: const TextStyle(
                        color: Color(0xFF4A4646),
                        fontSize: 15,
                        fontFamily: 'Karla',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const TextSpan(
                      text: '"Campus Living"',
                      style: TextStyle(
                        color: Color(0xFF4A4646),
                        fontSize: 15,
                        fontFamily: 'Karla',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                '@michiee123',
                style: TextStyle(
                  color: Color(0xFF4A4646),
                  fontSize: 16,
                  fontFamily: 'Karla',
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(
                  color: Color(0xFFEDECEC), height: 100, thickness: 2),
              const TaskOverview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
      decoration: const BoxDecoration(
        color: Color(0xFFEDECEC),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF4A4646),
          fontSize: 24,
          fontFamily: 'Karla',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class BackIconRow extends StatelessWidget {
  const BackIconRow({super.key, required this.username});

  final String username;
  final double padding = 20;
  final double size = 40;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: padding),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                ),
                onPressed: () {
                Get.offAll(() => MainWidget(user: username));
                },
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.arrowtriangle_left_fill,
                    color: col,
                    size: 18,
                  ),
                  Container(width: 5),
                  // Icon(
                  //   CupertinoIcons.house_fill,
                  //   color: col,
                  //   size: 18,
                  // )
                  Text('back_button_text'.tr,
                      style: TextStyle(
                          color: Color.fromARGB(255, 204, 198, 196),
                          fontSize: 15,
                          fontFamily: "Karla",
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskOverview extends StatelessWidget {
  const TaskOverview({super.key});

  final double size = 15;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child:
              Text('Their Tasks', style: Theme.of(context).textTheme.bodyLarge),
        ),
        const Task(taskName: "do the dishes", taskStatus: 2),
        const Task(taskName: "mop the floor", taskStatus: 1),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
              TextButton(
                onPressed: () {
                  Get.to(const MainHouseholdOverview());
                },
                child: Icon(
                  CupertinoIcons.house,
                  color: col,
                  size: size,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
