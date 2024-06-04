import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void createShopItem(String name, String description, int price,
    Map<String, dynamic> userData) async {
  final Map<String, dynamic> variables = {
    'householdId': userData['householdId'],
    'name': name,
    'description': description,
    'price': price
  };

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(r'''
  mutation CreateReward($householdId: Int!, $name: String!, $description: String, $price: Int!) {
    createReward(householdId: $householdId, name: $name, description: $description, price: $price) {
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
      print("pushed the new item to the db: $variables");
    }
  } catch (e) {
    print(e);
  }
}

class NewShopItem extends StatefulWidget {
  const NewShopItem({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<NewShopItem> createState() => _NewShopItemState(userData: userData);
}

class _NewShopItemState extends State<NewShopItem> {
  _NewShopItemState({required this.userData});

  final Map<String, dynamic> userData;
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
                        createShopItem(taskName.text, description.text,
                            int.parse(taskPrice.text), userData);
                        Get.forceAppUpdate();
                        Get.back();
                      } else {
                        Get.back();
                      }
                    },
                    child: Text(required ? "Confirm" : "Cancel",
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
                            hintText: 'new item...',
                            hintStyle:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Color.fromARGB(255, 204, 198, 196),
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
                      'price:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: TextField(
                          cursorColor:
                              Theme.of(context).colorScheme.onSecondary,
                          textAlign: TextAlign.end,
                          controller: taskPrice,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                              hintText: "add price",
                              hintStyle: TextStyle(
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
                          'description:',
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
                        decoration: const InputDecoration(
                            counterText: "",
                            hintText: 'add description...',
                            hintStyle: TextStyle(
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
                    'permanent',
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
                    'only once',
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
