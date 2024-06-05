import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JoinHouseholdView extends StatelessWidget {
  const JoinHouseholdView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Text('Join Household',
                style: Theme.of(context).textTheme.bodyLarge)));
  }
}
