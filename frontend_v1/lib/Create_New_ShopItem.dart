import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          bodyText1: TextStyle(
              color: Color.fromARGB(255, 99, 21, 21), fontSize: 20),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(),
              Price(),
              SliderWidget(),
              AddDescription(),
              NoneYet()
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
              padding: EdgeInsets.only(top: 100, left: 20),
              child: TextFormField(
                decoration: InputDecoration.collapsed(
                  hintText: 'new item..',
                ),
                style: TextStyle(fontSize: 30, color: Colors.black),
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
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 100, left: 20),
          child: Icon(CupertinoIcons.add_circled, size: 30),
        ),
        Padding(
          padding: EdgeInsets.only(top: 90, left: 10),
          child: Text(
            'price:',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 90, left: 50),
            child: TextField(
              textAlign: TextAlign.start,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(right: 25, bottom: 5),
                hintText: "price",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(0, 0, 0, 0)),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
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
      child: Padding( // Hinzufügen von Padding um den Container
        padding: EdgeInsets.only(top: 60.0), // Verschieben Sie den Slider nach unten
        child: Container(
          width: 386,
          height: 46,
          decoration: BoxDecoration(
            color: Color(0x7FD9D9D9),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: _isPermanent ? Alignment.centerLeft : Alignment.centerRight,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Container(
                  width: 193,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
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
                          color: _isPermanent ? Colors.black : Color(0xFF4A4646),
                          fontSize: 20,
                          fontFamily: 'Karla',
                          fontWeight: _isPermanent ? FontWeight.w700 : FontWeight.w300,
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
                          color: !_isPermanent ? Colors.black : Color(0xFF4A4646),
                          fontSize: 20,
                          fontFamily: 'Karla',
                          fontWeight: !_isPermanent ? FontWeight.w700 : FontWeight.w300,
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
  const AddDescription({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80, left: 20), // Fügt Padding um das Text-Widget
      child: Align(
        alignment: Alignment.centerLeft, // Stellt sicher, dass der Text linksbündig bleibt
        child: Text(
          'Add Description',
          textAlign: TextAlign.left, // Setzt den Text linksbündig
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class NoneYet extends StatelessWidget {
  const NoneYet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 20), // Fügt Padding um das Text-Widget
        child: Text(
          'None Yet',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
            fontSize: 20,
          ),
        ),
    );
  }
}