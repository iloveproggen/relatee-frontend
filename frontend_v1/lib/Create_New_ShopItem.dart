import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Karla',
        textTheme: const TextTheme(
          bodyText1: TextStyle(
              color: Color.fromARGB(255, 99, 21, 21), fontSize: 200),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Form(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 100, left: 40),
              child: TextFormField(
                decoration: InputDecoration.collapsed(
                  hintText: 'new item..',
                ),
                style: TextStyle(fontSize: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*class CreateNewShopitem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 393,
          height: 870,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Color(0xFFF3F3F3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 28,
                top: 211,
                child: Container(
                  width: 339,
                  height: 253,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 339,
                          height: 34,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 4,
                                        child: SizedBox(
                                          width: 16,
                                          height: 40,
                                          child: IconButton(
                                            icon: const Icon(Icons.add_box),
                                            color: Colors.grey,
                                            onPressed: () { }, )
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 40,
                                top: 10,
                                child: SizedBox(
                                  width: 288,
                                  height: 32,
                                  child: Text(
                                    'price:',
                                    style: TextStyle(
                                      color: Color(0xFF4A4646),
                                      fontSize: 20,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w300,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                               Positioned(
                                left: 51,
                                top: 10,
                                child: SizedBox(
                                  width: 200,
                                  height: 60,
                                  child: Text(
                                    '15',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Color(0xFF4A4646),
                                      fontSize: 20,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 4,
                        top: 82,
                        child: Container(
                          width: 327,
                          height: 46,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 327,
                                  height: 46,
                                  decoration: ShapeDecoration(
                                    color: Color(0x7FD9D9D9),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 165,
                                  height: 46,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFFD9D9D9),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 21,
                                top: 12,
                                child: SizedBox(
                                  width: 122,
                                  height: 22,
                                  child: Text(
                                    'permanent',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF4A4646),
                                      fontSize: 20,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 187,
                                top: 12,
                                child: SizedBox(
                                  width: 116,
                                  height: 22,
                                  child: Text(
                                    'only once',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF4A4646),
                                      fontSize: 20,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w300,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 4,
                        top: 183,
                        child: Container(
                          width: 327,
                          height: 70,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 2,
                                top: 0,
                                child: SizedBox(
                                  width: 288,
                                  height: 31.94,
                                  child: Text(
                                    'Add description:',
                                    style: TextStyle(
                                      color: Color(0xFF4A4646),
                                      fontSize: 20,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w300,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 38,
                                child: SizedBox(
                                  width: 327,
                                  height: 32,
                                  child: Text(
                                    'None yet.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFB4B4B4),
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w300,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 33,
                top: 108,
                child: SizedBox(
                  width: 327,
                  height: 32,
                  child: Text(
                    'new item...',
                    style: TextStyle(
                      color: Color(0xFF4A4646),
                      fontSize: 32,
                      fontFamily: 'Karla',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
*/
