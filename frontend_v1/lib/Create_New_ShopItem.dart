import 'package:flutter/cupertino.dart';

class CreateNewShopitem extends StatelessWidget {
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
                                        top: 0,
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage("https://via.placeholder.com/34x34"),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 15,
                                        top: 10,
                                        child: Container(
                                          width: 4,
                                          height: 14,
                                          decoration: ShapeDecoration(
                                            color: Color(0xFFB4B4B4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 24,
                                        top: 15,
                                        child: Transform(
                                          transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                          child: Container(
                                            width: 4,
                                            height: 14,
                                            decoration: ShapeDecoration(
                                              color: Color(0xFFB4B4B4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(100),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 51,
                                top: 1,
                                child: SizedBox(
                                  width: 288,
                                  height: 31.94,
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
                                top: 1,
                                child: SizedBox(
                                  width: 274,
                                  height: 32,
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
              Positioned(
                left: -53,
                top: -199,
                child: Container(
                  width: 496,
                  height: 258,
                  decoration: BoxDecoration(color: Color(0xFFF3F3F3)),
                ),
              ),
              Positioned(
                left: 303,
                top: 21,
                child: Container(
                  height: 16,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 15,
                        child: Transform(
                          transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-1.57),
                          child: Container(
                            width: 11,
                            height: 22,
                            decoration: ShapeDecoration(
                              color: Color(0xB2D9D9D9),
                              shape: StarBorder.polygon(sides: 3),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 23,
                        top: 0,
                        child: Text(
                          'back',
                          style: TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 14,
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w700,
                            height: 0,
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
      ],
    );
  }
}