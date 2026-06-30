import 'dart:async';
import 'dart:io';

import 'package:frontend_v1/core/logging/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:frontend_v1/auth/login.dart';
import 'package:frontend_v1/main.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? errorCode;

Future<void> checkInvite(String code) async {
  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql('''
      mutation joinHouseholdByCode(\$code: String!) {
      joinHouseholdByCode(code: \$code) {}
      }
    '''),
    variables: <String, dynamic>{
      'code': code,
    },
  );
  try {
    final result =
        await client.mutate(options).timeout(const Duration(seconds: 5));
    if (result.hasException) {
      if (result.exception!.graphqlErrors
          .any((error) => error.message.contains('Unique constraint failed'))) {
        AppLogger.info('An invite for this email already exists.');
        // Handle the unique constraint error specifically
      } else {
        AppLogger.info('GraphQL error: ${result.exception.toString()}');
        if (result.hasException && result.exception!.graphqlErrors.isNotEmpty) {
          errorCode = result.exception!.graphqlErrors.first.message;
        } else {
          errorCode = result.exception.toString();
        }
      }
    } else {
      Get.offAll(() => const MainWidget());
    }
  } on SocketException catch (e) {
    AppLogger.info('Network error: $e');
    // Handle network error
  } on TimeoutException catch (e) {
    AppLogger.info('Request timed out: $e');
    // Handle timeout
  } catch (e) {
    AppLogger.info('Unexpected error: $e');
    // Handle other errors
  }
}

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
  AppLogger.info("finished query");

  try {
    final result =
        await client.query(options).timeout(const Duration(seconds: 10));

    if (result.hasException) {
      AppLogger.info(result.exception.toString());
    } else if (result.isLoading) {
      AppLogger.info('Loading');
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
    AppLogger.info('Network error: $e');
    // Handle network error
  } on TimeoutException catch (e) {
    AppLogger.info('Request timed out: $e');
    // Handle timeout
  } catch (e) {
    AppLogger.info('Unexpected error: $e');
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
      AppLogger.info(result.exception.toString());
    } else {
      AppLogger.info('Household created successfully');
    }
  } catch (e) {
    AppLogger.info('Unexpected error: $e');
  }
}

class JoinHouseholdView extends StatefulWidget {
  const JoinHouseholdView({super.key});

  @override
  State<JoinHouseholdView> createState() => _JoinHouseholdViewState();
}

class _JoinHouseholdViewState extends State<JoinHouseholdView> {
  bool _isButtonEnabled = false;
  bool isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _inviteCode = TextEditingController();
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
    _userDataFuture = getUserData();

    errorCode = "";
    isLoading = false;
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _inviteCode.dispose();
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
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final userData = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BackIconSignOut(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Join Household',
                            style: Theme.of(context).textTheme.bodyLarge),
                        IconButton(
                          padding: EdgeInsets.zero,
                          style: const ButtonStyle(
                            alignment: Alignment.centerRight,
                            animationDuration: Duration.zero,
                          ),
                          icon: Icon(
                            CupertinoIcons.info,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          onPressed: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: const Text("Join a Household"),
                                  content: const Text(
                                      'To use Relatee, you need to be in a Household. Here, you can either create one by entering a name for your household below, or join another household with the code you received from a member.'),
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
                    const SizedBox(height: 20),
                    Text(
                      "Hi ${userData['forename']}! \nTo get the most out of Relatee, you need to join a household.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 40),
                    TextField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(8),
                          UpperCaseTextFormatter()
                        ],
                        controller: _inviteCode,
                        autocorrect: false,
                        cursorColor: Theme.of(context).colorScheme.onSecondary,
                        style: GoogleFonts.courierPrime(),
                        decoration: InputDecoration(
                          hintText: 'Invite Code',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
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
                        )),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (_inviteCode.text.isEmpty ||
                            _inviteCode.text.length != 8) {
                          errorCode = 'Please enter an invite code.';
                          isLoading = false;
                          setState(() {});
                          return;
                        } else {
                          errorCode = "";
                          setState(() {});
                          await checkInvite(_inviteCode.text);
                          setState(() {});
                          isLoading = false;
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 74, 70, 70)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                    color: Colors.transparent))),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Submit_txt'.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    // IconButton(
                    //     onPressed: () async {
                    //       setState(() {
                    //         isLoading = true;
                    //       });
                    //       await checkInvite(_inviteCode.text);
                    //     },
                    //     icon: Icon(CupertinoIcons.airplane)),
                    const SizedBox(height: 40),
                    isLoading == true
                        ? const Center(child: CupertinoActivityIndicator())
                        : const SizedBox(),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          errorCode ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Create one instead",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(
                        height:
                            20), // Add this line to add space between the TextFormField and the Button
                    TextButton(
                      onPressed: _isButtonEnabled
                          ? () async {
                              setState(() {
                                isLoading = true;
                              });
                              String name = _nameController.text;
                              await createHousehold(name);
                              Get.to(() => const Scaffold(body: MainView()));
                              setState(() {
                                isLoading = false;
                              });
                            }
                          : null,
                      style: _isButtonEnabled
                          ? ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(255, 74, 70, 70)),
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(
                                          color: Colors.transparent))),
                            )
                          : ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.primary),
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
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
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Submit_txt'.tr,
                              style: _isButtonEnabled
                                  ? Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold)
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
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
                            AppLogger.info(
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
