import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/assets/locale_strings.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/signup.dart';
import 'package:frontend_v1/theme/dark_theme.dart';
import 'package:frontend_v1/theme/light_theme.dart';
import 'package:get/get.dart';
//import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final focusNode1 = FocusNode();
final focusNode2 = FocusNode();
final focusNodeSwitch = FocusNode();
final focusNodeButton = FocusNode();
late int userId;

//checks if a user has saved their token in sharedpreferences, if yes, skip log in
Future<int?> checkIfSignedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  print(token);
  if (token != null) {
    List<String> parts = token.split('.');
    String payload = parts[1];
    String normalized = base64Url.normalize(payload);
    var decoded = utf8.decode(base64Url.decode(normalized));

    var payloadJson = jsonDecode(decoded);
    int userId = payloadJson['userId'];

    print("\n\nlogged in as user with the user id $userId\n\n");
    return userId;
  }
  return null;
}

class CheckLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return FutureBuilder<int?>(
      future: checkIfSignedIn(),
      builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GetMaterialApp(
              darkTheme: darktheme,
              theme: brightness == Brightness.light ? lighttheme : darktheme,
              translations: LocaleString(),
              locale: const Locale('en-Us'),
              fallbackLocale: const Locale('en-US'),
              debugShowCheckedModeBanner: false,
              title: 'Relatee',
              home: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return GetMaterialApp(
              darkTheme: darktheme,
              theme: brightness == Brightness.light ? lighttheme : darktheme,
              translations: LocaleString(),
              locale: const Locale('en-Us'),
              fallbackLocale: const Locale('en-US'),
              debugShowCheckedModeBanner: false,
              title: 'Relatee',
              home: MainWidget(userId: snapshot.data!));
        } else {
          return GetMaterialApp(
              darkTheme: darktheme,
              theme: brightness == Brightness.light ? lighttheme : darktheme,
              translations: LocaleString(),
              locale: const Locale('en-Us'),
              fallbackLocale: const Locale('en-US'),
              debugShowCheckedModeBanner: false,
              title: 'Relatee',
              home: LoginWidget());
        }
      },
    );
  }
}

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  late Future<void> loggedInFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return GetMaterialApp(
      darkTheme: darktheme,
      theme: brightness == Brightness.light ? lighttheme : darktheme,
      translations: LocaleString(),
      locale: const Locale('en-Us'),
      fallbackLocale: const Locale('en-US'),
      debugShowCheckedModeBanner: false,
      title: 'Relatee',
      home: const LoginWidget(),
    );
  }
}

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

  // bool _staySignedIn = false;

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
      });
    }
    setState(() {
      isLoading = true;
    });
    print("Loading...");
    print(response.statusCode);
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      String token = jsonDecode(response.body)['token'];
      _saveToken(token);
      int userId = jsonDecode(response.body)['userId'];
      Get.off(() => MainWidget(userId: userId));
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
        });
      } else {
        setState(() {
          timeOut = true;
          isLoading = false;
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
        child: Column(
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
                autofillHints: [AutofillHints.username],
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
              autofillHints: [AutofillHints.password],
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
            const SizedBox(height: 80),
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
            if (isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: CupertinoActivityIndicator(
                      radius: 20,
                      color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
            if (wrongPassword)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Text(
                    "Wrong username or password!",
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: "Karla",
                      fontSize: 23,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (timeOut) // change this to show error on timeout
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Text(
                    "Issues connecting to the server, try again later.",
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: "Karla",
                      fontSize: 23,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (otherError) // change this to show error on timeout
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Text(
                    "code kaputt, bitte fixen :( \n user id = -1",
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: "Karla",
                      fontSize: 23,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
