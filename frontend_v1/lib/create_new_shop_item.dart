import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:frontend_v1/shop.dart';
import 'package:get/get.dart';

class NewShopItem extends StatefulWidget {
  const NewShopItem({super.key, required this.userData});

  final Future<List<Map<String, dynamic>>> userData;

  @override
  State<NewShopItem> createState() => _NewShopItemState();
}

//purpose: Create a new shop item
//author: Rene, Michelle, Maurice
//Date: 11.04.2024

class _NewShopItemState extends State<NewShopItem> {
  TextEditingController taskName = TextEditingController();
  TextEditingController taskPrice = TextEditingController();

  Future<List<Map<String, dynamic>>> get userData => widget.userData;
  bool required = false;

  void _updateRequired() {
    setState(() {
      required = _checkInputs(); // Update required based on inputs
    });
  }

  bool _checkInputs() {
    return taskName.text.isNotEmpty && taskPrice.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Add listener to text controllers to update required variable
    taskName.addListener(_updateRequired);
    taskPrice.addListener(_updateRequired);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            children: [
              const BackIconRow(),
              Align(
                alignment: Alignment.topLeft,
                child: Form(
                  child: Column(
                    children: [
                      TextField(
                        controller: taskName,
                        decoration: InputDecoration.collapsed(
                            hintText: 'new_item_txt'.tr,
                            hintStyle: Theme.of(context).textTheme.bodySmall),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Sedan",
                          fontSize: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliderWidget(),
              Padding(
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
                    Text(
                      'price_txt'.tr,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.end,
                        controller: taskPrice,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            hintText: "add_price_txt".tr,
                            hintStyle: Theme.of(context).textTheme.bodySmall,
                            border: InputBorder.none),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 74, 70, 70),
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                    ),
                  ],
                ),
              ),
              const AddDescription(),
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Container(
                    decoration: required
                        ? const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color.fromARGB(255, 74, 70, 70),
                            boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(61, 109, 103, 103),
                                  offset: Offset(5.0, 5.0),
                                  blurRadius: 10.0,
                                  spreadRadius: 2.0,
                                )
                              ])
                        : BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                strokeAlign: BorderSide.strokeAlignOutside,
                                width: 5,
                                color:
                                    const Color.fromARGB(255, 204, 198, 196)),
                            color: const Color.fromARGB(255, 243, 243, 243),
                          ),
                    child: TextButton(
                      onPressed: () {
                        if (required == false) {
                          Get.back();
                        } else {
                          //implement here: instead of using the newShopItem as parameter, add sql statement that adds it to the db
                          Get.to(() => ShopView(
                                userData: userData,
                                itemToAdd: ItemCard(
                                  taskName: taskName.text,
                                  taskPrice: taskPrice.text,
                                ),
                              ));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
                        child: Text(
                          required ? 'Confirm_txt'.tr : 'Cancel_txt'.tr,
                          style: required
                              ? Theme.of(context).textTheme.bodyMedium
                              : Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

//purpose: Create a slider widget
//author: Rene, Michelle, Maurice
//Date: 11.04.2024

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
                        'permanent_txt'.tr,
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
                        'only_once_txt'.tr,
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

//purpose: Create a back icon row
//author: Rene, Michelle, Maurice
//Date: 11.04.2024

class AddDescription extends StatelessWidget {
  const AddDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
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
                'description_txt'.tr,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 25, fontFamily: "Karla"),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: TextField(
            maxLines: 3,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
                hintText: 'None_Yet_txt'.tr,
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
