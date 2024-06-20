import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/login.dart';
import 'package:frontend_v1/main.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _isButtonEnabled = false;
bool isLoading = false;


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

Future<void> createHousehold(String name) async {
  final Map<String, dynamic> variables = {
    'name': name,
  };
  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql(r'''
   mutation createHousehold($name: String!, $emoji: String) {
        createHousehold(name: $name, emoji: $emoji) {
          id
          name
          emoji
          owner {
            id
            username
          }
          users {
            id
            username
          }
        }
      }
    '''),
    variables: variables,
  );

  try {
    final QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else {
      print('Household created successfully');
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}

class JoinHouseholdView extends StatefulWidget {
  const JoinHouseholdView({super.key});

  @override
  _JoinHouseholdViewState createState() => _JoinHouseholdViewState();
}

class _JoinHouseholdViewState extends State<JoinHouseholdView> {
  bool _isButtonEnabled = false;
  bool isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
    _userDataFuture = getUserData();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _userDataFuture,
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
                                  title: const Text("You're creating a household"),
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
                    TextFormField(
                      controller: _nameController,
                      autocorrect: false,
                      cursorColor: Theme.of(context).colorScheme.onSecondary,
                      decoration: InputDecoration(
                        hintText: 'Household Name'.tr,
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSecondary,
                            width: 2,
                          ),
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20), // Add this line to add space between the TextFormField and the Button
                    ElevatedButton(
                      onPressed: _isButtonEnabled
                          ? () async {
                        setState(() {
                          isLoading = true;
                        });
                        String name = _nameController.text;
                        await createHousehold(name);
                        Get.to(() => MainView());
                        setState(() {
                          isLoading = false;
                        });
                      }
                          : null,
                      style: _isButtonEnabled
                          ? ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 74, 70, 70)),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                    color: Colors.transparent))),
                      )
                          : ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.primary),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                    width: 2,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary))),
                      ),
                      child: Center(
                        child: Padding(
                            padding: const EdgeInsets.only(
                                top: 15, bottom: 15, left: 15, right: 15),
                            child: Text(
                              'Submit_txt'.tr,
                              style: _isButtonEnabled
                                  ? Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold)
                                  : Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color:
                                  Theme.of(context).colorScheme.tertiary),
                            )),
                      ),
                    ),
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
                      content: const Text('Are you sure you want to log out? Your changes will not be saved'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        CupertinoDialogAction(

                          child: const Text('Logout', style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.remove('token');
                            print("logging out user ${prefs.getString('token')}");
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



