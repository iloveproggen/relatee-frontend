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
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(
          children: const [
            CreateNewShopitem(),
          ],
        ),
      ),
    );
  }
}

class CreateNewShopitem extends StatelessWidget {
  const CreateNewShopitem({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        return Column(
          children: [
            Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      // Add functionality to go back
                    },
                  ),
                ),
                Container(
                  width: screenWidth * 0.9,
                  height: 870,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 100), // Adjust as needed
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'New Item...',
                          style: TextStyle(
                            color: Color(0xFF4A4646),
                            fontSize: 32,
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Add your other widgets here
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
