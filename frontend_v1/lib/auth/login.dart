import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:frontend_v1/core/constants/app_constants.dart';
import 'package:frontend_v1/core/logging/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/assets/locale_strings.dart';
import 'package:frontend_v1/auth/forgot_password.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/auth/signup.dart';
import 'package:frontend_v1/theme/dark_theme.dart';
import 'package:frontend_v1/theme/light_theme.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:local_auth/local_auth.dart';

final focusNode1 = FocusNode();
final focusNode2 = FocusNode();
final focusNodeSwitch = FocusNode();
final focusNodeButton = FocusNode();

Map<String, dynamic> error = {
  'hasError': false,
  'message': "",
};

//checks if a user has saved their token in sharedpreferences, if yes, skip log in
Future<String?> getPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  AppLogger.info('Loaded saved auth token: ${token != null}');
  return token;
}

// Future<bool> authenticateWithFaceID() async {
//   final localAuth = LocalAuthentication();
//   bool authenticated = false;

//   try {
//     authenticated = await localAuth.authenticate(
//       localizedReason: 'Authenticate with Face ID',
//       biometricOnly: true,
//     );
//   } catch (e) {
//     AppLogger.info('Error: $e');
//   }

//   return authenticated;
// }

class CheckLoggedIn extends StatelessWidget {
  const CheckLoggedIn({super.key, this.brightness});

  final bool? brightness;

  @override
  Widget build(BuildContext context) {
    final bool systemBrightness = brightness ??
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.light;
    return FutureBuilder<String?>(
      future: getPrefs(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          return GetMaterialApp(
              darkTheme: darktheme,
              theme: systemBrightness == true ? lighttheme : darktheme,
              translations: LocaleString(),
              locale: const Locale('en-Us'),
              fallbackLocale: const Locale('en-US'),
              debugShowCheckedModeBanner: false,
              title: 'Relatee',
              home: const Scaffold(body: MainWidget()));
        } else {
          return GetMaterialApp(
              darkTheme: darktheme,
              theme: systemBrightness == true ? lighttheme : darktheme,
              translations: LocaleString(),
              locale: const Locale('en-Us'),
              fallbackLocale: const Locale('en-US'),
              debugShowCheckedModeBanner: false,
              title: 'Relatee',
              home: const Scaffold(body: LoginWidget()));
        }
      },
    );
  }
}

void checkLastLoginDate() async {
  final prefs = await SharedPreferences.getInstance();
  final lastLoginDate = prefs.getString('lastLoginDate');
  DateTime now = DateTime.now().subtract(Duration(
    hours: DateTime.now().hour,
    minutes: DateTime.now().minute,
    seconds: (DateTime.now().second - 1),
  ));

  if (lastLoginDate == null) {
    await prefs.setString('lastLoginDate', now.toString());
    return;
  }

  // updateStreak();
  final lastLogin = DateTime.parse(lastLoginDate);
  if (lastLogin.isBefore(now)) {
    // Last login was yesterday, increment streak by 1 and save today's date
    int streak = prefs.getInt('streak') ?? 0;
    prefs.setInt('streak', streak + 1);
    prefs.setString('lastLoginDate', now.toString());
    AppLogger.info('Last login was before today. Streak incremented.');
    updateStreak();
  } else {
    // Last login was today, do nothing
    AppLogger.info('Last login already recorded for today.');
  }
}

Future<void> updateStreak() async {
  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql('''
      mutation updateLoginStreak() {
        updateLoginStreak() {}
      }
    '''),
  );
  try {
    final result =
        await client.mutate(options).timeout(AppConstants.requestTimeout);
    if (result.hasException) {
      AppLogger.error('updateLoginStreak GraphQL error', result.exception);
    } else {
      AppLogger.info('Streak successfully updated.');
    }
  } on SocketException catch (e) {
    AppLogger.error('updateLoginStreak network error', e);
    // Handle network error
  } on TimeoutException catch (e) {
    AppLogger.error('updateLoginStreak timeout', e);
    // Handle timeout
  } catch (e) {
    AppLogger.error('updateLoginStreak unexpected error', e);
    // Handle other errors
  }
}
// class LoginApp extends StatefulWidget {
//   const LoginApp({super.key});

//   @override
//   State<LoginApp> createState() => _LoginAppState();
// }

