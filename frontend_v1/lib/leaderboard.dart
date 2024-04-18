import 'package:flutter/material.dart';

void main() {
  runApp(const Leaderboard());
}

class Leaderboard extends StatelessWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF3F3F3),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.085,
                top: MediaQuery.of(context).size.height * 0.046,
                child: Text(
                  'Members',
                  style: TextStyle(
                    color: const Color(0xFF4A4646),
                    fontSize: 24,
                    fontFamily: 'Karla',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.085,
                top: MediaQuery.of(context).size.height * 0.386,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.832,
                  height: MediaQuery.of(context).size.height * 0.34,
                  child: Stack(
                    children: [
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.279,
                        top: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.271,
                          height: MediaQuery.of(context).size.height * 0.34,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE1CE9F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.558,
                        top: MediaQuery.of(context).size.height * 0.125,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.271,
                          height: MediaQuery.of(context).size.height * 0.21,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFBFBCB5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: MediaQuery.of(context).size.height * 0.184,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.271,
                          height: MediaQuery.of(context).size.height * 0.181,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFBC9D96),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.692,
                        top: MediaQuery.of(context).size.height * 0.178,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.138,
                          height: MediaQuery.of(context).size.width * 0.138,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 3,
                                color: const Color(0xFF39555E),
                              ),
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.width * 0.5),
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                "https://via.placeholder.com/75x75"),
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.334,
                        top: MediaQuery.of(context).size.height * 0.158,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.138,
                          height: MediaQuery.of(context).size.width * 0.138,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 3,
                                color: const Color(0xFF39555E),
                              ),
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.width * 0.5),
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                "https://via.placeholder.com/84x84"),
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.436,
                        top: MediaQuery.of(context).size.height * 0.239,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '1',
                                style: TextStyle(
                                  color: const Color(0xFFF3F3F3),
                                  fontSize: 24,
                                  fontFamily: 'Karla',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: 'ST',
                                style: TextStyle(
                                  color: const Color(0xFFF3F3F3),
                                  fontSize: 15,
                                  fontFamily: 'Karla',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.151,
                        top: MediaQuery.of(context).size.height * 0.403,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '3',
                                style: TextStyle(
                                  color: const Color(0xFFF3F3F3),
                                  fontSize: 24,
                                  fontFamily: 'Karla',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: 'RD',
                                style: TextStyle(
                                  color: const Color(0xFFF3F3F3),
                                  fontSize: 15,
                                  fontFamily: 'Karla',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.566,
                        top: MediaQuery.of(context).size.height * 0.369,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '2',
                                style: TextStyle(
                                  color: const Color(0xFFF3F3F3),
                                  fontSize: 24,
                                  fontFamily: 'Karla',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: 'ND',
                                style: TextStyle(
                                  color: const Color(0xFFF3F3F3),
                                  fontSize: 15,
                                  fontFamily: 'Karla',
                                  fontWeight: FontWeight.w800,
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
            ],
          ),
        ),
      ),
    );
  }
}
