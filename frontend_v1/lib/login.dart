
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/assets/LocaleStrings.dart';
import 'package:frontend_v1/main.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

/*
Future<bool> authUser(String username, String password) async {
  final connection = PostgreSQLConnection(
    'ep-bold-snow-a2unxsbb.eu-central-1.aws.neon.tech',
    5432,
    'relateeDB',
    username: 'relateeDB_owner',
    password: 'bCTNHdw8mJL3',
    useSSL: true,
  );
  await connection.open();
  List<List<dynamic>> results = await connection.query(
      'SELECT id, username, password, email FROM users WHERE username = @username AND password = @password;',
      substitutionValues: {'username': username, 'password': password});
  await connection.close();

  print(results);
  print(results.isNotEmpty);
  print('SELECT id, username, password, email FROM users WHERE username = $username AND password = $password;',);

  return results.isNotEmpty;
}*/

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        translations: LocaleString(),
        locale: const Locale('en-US'),
        fallbackLocale: const Locale('en-US'),
        debugShowCheckedModeBanner: false,
        title: 'Relatee',
        theme: ThemeData(
            fontFamily: 'Karla',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(
                  letterSpacing: -1,
                  fontSize: 35,
                  color: Color.fromARGB(255, 74, 70, 70),
                  fontWeight: FontWeight.w800,
                  fontFamily: "Karla"),
              bodySmall: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 74, 70, 70),
                  fontFamily: "Karla",
                  letterSpacing: 0),
              bodyMedium: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 74, 70, 70),
                  fontFamily: "Sedan",
                  letterSpacing: 0),
            ),
            scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243)),
        home: LoginWidget());
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

    void _login() async {
    setState(() {
    });
    final connection = PostgreSQLConnection(
      'ep-bold-snow-a2unxsbb.eu-central-1.aws.neon.tech',
      5432,
      'relateeDB',
      username: 'relateeDB_owner',
      password: 'bCTNHdw8mJL3',
      useSSL: true,
    );
    await connection.open();
    List<List<dynamic>> results = await connection.query(
        'SELECT users.id, users.forename, users.surname, users.username, users.email, users.balance, households.name FROM users JOIN households ON users."householdId" = households.id WHERE users.username = @username AND users.password = @password;',
        substitutionValues: {
          'username': _usernameController.text,
          'password': _passwordController.text
        });
    await connection.close();
    if (results.isNotEmpty) {
      Get.to(() => MainWidget(user: _usernameController.text));
    }
    else
      {
        setState(() {
          wrongPassword = true;
        });
      }
    setState(() {
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Log In to Relatee',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 204, 198, 196),
                      width: 5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 5,
                      color: Color.fromARGB(255, 74, 70, 70),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 5,
                    ),
                  ),
                  hintText: 'Username or Email',
                  contentPadding: EdgeInsets.all(20),
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 204, 198, 196),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                )),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 204, 198, 196),
                    width: 5,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    width: 5,
                    color: Color.fromARGB(255, 74, 70, 70),
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    width: 5,
                  ),
                ),
                hintText: 'Password',
                contentPadding: EdgeInsets.all(20),
                hintStyle: const TextStyle(
                  color: Color.fromARGB(255, 204, 198, 196),
                ),
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
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container(
                decoration: requiredFields
                    ? const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color.fromARGB(255, 74, 70, 70),
                        boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(61, 109, 103, 103),
                              offset: Offset(5.0, 5.0),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            )
                          ])
                    : BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            strokeAlign: BorderSide.strokeAlignInside,
                            width: 5,
                            color: const Color.fromARGB(255, 204, 198, 196)),
                        color: const Color.fromARGB(255, 243, 243, 243),
                      ),
                child: TextButton(
                  onPressed: requiredFields
                  ? () async {
                    String username = _usernameController.text;
                    String password = _passwordController.text;
                    _login();
                    print("Username: $username, Password: $password");

                    // if (await authUser(username, password)) {
                    //   Navigator.of(context).push(ProfileView.route());
                    //   print("User authenticated");
                    // } else {
                    //   //Navigator.of(context).push(ProfileView.route());
                    //   print("User not authenticated");
                    //   setState(() {
                    //     wrongPassword = true;
                    //   });
                    // }
                  }
                  : null,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 15, right: 15),
                      child: Text(
                        "Log In",
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
            if (wrongPassword)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Text(
                    "Wrong username or password!",
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: "Karla",
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (wrongPassword) // change this to show error on timeout
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Text(
                    "Wrong username or password!",
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: "Karla",
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
