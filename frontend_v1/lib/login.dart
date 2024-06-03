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

Future<String?> isTokenSaved() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString('token') != null) {
    return prefs.getString('token')!;
  } else {
    return null;
  }
}

final focusNode1 = FocusNode();
final focusNode2 = FocusNode();
final focusNodeButton = FocusNode();
late int userId;

// Future<int?> loggedIn() async {
//   String? tokenSaved = await isTokenSaved();
//   if (tokenSaved != null) {
    
//     var response = await http.get(
//       Uri.parse('http://85.215.50.29:3000/login'),
//       headers: {
//         'Authorization': 'Bearer $tokenSaved',
//       },
//     );
//     if (response.statusCode == 200) {
//       print('Response data: ${response.body}');
//       return jsonDecode(response.body)['userId'];
//     } else {
//       print(response.statusCode);
//       return null;
//     }
//   } else {
//     print('No token found. Opening LoginScreen...');
//     return null;
//   }
// }

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

class LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  bool requiredFields = false;

  bool isLoading = false;

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
      Get.to(() => MainWidget(userId: userId));
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
    // Add listener to text controllers to update required variable
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
                      width: 5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 5,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 5,
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
            const SizedBox(height: 10),
            TextFormField(
              autofillHints: [AutofillHints.password],
              focusNode: focusNode2,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(focusNodeButton);
              },
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              cursorColor: Theme.of(context).colorScheme.onSecondary,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                    width: 5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    width: 5,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    width: 5,
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
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container(
                decoration: requiredFields
                    ? BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: const Color.fromARGB(255, 74, 70, 70),
                        boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.secondary,
                              offset: const Offset(5.0, 5.0),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            )
                          ])
                    : BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
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
                          print("Username: $username, Password: $password");
                        }
                      : null,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 15, right: 15),
                      child: Text(
                        'Log_In_txt'.tr,
                        style: requiredFields
                            ? const TextStyle(
                                color: Color.fromARGB(255, 243, 243, 243),
                                fontFamily: "Karla",
                                fontSize: 20,
                              )
                            : const TextStyle(
                                color: Color.fromARGB(255, 204, 198, 196),
                                fontFamily: "Karla",
                                fontSize: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: const Color.fromARGB(255, 243, 243, 243),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.secondary,
                        offset: const Offset(5.0, 5.0),
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      )
                    ]),
                child: TextButton(
                  onPressed: () {
                    Get.to(() => const SignUp());
                  },
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 15, right: 15),
                      child: Text('Sign Up!',
                          style: TextStyle(
                            color: Color.fromARGB(255, 74, 70, 70),
                            fontFamily: "Karla",
                            fontSize: 20,
                          )),
                    ),
                  ),
                ),
              ),
            ),
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
