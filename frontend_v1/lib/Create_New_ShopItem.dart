import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:frontend_v1/shop.dart';

void main() {
  runApp(const MainWidget());
}

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
          bodyLarge:
              TextStyle(color: Color.fromARGB(255, 99, 21, 21), fontSize: 20),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      home: const NewShopItem(),
    );
  }
}

class NewShopItem extends StatelessWidget {
  const NewShopItem({super.key});

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return const NewShopItem();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            children: [
              BackIconRow(),
              CustomTextField(),
              SliderWidget(),
              Price(),
              AddDescription(),
              ConfirmButton(),
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
            TextFormField(
              decoration: const InputDecoration.collapsed(
                hintText: 'new item..',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Sedan",
                  fontSize: 40,
                  color: Color.fromARGB(255, 204, 198, 196),
                ),
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Sedan",
                fontSize: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Price extends StatelessWidget {
  const Price({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.add_circled,
            size: 25,
            color: Color.fromARGB(255, 204, 198, 196),
          ),
          const SizedBox(width: 20),
          const Text(
            'price:',
            style: TextStyle(fontSize: 25, fontFamily: "Karla"),
          ),
          Expanded(
            child: TextField(
              textAlign: TextAlign.end,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  hintText: "add price",
                  hintStyle: TextStyle(
                      color: Color.fromARGB(255, 204, 198, 196), fontSize: 20),
                  border: InputBorder.none),
              style: const TextStyle(
                  color: Color.fromARGB(255, 74, 70, 70),
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ),
        ],
      ),
    );
  }
}

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  bool _isPermanent = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPermanent = !_isPermanent;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Container(
          width: 386,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0x7FD9D9D9),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment:
                    _isPermanent ? Alignment.centerLeft : Alignment.centerRight,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Container(
                  width: 193,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'permanent',
                        style: TextStyle(
                          color: _isPermanent
                              ? Colors.black
                              : const Color(0xFF4A4646),
                          fontSize: 20,
                          fontFamily: 'Karla',
                          fontWeight:
                              _isPermanent ? FontWeight.w700 : FontWeight.w300,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'only once',
                        style: TextStyle(
                          color: !_isPermanent
                              ? Colors.black
                              : const Color(0xFF4A4646),
                          fontSize: 20,
                          fontFamily: 'Karla',
                          fontWeight:
                              !_isPermanent ? FontWeight.w700 : FontWeight.w300,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddDescription extends StatelessWidget {
  const AddDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 40), // Fügt Padding um das Text-Widget
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.text_aligncenter,
                size: 25,
                color: Color.fromARGB(255, 204, 198, 196),
              ),
              SizedBox(width: 20),
              Text(
                'description',
                textAlign: TextAlign.left, // Setzt den Text linksbündig
                style: TextStyle(fontSize: 25, fontFamily: "Karla"),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20), // Fügt Padding um das Text-Widget
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
                hintText: 'None Yet',
                hintStyle: TextStyle(
                    color: Color.fromARGB(255, 204, 198, 196), fontSize: 20),
                border: InputBorder.none),
            style: TextStyle(
              color: Color.fromARGB(255, 74, 70, 70),
              fontWeight: FontWeight.bold,
              fontSize: 25,
              letterSpacing: 0,
            ),
          ),
        )
      ],
    );
  }
}

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(80),
      child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color:  Color.fromARGB(255, 74, 70, 70),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(61, 109, 103, 103),
                  offset: Offset(5.0, 5.0),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                )
              ]),
          child: TextButton(
            onPressed: (){
              Navigator.of(context).push(ShopView.route());
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
              child: Text(
                "Confirm",
                style: TextStyle(
                    color: Color.fromARGB(255, 243, 243, 243),
                    fontFamily: "Karla", 
                    fontSize: 30),
              ),
            ),
          )),
    );
  }
}
