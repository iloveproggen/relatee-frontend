import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/assets/locale_strings.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/signup.dart';
import 'package:frontend_v1/theme/dark_theme.dart';
import 'package:frontend_v1/theme/light_theme.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:local_auth/local_auth.dart';

final focusNode1 = FocusNode();
final focusNode2 = FocusNode();
final focusNodeSwitch = FocusNode();
final focusNodeButton = FocusNode();
late int userId;

Map<String, dynamic> error = {'hasError': false, 'message': "",};

//checks if a user has saved their token in sharedpreferences, if yes, skip log in
Future<String?> checkIfSignedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  print("token: $token");
  if (token != null) {
    return token;
  }
  print("no token found");
  return null;
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
//     print('Error: $e');
//   }

//   return authenticated;
// }

class CheckLoggedIn extends StatelessWidget {
  const CheckLoggedIn({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return FutureBuilder<String?>(
      future: checkIfSignedIn(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          return GetMaterialApp(
              darkTheme: darktheme,
              theme: brightness == Brightness.light ? lighttheme : darktheme,
              translations: LocaleString(),
              locale: const Locale('en-Us'),
              fallbackLocale: const Locale('en-US'),
              debugShowCheckedModeBanner: false,
              title: 'Relatee',
              home: Scaffold(body: MainWidget()));
        } else {
          return GetMaterialApp(
              darkTheme: darktheme,
              theme: brightness == Brightness.light ? lighttheme : darktheme,
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
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //String? lastLoginDate = prefs.getString('lastLoginDate');
// for (String key in prefs.getKeys()) {
//   var value = prefs.get(key);
//   print('$key: $value');
// }
  String? lastLoginDate = prefs.getString('lastLoginDate');
  DateTime now = DateTime.now();
  DateTime yesterday = now.subtract(Duration(days: 1));
  
  if (lastLoginDate == null) {
    // First time login, set streak to 1 and save today's date
    prefs.setInt('streak', 1);
    prefs.setString('lastLoginDate', now.toString());
    print('First time login. Streak set to 1.');
  } else {
    DateTime lastLogin = DateTime.parse(lastLoginDate);
    if (lastLogin.isBefore(yesterday)) {
      // Last login was yesterday, increment streak by 1 and save today's date
      int streak = prefs.getInt('streak') ?? 0;
      prefs.setInt('streak', streak + 1);
      prefs.setString('lastLoginDate', now.toString());
      print('Last login was yesterday. Streak incremented to ${streak + 1}.');
    } else {
    // Last login was today, do nothing
    print('Last login was today.');
  }
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
            Uri.parse('http://85.215.50.29:3000/login'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'email': _usernameController.text,
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        timeOut = true;
        error['hasError'] = true;
        error['message'] = jsonDecode(response.body)['error'][0]['message'].split("\"")[1];
      });
    }
    setState(() {
      isLoading = true;
    });
    print("Loading...");
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      String token = jsonDecode(response.body)['token'];
      _saveToken(token);
      int userId = jsonDecode(response.body)['userId'];
      print("The user id is: $userId");
      Get.off(() => MainWidget());
      print("Opened MainWidget");
      setState() {
        isLoading = false;
      }
    } else {
      // If the server returns an error response, throw an exception.
      print('Failed to load');
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
    // Check if there is a token saved in SharedPreferences

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Stack(
          children: [
            isLoading
                ? Positioned.fill(
                  bottom: 150,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
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
              TextFormField(
                  autofillHints: const [AutofillHints.username],
                  cursorColor: Theme.of(context).colorScheme.onSecondary,
                  autocorrect: false,
                  focusNode: focusNode1,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(focusNode2);
                  },
                  controller: _usernameController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                        ?.copyWith(color: Theme.of(context).colorScheme.tertiary),
                  ),
                  style: Theme.of(context).textTheme.bodySmall),
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
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                      ?.copyWith(color: Theme.of(context).colorScheme.tertiary),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      icon: Icon(
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
              const SizedBox(height: 0),
              error['hasError'] && error['message'] != "" && isLoading == false ? 
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                    child: Text(
                      error['message'] == "Invalid request" ? "Invalid email adress" : error['message'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ) : Container(height: 67),
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
              //           print(_staySignedIn);
              //         });
              //       },
              //     ),
              //   title: Text('Stay Signed In?', style: Theme.of(context).textTheme.bodySmall),
              // ),
              const SizedBox(height:40),
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
                                  print(
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
                            Get.to(() => SignUpScreen());
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
                  ]),
            ],
          ),
          ]
        ),
      ),
    );
  }
}
