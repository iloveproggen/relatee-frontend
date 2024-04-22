import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:postgres/postgres.dart';

void main() {
  runApp(const LoginApp());
}
Future<List<Map<String, dynamic>>> authUser(String usern, String psw) async {
  final connection = PostgreSQLConnection(
    'ep-bold-snow-a2unxsbb.eu-central-1.aws.neon.tech',
    5432,
    'relateeDB',
    username: 'relateeDB_owner',
    password: 'bCTNHdw8mJL3',
    useSSL: true,
  );
  await connection.open();
  List<List<dynamic>> results =
      await connection.query('SELECT id, username,	password,	email FROM users WHERE username=usern, password = psw;');
  await connection.close();

  return results.map((row) => {'id': row[0], 'forename': row[1]}).toList();
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(title: 'Login App', home: LoginWidget());
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return const LoginWidget();
      },
    );
  }

  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  bool _isPasswordVisible = false;

  bool requiredFields = false;

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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackIconRow(),
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
                  borderRadius: BorderRadius.all( Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 204, 198, 196), 
                    width: 5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    width: 5,
                    color:
                        Color.fromARGB(255, 74, 70, 70), 
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
                  borderRadius: BorderRadius.all( Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 204, 198, 196), 
                    width: 5,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    width: 5,
                    color:
                        Color.fromARGB(255, 74, 70, 70), 
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
                      color: const Color.fromARGB(255, 204, 198, 196), // Set the color to grey
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
                  onPressed: () {
                    // Perform login logic here
                    String username = _usernameController.text;
                    String password = _passwordController.text;

                    
                    print('Username: $username');
                    print('Password: $password');
                  },
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
          ],
        ),
      ),
    );
  }
}
