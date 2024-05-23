import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:frontend_v1/routine.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

//fetched alle Daten aus der Datenbank -> tasks + Routinen
Future<Map<String, dynamic>> getUserData(int id) async {
  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql('''
  query GetUser(\$id: Int!) {
    user(id: \$id) {
      householdId
      household {
        routine
        tasks
      }
    }
  }
'''),
    variables: <String, dynamic>{
      'id': id,
    },
  );

  try {
    final result =
        await client.query(options).timeout(const Duration(seconds: 10));

    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      final user = result.data!['user'];
      final mappedResult = {
        'forename': user['forename'],
        'surname': user['surname'],
        'username': user['username'],
        'email': user['email'],
        'points': user['balance'],
        'householdName': user['household']['name'],
      };
      if (user['points'] == null) {
        mappedResult['points'] = 0;
      }
      return mappedResult;
    }
  } on SocketException catch (e) {
    print('Network error: $e');
    // Handle network error
  } on TimeoutException catch (e) {
    print('Request timed out: $e');
    // Handle timeout
  } catch (e) {
    print('Unexpected error: $e');
    // Handle other errors
  }
  return {};
}

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

/*
purpose: This widget holds the slider for switching between task and routine view.
author: Rene
date: 17.05.2024
*/

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

/*
purpose: Should hold the views + info needed.
author: Rene
date: 17.05.2024
*/

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
    return Routine();
  }
}
