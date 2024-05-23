import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:frontend_v1/shop.dart';
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
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
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
                        decoration: const InputDecoration.collapsed(
                          hintText: 'new item...',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Sedan",
                            fontSize: 40,
                            color: Color.fromARGB(255, 204, 198, 196),
                          ),
                        ),
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
                      'price:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: TextField(
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          CupertinoIcons.text_aligncenter,
                          size: 25,
                          color: Color.fromARGB(255, 204, 198, 196),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            'description',
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.bodySmall,
                              )
                              ),
                      
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextField(
                      maxLines: 3,
                      controller: description,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          hintText: 'None Yet',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 204, 198, 196),
                              fontSize: 20),
                          border: InputBorder.none),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)
                    ),
                  )
                ],
              ),
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
                          createShopItem(taskName.text, description.text, int.parse(taskPrice.text), userData);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => MainWidget(userId: userData['id'])),
                            (route) => false,
                          );
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => ShopView(userData: userData)))
                          ).then((value) {
                          setState(() {
                            // Perform any state updates here
                          });
                        });
                        
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
                        child: Text(
                          required ? "Confirm" : "Cancel",
                          style: required
                              ? const TextStyle(
                                  color: Color.fromARGB(255, 243, 243, 243),
                                  fontFamily: "Karla",
                                  fontSize: 30,
                                )
                              : const TextStyle(
                                  color: Color.fromARGB(255, 204, 198, 196),
                                  fontFamily: "Karla",
                                  fontSize: 30,
                                ),
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
