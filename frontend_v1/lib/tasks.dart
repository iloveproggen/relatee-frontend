import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:frontend_v1/main.dart' as main;

class SeeAllTasks extends StatelessWidget {
  const SeeAllTasks({super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Padding(
      padding: EdgeInsets.only(top: 80, left: 40, right: 40),
      child: Column(
        children: [
          BackIconRow(),
          SliderWidgetRepeat(userData: userData, tasks: tasks),
        ],
      ),
    ));
  }
}

class SliderWidgetRepeat extends StatefulWidget {
  const SliderWidgetRepeat({super.key, required this.userData, required this.tasks});


  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  @override
  State<SliderWidgetRepeat> createState() => _SliderWidgetState(userData: userData, tasks: tasks);
}

class _SliderWidgetState extends State<SliderWidgetRepeat> {
  _SliderWidgetState({required this.userData, required this.tasks});
  bool _isPermanent = true;


  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPermanent = !_isPermanent;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("All Tasks", style: Theme.of(context).textTheme.bodyLarge),
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
                  alignment:
                      _isPermanent ? Alignment.centerLeft : Alignment.centerRight,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2 -40,
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
                        child: Text(
                          'task view',
                          style: TextStyle(
                            color: _isPermanent
                                ? Colors.black
                                : const Color(0xFF4A4646),
                            fontSize: 20,
                            fontFamily: 'Karla',
                            fontWeight:
                                _isPermanent ? FontWeight.w700 : FontWeight.w300,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'routine view',
                          style: TextStyle(
                            color: !_isPermanent
                                ? Colors.black
                                : const Color(0xFF4A4646),
                            fontSize: 20,
                            fontFamily: 'Karla',
                            fontWeight:
                                !_isPermanent ? FontWeight.w700 : FontWeight.w300,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: _isPermanent
                  ? [TaskWidget(userData: userData, tasks: tasks)]
                  : [const RoutineWidget()],
            ),
          )
        ],
      ),
    );
  }
}

class TaskWidget extends StatelessWidget {
  const TaskWidget({super.key, required this.userData, required this.tasks});

  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tasks;

  @override
  Widget build(BuildContext context) {
    return main.TaskOverview(userData: userData, tasks: tasks);
  }
}

class RoutineWidget extends StatelessWidget {
  const RoutineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Routines");
  }
}