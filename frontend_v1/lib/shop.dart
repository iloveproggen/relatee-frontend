import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/Create_New_ShopItem.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class ShopIcon extends StatefulWidget {
  const ShopIcon({super.key,});

  @override
  State<ShopIcon> createState() => _ShopIconState();
}

class _ShopIconState extends State<ShopIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 300), // Adjust the duration as needed
    );
    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 204, 198, 196), // Initial color
      end: const Color.fromARGB(255, 112, 80, 228), // Target color
    ).animate(_controller);
    _controller.addListener(() {
      setState(() {}); // Trigger rebuild when animation value changes
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleColor() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse(); // If animation is completed, reverse it
    } else {
      _controller.forward(); // Otherwise, start the animation
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _toggleColor(); // Toggle the color animation
      },
      child: SvgPicture.asset(
        "assets/images/relatee.svg",
        height: 40,
        colorFilter: ColorFilter.mode(
          _colorAnimation.value ??
              Colors
                  .transparent, // Provide a default color if _colorAnimation.value is null
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class ShopView extends StatefulWidget {
  const ShopView({super.key, this.itemToAdd, required this.username});

  final ItemCard? itemToAdd; 
  final String username;
  
  @override
  State<ShopView> createState() => ShopViewState();
}
class ShopViewState extends State<ShopView> {
  final List<Widget> itemCards = [
    const ItemCard(taskName: "Task 1", taskPrice: "9999")
  ];

  @override
  void initState() {
    super.initState();
    // Add item if passed through route arguments
    if (widget.itemToAdd != null) {
      addItem(widget.itemToAdd!);
    }
  }

  void addItem(ItemCard item) {
      itemCards.add(item);
  }

  // Getter for the itemCards list
  List<Widget> get getItemCards => itemCards;
  String get username => widget.username;

  final Color colLight = const Color.fromARGB(255, 243, 243, 243);
  final Color colMid = const Color.fromARGB(255, 204, 198, 196);
  final Color colText = const Color(0xFF4A4646);

  @override
  Widget build(BuildContext context) {

  final Color primColor = Theme.of(context).colorScheme.primary;//const Color.fromARGB(255, 243, 243, 243);  colLight
  final Color secColor = Theme.of(context).colorScheme.secondary; //const Color(0xFF4A4646); colText

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BackIconRow(username: username),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shop_title'.tr,
                  style: const TextStyle(
                    color: Color(0xFF4A4646),
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                    onPressed: () {
                    Get.to(NewShopItem(username: username));
                      
                    },
                    child: Icon(CupertinoIcons.add,
                        color: secColor, size: 35))//Color.fromARGB(255, 204, 198, 196), size: 35))
              ],
            ),
            Text(
              ('Shop_info'.tr),
              style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 74, 70, 70),
                  fontFamily: "Karla",
                  letterSpacing: 0),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: itemCards.length,
                itemBuilder: (context, index) {
                  return itemCards[index];
                },
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildBadge(context ,'1150 pts', backgroundColor: primColor, textColor: secColor), //help Michelle, habe cmd + . und den parameter hinzugefügt
                const SizedBox(width: 20),
                buildBadge(context, 'lvl 25', backgroundColor: primColor, textColor: secColor),
              ],
            ),
            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }

  Widget buildBadge(BuildContext context, String text, {required backgroundColor, required Color textColor}) {  //help Michelle habe context hinzugefügt
    
  final Color primColor = Theme.of(context).colorScheme.primary;//const Color.fromARGB(255, 243, 243, 243);  colLight
  final Color secColor = Theme.of(context).colorScheme.secondary; //const Color(0xFF4A4646); colText
    
   
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
      decoration: BoxDecoration(
        color: primColor, //const Color(0xFFEDECEC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: secColor, //Color(0xFFB4B4B4),
          fontSize: 24,
          fontFamily: 'Karla',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key, required this.taskName, required this.taskPrice,
  });

  final String taskName;
  final String taskPrice;

  @override
  Widget build(BuildContext context) {

  final Color primColor = Theme.of(context).colorScheme.primary;//const Color.fromARGB(255, 243, 243, 243);  colLight
  final Color colMid = const Color.fromARGB(255, 204, 198, 196);
  final Color secColor = Theme.of(context).colorScheme.secondary; //const Color(0xFF4A4646); colText

    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: primColor,//const Color.fromARGB(255, 243, 243, 243),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: secColor,//Color.fromARGB(61, 109, 103, 103),
            offset: Offset(5.0, 5.0),
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    taskName,
                    style: TextStyle(
                      color: secColor,//Color(0xFF4A4646),
                      fontSize: 20,
                      fontFamily: 'Karla',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "$taskPrice pts",
                  style: TextStyle(
                      color: secColor,//Color.fromARGB(255, 204, 198, 196),
                      fontSize: 20,
                      fontFamily: "Karla"),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  color: secColor,//colMid,
                ),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "BUY",
                      style: TextStyle(
                          fontFamily: "Karla",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: primColor,//Color.fromARGB(255, 243, 243, 243)),
                      )
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }
}
