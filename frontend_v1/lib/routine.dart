import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'task_item_view.dart';

class Routine extends StatelessWidget {
  const Routine({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Routines_txt'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.left,
        ),
        Routinenitems(
          routineName: 'SuperTest idk',
          routineDescription: 'ist toll weiol darum bitte nicht sclagen',
        ),
        Routinenitems(
            routineName: 'Das ist ein toller Titel',
            routineDescription: 'routineDescription')
      ],
    );
  }
}

class Routinenitems extends StatelessWidget {
  const Routinenitems({
    super.key,
    required this.routineName,
    required this.routineDescription,
  });

  final Color colLight = const Color.fromARGB(255, 243, 243, 243);
  final Color colMid = const Color.fromARGB(255, 204, 198, 196);
  final Color colText = const Color(0xFF4A4646);

  final String routineName;
  final String routineDescription;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            offset: const Offset(5.0, 5.0),
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(routineName,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    routineDescription,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 204, 198, 196),
                        fontSize: 20,
                        fontFamily: "Karla"),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(5),
              child: IconButton(
                  onPressed: () {
                    Get.to(ItemView(
                        routineName: this.routineName,
                        routineDescription: this.routineDescription));
                  },
                  icon: Icon(
                    CupertinoIcons.info,
                    size: 25,
                    color: Theme.of(context).colorScheme.tertiary,
                  )))
        ],
      ),
    );
  }
}
