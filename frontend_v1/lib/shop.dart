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
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: ShopView(),
          ),
        ),
      ),
    );
  }
}

class ShopView extends StatelessWidget {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'The Shop',
          style: TextStyle(
            color: Color(0xFF4A4646),
            fontSize: 40,
            fontFamily: 'Karla',
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Spend your hard-earned points for goodies!',
          style: TextStyle(
            color: Color(0xFF4A4646),
            fontSize: 20,
            fontFamily: 'Karla',
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildItemCard(context, 'Item 1', 'Buy for 1000pts'),
              const SizedBox(width: 20),
              _buildItemCard(context, 'Item 2', '500pts'),
              const SizedBox(width: 20),
              _buildItemCard(context, 'Item 3', '500pts'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBadge('1150 pts'),
            const SizedBox(width: 20),
            _buildBadge('lvl 25'),
          ],
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () {
            // Implement your back button functionality here
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, color: Color(0xFFD9D9D9)),
              SizedBox(width: 5),
              Text(
                'back',
                style: TextStyle(
                  color: Color(0xFFD9D9D9),
                  fontSize: 14,
                  fontFamily: 'Karla',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, String title, String subTitle) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEB),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4A4646),
              fontSize: 20,
              fontFamily: 'Karla',
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subTitle,
            style: const TextStyle(
              color: Color(0xFF807D7D),
              fontSize: 15,
              fontFamily: 'Karla',
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEDECEC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFB4B4B4),
          fontSize: 24,
          fontFamily: 'Karla',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
