import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

bool wrongPassword = false;
bool timeOut = false;
bool otherError = false;
bool isLoading = false;
bool requiredFields = false;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _forenameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  bool isConfirmed = true; // Define a new boolean variable
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    _forenameController.addListener(_updateButtonState);
    _surnameController.addListener(_updateButtonState);
    _usernameController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _forenameController.removeListener(_updateButtonState);
    _surnameController.removeListener(_updateButtonState);
    _usernameController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _emailController.removeListener(_updateButtonState);

    _forenameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _forenameController.text.isNotEmpty &&
          _surnameController.text.isNotEmpty &&
          _usernameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  void _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  void _register() async {
    print("Register function called"); // Debugging line
    setState(() {
      wrongPassword = false;
      timeOut = false;
      otherError = false;
      isLoading = false;
    });

    http.Response response = http.Response('Error', 500);
    try {
      print("Sending POST request"); // Debugging line
      response = await http
          .post(
        Uri.parse('http://relatee.rhinebytes.com:3000/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'forename': _forenameController.text,
          'surname': _surnameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
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
      var responseBody = jsonDecode(response.body);
      if (responseBody != null) {
        String token = responseBody['token'];
        int userId = responseBody['userId'];
        _saveToken(token);
        Get.to(() => MainWidget(userId: userId));
        print("Opened MainWidget");
            } else {
        print('Response body is null');
      }
      setState(() {
        isLoading = false;
      });
    } else {
      // If the server returns an error response, throw an exception.
      print('Failed to load');
      print('Response body: ${response.body}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, right: 40, left: 40), // Adjust padding for top, right, and left
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BackIconRow(),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Register'.tr,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 20), // Adjust padding for better spacing
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          cursorColor: Theme.of(context).colorScheme.onSecondary,
                          controller: _forenameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z]')),
                          ],
                          decoration: InputDecoration(
                            hintText: "forename",
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 204, 198, 196),
                              fontSize: 20,
                            ),
                            border: InputBorder.none,
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
                                color: Theme.of(context).colorScheme.onSecondary,
                                width: 5,
                              ),
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Surname - optional
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          cursorColor:
                          Theme.of(context).colorScheme.onSecondary,
                          controller: _surnameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z]')),
                          ],
                          decoration: InputDecoration(
                            hintText: "surname",
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 204, 198, 196),
                              fontSize: 20,
                            ),
                            border: InputBorder.none,
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
                                color: Theme.of(context).colorScheme.onSecondary,
                                width: 5,
                              ),
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Username - required
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          cursorColor:
                          Theme.of(context).colorScheme.onSecondary,
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: "username",
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 204, 198, 196),
                              fontSize: 20,
                            ),
                            border: InputBorder.none,
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
                                color: Theme.of(context).colorScheme.onSecondary,
                                width: 5,
                              ),
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Email - required
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          cursorColor: Theme.of(context).colorScheme.onSecondary,
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: "email",
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 204, 198, 196),
                              fontSize: 20,
                            ),
                            border: InputBorder.none,
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
                                color: Theme.of(context).colorScheme.onSecondary,
                                width: 5,
                              ),
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Password - required
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          cursorColor:
                          Theme.of(context).colorScheme.onSecondary,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: "password",
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 204, 198, 196),
                              fontSize: 20,
                            ),
                            border: InputBorder.none,
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
                                color: Theme.of(context).colorScheme.onSecondary,
                                width: 5,
                              ),
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () async {
                    _register();
                    setState(() {
                      isLoading = true;
                    });
                  }
                      : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 74, 70, 70)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(color: Colors.transparent))),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 15, right: 15),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            color: Color.fromARGB(255, 243, 243, 243),
                            fontFamily: "Karla",
                            fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BackIconRow extends StatelessWidget {
  const BackIconRow({super.key});

  final double padding = 20;
  final double size = 40;
  final Color col = const Color.fromARGB(255, 204, 198, 196);

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
                Get.back();
              },
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.arrowtriangle_left_fill,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 18,
                  ),
                  Container(width: 5),
                  Text('back_button_text'.tr,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 15,
                          fontFamily: "Karla",
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
