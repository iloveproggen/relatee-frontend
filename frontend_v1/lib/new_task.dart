import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend_v1/assets/LocaleStrings.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: LocaleString(),
      locale: const Locale('en-US'),
      fallbackLocale: const Locale('en-US'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      home: const Scaffold(
        body: CreateTaskView(),
      ),
    );
  }
}

class CreateTaskView extends StatelessWidget {
  const CreateTaskView({super.key});

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return const CreateTaskView();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackIconRow(),
            Text(
              'New Task...',
              style: TextStyle(
                color: Color(0xFF4A4646),
                fontSize: 32,
                fontFamily: 'Karla',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20),
            TaskDetailsWidget(),
            SizedBox(height: 20),
            NotesWidget(),
          ],
        ),
      ),
    );
  }
}

class TaskDetailsWidget extends StatelessWidget {
  const TaskDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      width: deviceWidth,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              TaskAttributeWidget(
                iconUrl: 'https://via.placeholder.com/34x34',
                label: 'repeats:',
                value: '',
              ),
              SizedBox(width: 10),
              TaskAttributeWidget(
                iconUrl: 'https://via.placeholder.com/34x34',
                label: 'assign to:',
                value: 'Michelle (you)',
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Points:',
            style: TextStyle(
              color: Color(0xFF4A4646),
              fontSize: 20,
              fontFamily: 'Karla',
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '15',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xFF4A4646),
              fontSize: 20,
              fontFamily: 'Karla',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskAttributeWidget extends StatelessWidget {
  final String iconUrl;
  final String label;
  final String value;

  const TaskAttributeWidget({
    super.key,
    required this.iconUrl,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(iconUrl),
              fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4A4646),
            fontSize: 16,
            fontFamily: 'Karla',
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color(0xFF4A4646),
            fontSize: 16,
            fontFamily: 'Karla',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class NotesWidget extends StatelessWidget {
  const NotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      width: deviceWidth,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes:',
            style: TextStyle(
              color: Color(0xFF4A4646),
              fontSize: 20,
              fontFamily: 'Karla',
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'None yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB4B4B4),
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontFamily: 'Karla',
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
