import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'profileV2.dart';

class ItemView extends StatelessWidget {
  const ItemView({
    super.key,
    required this.routineName,
    required this.routineDescription,
    required this.routineIntervall,
    required this.routineTasks,
  });

  final String routineName;
  final String routineDescription;
  final int routineIntervall;
  final List<String> routineTasks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          children: [
            BackIconRow(),
            Text(routineName, style: Theme.of(context).textTheme.bodyLarge),
            Text(routineDescription,
                style: Theme.of(context).textTheme.bodyMedium),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 60),
            ),
          ],
        ),
      ),
    ));
  }
}
