import 'package:flutter/material.dart';

import 'package:frontend_v1/profile/profile_v2.dart';

class ItemView extends StatelessWidget {
  const ItemView({
    super.key,
    required this.routineName,
    required this.routineDescription,
  });

  final String routineName;
  final String routineDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          children: [
            const BackIconRow(),
            Text(routineName, style: Theme.of(context).textTheme.bodyLarge),
            Text(routineDescription,
                style: Theme.of(context).textTheme.bodyMedium),
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 60),
            ),
          ],
        ),
      ),
    ));
  }
}
