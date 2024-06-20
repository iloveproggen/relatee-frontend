import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/login.dart';
import 'package:frontend_v1/main.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> getUserData() async {
  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql('''
  query GetUser {
      me {
    id
    username
    forename
    surname
    email
    coins
    experience
    level
  }
}
'''),
  );
  print("finished query");

  try {
    final result =
        await client.query(options).timeout(const Duration(seconds: 10));

    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      final user = result.data!['me'];
      final mappedResult = {
        'id': user['id'],
        'forename': user['forename'],
        'surname': user['surname'],
        'username': user['username'],
        'email': user['email'],
        'coins': user['coins'],
        'experience': user['experience'],
        'level': user['level'],
      };
      if (mappedResult['points'] == null) {
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

class JoinHouseholdView extends StatelessWidget {
  const JoinHouseholdView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: FutureBuilder<Map<String, dynamic>>(
            future: getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final userData = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackIconSignOut(),
                        TextButton(
                          style: ButtonStyle(
                            alignment: Alignment.centerRight,
                            animationDuration: Duration.zero,
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                          ),
                          child: Icon(
                            CupertinoIcons.info,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          onPressed: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title:
                                      const Text("You're creating a household"),
                                  content: const Text(
                                      'To join an existing household instead, ask a member to send you an invitation. Once you receive it, click the link to join.'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('OK',
                                          style: TextStyle(color: Colors.blue)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Text('Create Household',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 20),
                    Text(
                      "Hi ${userData['forename']}! \nTo get the most out of Relatee, you need to join a household. Create one now!",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class BackIconSignOut extends StatelessWidget {
  const BackIconSignOut({super.key});

  final double padding = 20;

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
              onPressed: () async {
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text(
                          'Are you sure you want to log out? Your changes will not be saved'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        CupertinoDialogAction(
                          child: const Text('Logout',
                              style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.remove('token');
                            print(
                                "logging out user ${prefs.getString('token')}");
                            Get.off(() => const LoginWidget());
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.back,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 18,
                  ),
                  Container(width: 5),
                  Text('log out',
                      style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
