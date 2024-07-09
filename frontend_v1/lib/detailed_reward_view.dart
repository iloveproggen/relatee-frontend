import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_v1/create_new_task_v1.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';

Future<void> updateShopItem(int rewardId, String name, int stock, String description, int price, String emoji) async {
  final Map<String, dynamic> variables = {
    'input': {
      'rewardId': rewardId,
      'name': name,
      'emoji': emoji,
      'description': description,
      'stock': stock,
      'price': price,
    },
  };

  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql(r'''
  mutation updateReward($input: UpdateRewardInput!) {
    updateReward(input: $input) {
      id
      name
      description
      price
      emoji
      stock
    }
  }
'''),
    variables: variables,
  );

  try {
    final QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception.toString());
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
  TextEditingController stock = TextEditingController();

  bool required = false;

  String? emojiDisplay;

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
    stock.addListener(_updateRequired);


    taskName.text = widget.shopItem['name'];
    taskPrice.text = widget.shopItem['price'].toString();
    description.text = widget.shopItem['description'];
    stock.text = widget.shopItem['stock'].toString();
    emojiDisplay = widget.shopItem['emoji'];
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
                    onPressed: () async {
                      if (stock.text == "") {
                        stock.text = "-1";
                      }
                      if (required) {
                        await updateShopItem(
                            widget.shopItem['id'],
                            taskName.text,
                            int.parse(stock.text),
                            description.text,
                            int.parse(taskPrice.text),
                            emojiDisplay ?? "");
                        Get.back(result: 'Task_created_txt'.tr);
                      } else {
                        Get.back(result: 'Task_created_txt'.tr);
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
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextFormField(
                    controller: taskName,
                    cursorColor: Theme.of(context).colorScheme.onSecondary,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLength: 30,
                  ),
                  IgnorePointer(
                    child: Visibility(
                      visible: taskName.text.isEmpty,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: ('new_item_txt'.tr),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                            ),
                            TextSpan(
                              text: ' *',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.red.withOpacity(0.5),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //const SliderWidget(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, right: paddingRight),
                    child: Icon(
                      CupertinoIcons.money_dollar_circle,
                      size: iconSize,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    'price_txt'.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Expanded(
                    child: TextField(
                        cursorColor: Theme.of(context).colorScheme.onSecondary,
                        textAlign: TextAlign.end,
                        controller: taskPrice,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          MaxLengthNumberInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                            hintText: 'add_price_txt'.tr,
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 20),
                            border: InputBorder.none),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, right: paddingRight),
                    child: Icon(
                      CupertinoIcons.smiley,
                      size: iconSize,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    'Icon:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  const KeyboardEmojiPickerWrapper(child: SizedBox.shrink()),
                  TextButton(
                    onPressed: () async {
                      final hasEmojiKeyboard =
                          await KeyboardEmojiPicker().checkHasEmojiKeyboard();
                      if (hasEmojiKeyboard) {
                        final pickedEmoji =
                            await KeyboardEmojiPicker().pickEmoji();
                        setState(() {
                          emojiDisplay = pickedEmoji;
                        });
                      } else {
                        showCupertinoModalPopup(
                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text('Emoji Keyboard Disabled'),
                              content: const Text(
                                  'Please enable the emoji keyboard in your device settings.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(0)),
                    ),
                    child: emojiDisplay == null
                        ? Text(
                            "add icon",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          )
                        : Text(
                            emojiDisplay ?? 'add icon',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 30,
                            ),
                          ),
                  ),
                  emojiDisplay != null
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              emojiDisplay = null;
                            });
                          },
                          icon: Icon(CupertinoIcons.clear,
                              color: Theme.of(context).colorScheme.tertiary),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, right: paddingRight),
                    child: Icon(
                      CupertinoIcons.add_circled,
                      size: iconSize,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    'Stock',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Expanded(
                    child: TextField(
                        cursorColor: Theme.of(context).colorScheme.onSecondary,
                        textAlign: TextAlign.end,
                        controller: stock,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          MaxLengthNumberInputFormatter(2),
                        ],
                        decoration: InputDecoration(
                            hintText: 'add stock',
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 20),
                            border: InputBorder.none),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, right: paddingRight),
                        child: Icon(
                          CupertinoIcons.text_aligncenter,
                          size: iconSize,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Expanded(
                          child: Text(
                        'description_txt'.tr,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodySmall,
                      )),
                    ],
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
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary),
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
