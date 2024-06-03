import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';

class HouseholdInvaitation extends StatelessWidget {
  const HouseholdInvaitation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            children: [
              const BackIconRow(),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 60),
                child: Text(
                  'HouseholdInvitation',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Who do you want to invite?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter email address',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
