import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

class SeeAllTasks extends StatelessWidget {
  const SeeAllTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Padding(
      padding: EdgeInsets.only(top: 80, left: 40, right: 40),
      child: Column(
        children: [
          BackIconRow(),
          SliderWidgetRepeat(),
        ],
      ),
    ));
  }
}

class SliderWidgetRepeat extends StatefulWidget {
  const SliderWidgetRepeat({super.key});

  @override
  State<SliderWidgetRepeat> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidgetRepeat> {
  bool _isPermanent = true;

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
          Text('All_Tasks_txt'.tr,
              style: Theme.of(context).textTheme.bodyLarge),
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
                  alignment: _isPermanent
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
                        child: Text(
                          'task_view_txt'.tr,
                          style: TextStyle(
                            color: _isPermanent
                                ? Colors.black
                                : const Color(0xFF4A4646),
                            fontSize: 20,
                            fontFamily: 'Karla',
                            fontWeight: _isPermanent
                                ? FontWeight.w700
                                : FontWeight.w300,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'routine_view_txt'.tr,
                          style: TextStyle(
                            color: !_isPermanent
                                ? Colors.black
                                : const Color(0xFF4A4646),
                            fontSize: 20,
                            fontFamily: 'Karla',
                            fontWeight: !_isPermanent
                                ? FontWeight.w700
                                : FontWeight.w300,
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
              children:
                  _isPermanent ? [const TaskWidget()] : [const RoutineWidget()],
            ),
          )
        ],
      ),
    );
  }
}

class TaskWidget extends StatelessWidget {
  const TaskWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Tasks_txt'.tr);
  }
}

class RoutineWidget extends StatelessWidget {
  const RoutineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Routines_txt'.tr);
  }
}
