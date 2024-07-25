import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_v1/main.dart' as main;
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

String getDueDaysInText(int days) {
  if (days == 1) {
    return 'day_txt'.tr;
  } else {
    return 'days_txt'.tr;
  }
}

class PublicProfile extends StatelessWidget {
  PublicProfile({super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  final List<int> levelList = [
    0,
    200,
    400,
    600,
    800,
    1000,
    1300,
    1600,
    1900,
    2200,
    2400,
    2700,
    3000,
    3400,
    3800,
    4200,
    4600,
    5000,
    5500,
    6000,
    6500,
    7000,
    7600,
    8200,
    8800,
    9400,
    10000,
    11000,
    12000,
    13500,
  ];

  //get correct next level xp
  int getLevelProgress() {
    // Use the null-aware operator `??` to provide a default value if `widget.userData['level']` is null
    int level = userData['level'] ?? 0;
    // Check if `levelList` contains the key before accessing it to prevent a runtime error
    // Provide a default value if the key is not found
    return levelList[level];
  }

  int getPreviousLevelProgress() {
    // Use the null-aware operator `??` to provide a default value if `widget.userData['level']` is null
    int level = userData['level'] - 1 ?? 0;
    // Check if `levelList` contains the key before accessing it to prevent a runtime error
    // Provide a default value if the key is not found
    return levelList[level + 1] - levelList[level];
  }

  //to get the previous level progress
  double getPreviousLevelProgressValue() {
    int experience = userData['experience'] ?? 0;
    // Ensure `getLevelProgress` does not return null or 0 to avoid division by zero error
    int levelProgress = getPreviousLevelProgress();
    if (levelProgress == 0) {
      return 0.0; // Return 0.0 or handle appropriately if level progress is 0 to avoid division by zero
    }
    return ((experience - levelList[userData['level'] - 1]) /
            levelProgress)
        .toDouble();
  }

  double getLevelProgressValue() {
    int experience = userData['experience'] ?? 0;
    // Ensure `getLevelProgress` does not return null or 0 to avoid division by zero error
    int levelProgress = getLevelProgress();
    if (levelProgress == 0) {
      return 0.0; // Return 0.0 or handle appropriately if level progress is 0 to avoid division by zero
    }
    return (experience / levelProgress).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final String avatar = userData['emoji'];
    final Color colorPrimary =
        Color(int.parse('0xFF' + userData['colorPrimary'].replaceAll('#', '')));
    final Color colorSecondary = Color(
        int.parse('0xFF' + userData['colorSecondary'].replaceAll('#', '')));
    print(userData);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BackIconRow(),
              Column(
                children: [
                  //Profile Picture
                  SizedBox(
                    height: 200,
                    width: 200,
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //   width: 7,
                    //   color: Theme.of(context).colorScheme.onPrimary,
                    //   strokeAlign: BorderSide.strokeAlignOutside
                    //   ),
                    //   borderRadius: BorderRadius.circular(100),
                    // ),
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorPrimary, colorSecondary],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Center(
                          child: Text(
                            avatar,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 130,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                        '${userData['forename'] ?? ""} ${userData['surname'] ?? ""}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 20),
                    
                    // Padding(
                    //       padding: const EdgeInsets.only(left: 30, right: 30),
                    //       child: Stack(
                    //         children: <Widget>[
                    //           Container(
                    //             height: 10,
                    //             decoration: BoxDecoration(
                    //               color: Theme.of(context)
                    //                   .colorScheme
                    //                   .tertiary, // White background for the empty part
                    //               borderRadius: BorderRadius.circular(10),
                    //             ),
                    //           ),
                              
                    //           LayoutBuilder(
                    //             builder: (BuildContext context,
                    //                 BoxConstraints constraints) {
                    //               double progressWidth = constraints.maxWidth *
                    //                   (userData['level'] <= 1
                    //                       ? getLevelProgressValue()
                    //                       : getPreviousLevelProgressValue()); // Calculate width based on progress
                    //               return Container(
                    //                 width: progressWidth,
                    //                 height: 10,
                    //                 decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(10),
                    //                   gradient: LinearGradient(
                    //                     colors: [
                    //                       colorPrimary,
                    //                       colorSecondary,
                    //                     ],
                    //                     begin: Alignment.centerLeft,
                    //                     end: Alignment.centerRight,
                    //                   ),
                    //                 ),
                    //               );
                    //             },
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     Text(
                    //         '${'Progress_1_txt'.tr}${userData['experience']} xp ${'Progress_2_txt'.tr}${getLevelProgress()} xp.',
                    //         style: Theme.of(context).textTheme.labelSmall),
                    //     const SizedBox(height: 20),
                    Text(
                      '@${userData['username']}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: ('part_household'.tr),
                              style: Theme.of(context).textTheme.bodySmall),
                          TextSpan(
                              text: '"${userData['householdName']}"',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    userData['streak'] >= 1 
                      ? Text(
                          "🔥${(userData['forename'] != null && userData['forename'] != '') ? userData['forename'] + " has" : "They have"} a streak of ${userData['streak'].toString()}! 🔥",
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : Container(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 27, vertical: 9),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/images/relatee.svg",
                                height: 20,
                                width: 20,
                                color: Color.lerp(
                                    hexToColor(userData['colorPrimary']),
                                    hexToColor(userData['colorSecondary']),
                                    0.5)!,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '${userData['coins']}',
                                textAlign: TextAlign.center,
                                style:Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 27, vertical: 9),
                          decoration:  BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text(
                            'lvl ${userData['level']}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                          ),
                        ),
                        SizedBox(height: 5),
                        
                        //Text('Progress_txt'.tr(args: {'Experience': '20', 'Total': '100'}),
                        
                      ],
                    ),
                  ],
                )
              ]),
              // const Divider(
              //     color: Color.fromARGB(238, 126, 126, 126),
              //     height: 100,
              //     thickness: 2),
              SizedBox(height: 80),
              PublicTaskOverview(userData: userData, tasks: tasks),
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

class PublicTaskOverview extends StatelessWidget {
  const PublicTaskOverview(
      {super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  final double size = 15;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> taskLeft =
        tasks.where((task) => task['completed'] == false).toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: Text('Their Tasks',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        taskLeft.isNotEmpty
            ? Column(
                children: taskLeft.map((task) {
                  return main.Task(
                    task: task,
                    userData: userData,
                    isRecommended: false,
                                showAssignedUser: false,
                  );
                }).toList(),
              )
            : Column(
                children: [
                  Text("This user currently has no tasks assigned to them.",
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
      ],
    );
  }
}
