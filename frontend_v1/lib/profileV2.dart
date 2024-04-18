import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: ProfileView(),
        ),
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:100),
                    child: Column(
                      children: [
                        Container(
                          width: screenWidth * 0.4,
                          height: screenWidth * 0.4,
                          decoration: const ShapeDecoration(
                            shape: CircleBorder(
                              side: BorderSide(
                                width: 6,
                                color: Color(0xFF39555E),
                              ),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                  "https://via.placeholder.com/185x176"),
                              fit: BoxFit.fill,)
                          ),
                        ),
                        Container(height:30)
                      ],
                    ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoContainer('1150 pts'),
                    const SizedBox(width: 10),
                    _buildInfoContainer('lvl 25'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Michelle Gerwald',
            style: TextStyle(
              color: Color(0xFF4A4646),
              fontSize: 32,
              fontFamily: 'Karla',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'part of household "',
                  style: TextStyle(
                    color: Color(0xFF4A4646),
                    fontSize: 16,
                    fontFamily: 'Karla',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                TextSpan(
                  text: 'Campus Living',
                  style: TextStyle(
                    color: Color(0xFF4A4646),
                    fontSize: 16,
                    fontFamily: 'Karla',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: '"',
                  style: TextStyle(
                    color: Color(0xFF4A4646),
                    fontSize: 16,
                    fontFamily: 'Karla',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            '@michiee123',
            style: TextStyle(
              color: Color(0xFF4A4646),
              fontSize: 16,
              fontFamily: 'Karla',
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Divider(
            color: Color(0xFFB4B4B4),
            height: 20,
            thickness: 2,
            indent: 20,
            endIndent: 20,
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

  Widget _buildInfoContainer(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
      decoration: const BoxDecoration(
        color: Color(0xFFEDECEC),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF4A4646),
          fontSize: 24,
          fontFamily: 'Karla',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final String title;
  final String status;

  const TaskItem({
    super.key,
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4A4646),
              fontSize: 20,
              fontFamily: 'Karla',
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
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