// class _LoginAppState extends State<LoginApp> {
//   late Future<void> loggedInFuture;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final brightness = MediaQuery.of(context).platformBrightness;
//     return GetMaterialApp(
//       darkTheme: darktheme,
//       theme: brightness == Brightness.light ? lighttheme : darktheme,
//       translations: LocaleString(),
//       locale: const Locale('en-Us'),
//       fallbackLocale: const Locale('en-US'),
//       debugShowCheckedModeBanner: false,
//       title: 'Relatee',
//       home: const LoginWidget(),
//     );
//   }
// }

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> with WidgetsBindingObserver {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  bool requiredFields = false;

  bool isLoading = false;

  //bool _staySignedIn = false;

  void _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  void _login() async {
    setState(() {
      wrongPassword = false;
      timeOut = false;
      otherError = false;
      isLoading = false;
    });
    http.Response response = http.Response('Error', 500);
    try {
      response = await http
          .post(
        Uri.parse(AppConstants.loginEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _usernameController.text,
          'password': _passwordController.text,
        }),
      )
          .timeout(AppConstants.requestTimeout, onTimeout: () {
        throw TimeoutException('Request timed out');
      });
    } catch (e) {
      if (e is TimeoutException) {
        AppLogger.warning('Login request timed out.');
        setState(() {
          isLoading = false;
          timeOut = true;
          error['hasError'] = true;
          error['message'] = 'Request timed out';
        });
      } else {
        AppLogger.error('Login request failed', e);
        setState(() {
          isLoading = false;
          timeOut = true;
          error['hasError'] = true;
          error['message'] =
              jsonDecode(response.body)['error'][0]['message'].split("\"")[1];
        });
      }
      //Get.to(() => const LoginWidget());
    }
    setState(() {
      isLoading = true;
    });
    AppLogger.info('Login response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      String token = jsonDecode(response.body)['token'];
      _saveToken(token);
      int userId = jsonDecode(response.body)['userId'];
      AppLogger.info('Login succeeded for userId=$userId');
      Get.off(() => const MainWidget());
      setState(() {
        isLoading = false;
      });
    } else {
      // If the server returns an error response, throw an exception.
      AppLogger.warning('Login failed with status ${response.statusCode}.');
      if (response.statusCode == 401) {
        setState(() {
          wrongPassword = true;
          isLoading = false;
          error['hasError'] = true;
          error['message'] = jsonDecode(response.body)['message'];
        });
      } else {
        setState(() {
          timeOut = true;
          isLoading = false;
          error['hasError'] = true;
          error['message'] = jsonDecode(response.body)['message'];
        });
      }
    }
  }

  void _updateRequired() {
    setState(() {
      requiredFields = _checkInputs(); // Update required based on inputs
    });
  }

  @override
  void initState() {
    super.initState();
    error = {
      'hasError': false,
      'message': '',
    };
    _usernameController.addListener(_updateRequired);
    _passwordController.addListener(_updateRequired);
  }

  bool _checkInputs() {
    return _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  bool wrongPassword = false;
  bool timeOut = false;
  bool otherError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Stack(children: [
          isLoading
              ? Positioned.fill(
                  bottom: 150,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 40, left: 20, right: 20),
                        child: CupertinoActivityIndicator(
                          radius: 15,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              Text(
                'Log_In_to_Relatee_txt'.tr,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 20,
              ),
              AutofillGroup(
                child: Column(
                  children: [
                    TextFormField(
                      autofillHints: const [AutofillHints.email],
                      cursorColor: Theme.of(context).colorScheme.onSecondary,
                      autocorrect: false,
                      focusNode: focusNode1,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(focusNode2);
                      },
                      controller: _usernameController,
                      decoration: InputDecoration(
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
                            width: 2,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 2,
                          ),
                        ),
                        hintText: 'Email_txt'.tr,
                        contentPadding: const EdgeInsets.all(20),
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      autofillHints: const [AutofillHints.password],
                      focusNode: focusNode2,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(focusNodeSwitch);
                      },
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      cursorColor: Theme.of(context).colorScheme.onSecondary,
                      decoration: InputDecoration(
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
                            width: 2,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 2,
                          ),
                        ),
                        hintText: 'Password_txt'.tr,
                        contentPadding: const EdgeInsets.all(20),
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: TextButton(
                            style: ButtonStyle(
                                padding: WidgetStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.all(0)),
                                animationDuration: Duration.zero),
                            child: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color.fromARGB(
                                  255, 204, 198, 196), // Set the color to grey
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: Text('Reset Password',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                    content: const Text(
                                        'Do you want to reset your password?'),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text('Yes',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ForgotPasswordScaffold()),
                                          );
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: Text('No',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: Text('forgotpassword_txt'.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.red)
                                  .copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              error['hasError'] && error['message'] != "" && isLoading == false
                  ? Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 40, left: 20, right: 20),
                        child: Text(
                          error['message'] == "Invalid request"
                              ? "Invalid email adress"
                              : error['message'],
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.red,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Container(height: 67),
              // if (error['hasError'] && error['message'] == "" ||
              //     error['message'].isEmpty)
              //   Center(
              //     child: Padding(
              //       padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
              //       child: Text(
              //         'Wrong password or email',
              //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //               color: Colors.red,
              //             ),
              //         textAlign: TextAlign.center,
              //       ),
              //     ),
              //   ),

              // ListTile(
              //   contentPadding: const EdgeInsets.only(top: 20),
              //   leading: CupertinoSwitch(
              //       focusNode: focusNodeSwitch,
              //       activeColor: Theme.of(context).colorScheme.tertiary, // Set the color to blue when the switch is on
              //       value: _staySignedIn,
              //       onChanged: (newValue) {
              //         setState(() {
              //           _staySignedIn = newValue;
              //           AppLogger.info(_staySignedIn);
              //         });
              //       },
              //     ),
              //   title: Text('Stay Signed In?', style: Theme.of(context).textTheme.bodySmall),
              // ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: requiredFields
                          ? BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              color: const Color.fromARGB(255, 74, 70, 70),
                              border: Border.all(
                                color: const Color.fromARGB(255, 74, 70, 70),
                                width: 2,
                              ),
                            )
                          : BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.tertiary,
                                width: 2,
                              ),
                            ),
                      child: TextButton(
                        onPressed: requiredFields
                            ? () async {
                                String username = _usernameController.text;
                                String password = _passwordController.text;
                                _login();
                                setState(() {
                                  isLoading = true;
                                });
                                AppLogger.info(
                                    "Username: $username, Password: $password");
                              }
                            : null,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, left: 15, right: 15),
                            child: Text(
                              'Log_In_txt'.tr,
                              style: requiredFields
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Theme.of(context).colorScheme.tertiary,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 2,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          error = {
                            'hasError': false,
                            'message': '',
                          };
                          Get.to(() => const SignUpScreen());
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, left: 15, right: 15),
                            child: Text('Sign Up!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ]),
      ),
    );
  }
}
