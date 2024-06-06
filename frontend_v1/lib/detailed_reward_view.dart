import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_v1/create_new_task_v1.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void updateShopItem(int id, String name, String description, int price) async {
  final Map<String, dynamic> variables = {
    'id': id,
    'name': name,
    'description': description,
    'price': price
  };

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(r'''
  mutation updateReward($id: Int!, $name: String, $description: String, $price: Int) {
    updateReward(id: $id, name: $name, description: $description, price: $price) {
      id
      name
      description
      price
    }
  }
'''),
    variables: variables,
  );

  try {
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      // Handle the result
      print(result.data);
      print("Updated the item in the db: $variables");
    }
  } catch (e) {
    print(e);
  }
}

class UpdateShopItem extends StatefulWidget {
  const UpdateShopItem({super.key, required this.shopItem});

  final Map<String, dynamic> shopItem;

  @override
  State<UpdateShopItem> createState() => _UpdateShopItemState();
}

class _UpdateShopItemState extends State<UpdateShopItem> {
  _UpdateShopItemState();

  TextEditingController taskName = TextEditingController();
  TextEditingController taskPrice = TextEditingController();
  TextEditingController description = TextEditingController();

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
    description.addListener(_updateRequired);

    taskName.text = widget.shopItem['name'];
    taskPrice.text = widget.shopItem['price'].toString();
    description.text = widget.shopItem['description'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackIconRow(),
                  TextButton(
                    style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      animationDuration: Duration.zero,
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(0),
                      ),
                    ),
                    onPressed: () {
                      if (required) {
                        if (taskName.text.isEmpty) {
                          taskName.text = widget.shopItem['name'];
                        }
                        if (taskPrice.text.isEmpty) {
                          taskPrice.text = widget.shopItem['price'].toString();
                        }
                        updateShopItem(widget.shopItem['id'], taskName.text,
                            description.text, int.parse(taskPrice.text));
                        Get.back(result: 'Task Updated');
                      } else {
                        Get.back();
                      }
                    },
                    child: Text(required ? 'Confirm_txt'.tr : 'Cancel_txt'.tr,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: required
                                ? Theme.of(context).colorScheme.onSecondary
                                : const Color.fromARGB(255, 204, 198, 196))),
                  )
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Form(
                  child: Column(
                    children: [
                      TextField(
                          cursorColor:
                              Theme.of(context).colorScheme.onSecondary,
                          controller: taskName,
                          maxLength: 30,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            hintText: 'new_item_txt'.tr,
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color:
                                      const Color.fromARGB(255, 204, 198, 196),
                                ),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SliderWidget(),
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.add_circled,
                      size: 40,
                      color: Color.fromARGB(255, 204, 198, 196),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'price_txt'.tr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: TextField(
                          cursorColor:
                              Theme.of(context).colorScheme.onSecondary,
                          textAlign: TextAlign.end,
                          controller: taskPrice,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            MaxLengthNumberInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                              hintText: 'add_price_txt'.tr,
                              hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 204, 198, 196),
                                  fontSize: 20),
                              border: InputBorder.none),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          CupertinoIcons.text_aligncenter,
                          size: 40,
                          color: Color.fromARGB(255, 204, 198, 196),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                            child: Text(
                          'description_txt'.tr,
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.bodySmall,
                        )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextField(
                        cursorColor: Theme.of(context).colorScheme.onSecondary,
                        maxLines: 4,
                        maxLength: 100,
                        controller: description,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            counterText: "",
                            hintText: 'add_description_txt'.tr,
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 204, 198, 196),
                                fontSize: 20),
                            border: InputBorder.none),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  )
                ],
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
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: const Color(0x7FD9D9D9),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedAlign(
                alignment:
                    _isPermanent ? Alignment.centerLeft : Alignment.centerRight,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'permanent_txt'.tr,
                    style: TextStyle(
                      color:
                          _isPermanent ? Colors.black : const Color(0xFF4A4646),
                      fontSize: 20,
                      fontFamily: 'Karla',
                      fontWeight:
                          _isPermanent ? FontWeight.w700 : FontWeight.w300,
                      height: 0,
                    ),
                  ),
                  Text(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
