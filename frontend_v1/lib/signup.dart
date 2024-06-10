import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

bool wrongPassword = false;
bool timeOut = false;
bool otherError = false;
bool isLoading = false;
bool requiredFields = false;

Map<String, dynamic> signUpError = {
  'hasError': false,
  'message': '',
};

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

  FocusNode? _forename;
  FocusNode? _surname;
  FocusNode? _username;
  FocusNode? _email;
  FocusNode? _password;

  @override
  void initState() {
    super.initState();

    signUpError = {
      'hasError': false,
      'message': '',
    };

    _forename = FocusNode();
    _surname = FocusNode();
    _username = FocusNode();
    _email = FocusNode();
    _password = FocusNode();

    _forenameController.addListener(_updateButtonState);
    _surnameController.addListener(_updateButtonState);
    _usernameController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _username?.addListener(() {
      // Add this line
      setState(() {});
    });
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

    _forename?.dispose();
    _surname?.dispose();
    _username?.dispose();
    _email?.dispose();
    _password?.dispose();

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
        signUpError['hasError'] = true;
        signUpError['message'] = jsonDecode(response.body)['message'];
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
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Congrats!'),
              content: const Text(
                  'Your Account was created!\n\nTo continue, verify your email and log in.'),
              actions: [
                CupertinoDialogAction(
                  child:
                      const Text('Okay!', style: TextStyle(color: Colors.blue)),
                  onPressed: () async {
                    Get.back();
                    Get.back();
                    print("Opened MainWidget");
                  },
                ),
              ],
            );
          },
        );
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
          signUpError['hasError'] = true;
          signUpError['message'] =
              jsonDecode(response.body)['error'][0]['message'];
          wrongPassword = true;
          isLoading = false;
        });
      } else {
        setState(() {
          signUpError['hasError'] = true;
          signUpError['message'] = jsonDecode(response.body)['message'];
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
          padding: const EdgeInsets.only(
              top: 80,
              right: 40,
              left: 40), // Adjust padding for top, right, and left
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
                    'Register_txt'.tr,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 40, bottom: 20), // Adjust padding for better spacing
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                            autocorrect: false,
                            focusNode: _forename,
                            onSubmitted: (value) {
                              FocusScope.of(context).requestFocus(_surname);
                            },
                            cursorColor:
                                Theme.of(context).colorScheme.onSecondary,
                            controller: _forenameController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z]')),
                            ],
                            decoration: InputDecoration(
                              hintText: 'forename_txt'.tr,
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                              border: InputBorder.none,
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                            autocorrect: false,
                            focusNode: _surname,
                            onSubmitted: (value) {
                              FocusScope.of(context).requestFocus(_username);
                            },
                            cursorColor:
                                Theme.of(context).colorScheme.onSecondary,
                            controller: _surnameController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z]')),
                            ],
                            decoration: InputDecoration(
                              hintText: 'surname_txt'.tr,
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                              border: InputBorder.none,
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
                ),
                // Username - required
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                      autocorrect: false,
                      focusNode: _username,
                      onSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_email);
                      },
                      cursorColor: Theme.of(context).colorScheme.onSecondary,
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixText: _username!.hasFocus ||
                                _usernameController.text.isNotEmpty
                            ? '@'
                            : null,
                        hintText: 'username_txt'.tr,
                        prefixStyle: Theme.of(context).textTheme.bodySmall,
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
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                // Email - required
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                      autocorrect: false,
                      cursorColor: Theme.of(context).colorScheme.onSecondary,
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: 'Email_txt'.tr,
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
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                // Password - required
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                      autocorrect: false,
                      cursorColor: Theme.of(context).colorScheme.onSecondary,
                      controller: _passwordController,
                      obscureText:
                          true, // Add this line to make the text field hideable
                      decoration: InputDecoration(
                        hintText: 'Password_txt'.tr,
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
                      style: Theme.of(context).textTheme.bodySmall),
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
                if (signUpError['hasError'] && signUpError['message'] != "")
                  Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 40, left: 20, right: 20),
                      child: Text(
                        signUpError['message'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                // if (signUpError['hasError'] && signUpError['message'] == "" ||
                //     signUpError['message'].isEmpty)
                //   Center(
                //     child: Padding(
                //       padding:
                //           const EdgeInsets.only(top: 40, left: 20, right: 20),
                //       child: Text(
                //         'Wrong password or email',
                //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
                //               color: Colors.red,
                //             ),
                //         textAlign: TextAlign.center,
                //       ),
                //     ),
                //   ),
                if (isLoading)
                  Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 40, left: 20, right: 20),
                      child: CupertinoActivityIndicator(
                          radius: 15,
                          color: Theme.of(context).colorScheme.tertiary),
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
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: const Text('Go back to Log in screen?'),
                      content: const Text(
                          'Are you sure you want to go back? Any changes will be lost.'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          child: const Text('Go',
                              style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            signUpError = {
                              'hasError': false,
                              'message': '',
                            };
                            Get.back();
                            Get.back();
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
                  // Icon(
                  //   CupertinoIcons.house_fill,
                  //   color: col,
                  //   size: 18,
                  // )
                  Text('back_button_text'.tr,
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
