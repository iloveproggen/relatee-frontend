import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileView(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: screenHeight * 0.1,
          ),
          SizedBox(
            height: screenHeight * 0.4,
            child: Stack(
              children: [
                Positioned(
                  left: screenWidth * 0.15,
                  top: screenHeight * 0.2,
                  child: Container(
                    width: screenWidth * 0.7,
                    height: screenHeight * 0.2,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9D9D9),
                    ),
                  ),
                ),
                Positioned(
                  left: screenWidth * 0.02,
                  top: screenHeight * 0.03,
                  child: Container(
                    width: screenWidth * 0.96,
                    height: screenHeight * 0.4,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            NetworkImage("https://via.placeholder.com/439x273"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: screenWidth * 0.065,
                  top: screenHeight * 0.09,
                  child: Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 5,
                        color: const Color(0xFF39555E),
                      ),
                    ),
                    child: const ClipOval(
                      child: Image(
                        image:
                            NetworkImage("https://via.placeholder.com/185x176"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: screenWidth * 0.05,
                  top: screenHeight * 0.25,
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Michelle Gerwald',
                          style: TextStyle(
                            color: Color(0xFF4A4646),
                            fontSize: 32,
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '@michiee123',
                          style: TextStyle(
                            color: Color(0xFF4A4646),
                            fontSize: 16,
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'part of household “Campus Living”',
                          style: TextStyle(
                            color: Color(0xFF4A4646),
                            fontSize: 16,
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'View Michelle’s Tasks',
            style: TextStyle(
              color: Color(0xFF4A4646),
              fontSize: 24,
              fontFamily: 'Karla',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const TaskItem(
            title: 'do the dishes',
            status: 'overdue',
          ),
          const TaskItem(
            title: 'take out trash',
            status: 'due in 2 days',
          ),
          const TaskItem(
            title: 'mop floor',
            status: 'due in 2 days',
          ),
        ],
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final String title;
  final String status;

  const TaskItem({
    Key? key,
    required this.title,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF4A4646),
            fontSize: 20,
            fontFamily: 'Karla',
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: status == 'overdue'
                ? const Color(0xFFEC5656)
                : const Color(0xFFB4B4B4),
            fontSize: 20,
            fontFamily: 'Karla',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
