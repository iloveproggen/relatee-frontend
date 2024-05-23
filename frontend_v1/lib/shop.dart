import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/Create_New_ShopItem.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart' as profile;
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<List<Map<String, dynamic>>> getRewards(int id) async {
  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql('''
  query GetUserRewards(\$id: Int!) {
    household(id: \$id) {
        rewards {
            id,
            name,
            price,
            description
        }
    }
}
'''),
    variables: <String, dynamic>{
      'id': id,
    },
  );
  try {
    final result =
        await client.query(options).timeout(const Duration(seconds: 10));

    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      final rewards = result.data!['household']['rewards'];
      final List<Map<String, dynamic>> mappedRewards =
          rewards.map<Map<String, dynamic>>((reward) {
        return {
          'id': reward['id'],
          'name': reward['name'],
          'price': reward['price'],
          'description': reward['description'],
        };
      }).toList();
      print(mappedRewards);
      return mappedRewards;
    }
  } on SocketException catch (e) {
    print('Network error: $e');
    // Handle network error
  } on TimeoutException catch (e) {
    print('Request timed out: $e');
    // Handle timeout
  } catch (e) {
    print('Unexpected error: $e');
    // Handle other errors
  }
  return [];
}

Future<void> deleteReward(int id) async {
  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql('''
      mutation DeleteReward(\$id: Int!) {
        deleteReward(id: \$id) {
        }
      }
    '''),
    variables: <String, dynamic>{
      'id': id,
    },
  );
  try {
    await client.mutate(options).timeout(const Duration(seconds: 10));

  } on SocketException catch (e) {
    print('Network error: $e');
    // Handle network error
  } on TimeoutException catch (e) {
    print('Request timed out: $e');
    // Handle timeout
  } catch (e) {
    print('Unexpected error: $e');
    // Handle other errors
  }
}

bool isBuyable(int price, int points) {
  return points >= price;
}

// ignore: must_be_immutable
class ShopIcon extends StatefulWidget {
  const ShopIcon({
    super.key,
  });

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
        height: 35,
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
  const ShopView({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<ShopView> createState() => ShopViewState(userData: userData);
}

class ShopViewState extends State<ShopView> {
  ShopViewState({required this.userData});

  final Map<String, dynamic> userData;

  @override

  // Getter for the itemCards list

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const profile.BackIconRow(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Shop_title'.tr,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
                TextButton(
                    onPressed: () {
                      Get.to(() => NewShopItem(userData: userData));
                    },
                    child: const Icon(CupertinoIcons.add,
                        color: Color.fromARGB(255, 204, 198, 196), size: 35))
              ],
            ),
            Text(
              ('Shop_info'.tr),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: getRewards(userData['householdId']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final rewards = snapshot.data!;
                      if (rewards.isEmpty) {
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            Text('No rewards available. Create new ones!',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        );
                      } else {
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: rewards.length,
                          itemBuilder: (context, index) {
                            final reward = rewards[index];
                            return Dismissible(
                              key: Key(reward.toString()),
                              onDismissed: (direction) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: Text(
                                          'Are you sure you want to delete the reward \"${reward['name']}\"?'),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            Get.back();
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            setState(() {});
                                          },
                                          child: const Text('No',
                                              style: TextStyle(
                                                  color: Colors.blue)),
                                        ),
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            deleteReward(reward['id']);
                                            setState(() {});
                                          },
                                          child: const Text('Yes',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              background: Container(
                                margin: const EdgeInsets.only(
                                    right: 50, bottom: 22),
                                alignment: Alignment.centerRight,
                                child: const Icon(CupertinoIcons.delete,
                                    color: Colors.red, size: 30),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                title: ItemCard(
                                  taskName: reward['name'],
                                  taskPrice: reward['price'].toString(),
                                  description: reward['description'],
                                  userData: userData,
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }
                  }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildBadge(userData['points'] == null
                    ? '0 pts'
                    : '${userData['points']} pts'),
                const SizedBox(width: 20),
                buildBadge('lvl 25'),
              ],
            ),
            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }

  Widget buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
      decoration: BoxDecoration(
        color: const Color.fromARGB(106, 205, 205, 205),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 25),
      ),
    );
  }
}

void showNotEnoughPointsDialog(
    BuildContext context, int taskPrice, Map<String, dynamic> userData) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      // Automatically dismiss the dialog after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pop(true); // Dismiss the dialog
      });

      return CupertinoAlertDialog(
        title: const Text(
          'Not enough Points to buy!',
          textAlign: TextAlign.center,
        ),
        content: Text(
          "You need ${taskPrice - userData['points']} more points to buy this item.",
        ),
      );
    },
  );
}

// ignore: must_be_immutable
class ItemCard extends StatelessWidget {
  ItemCard({
    super.key,
    required this.taskName,
    required this.taskPrice,
    required this.description,
    required this.userData,
  });

  final Color colLight = const Color.fromARGB(255, 243, 243, 243);
  final Color colMid = const Color.fromARGB(255, 204, 198, 196);
  final Color colText = const Color(0xFF4A4646);

  final String taskName;
  final String taskPrice;
  final String? description;
  final Map<String, dynamic> userData;

  late bool buyable = false;

  @override
  Widget build(BuildContext context) {
    buyable = isBuyable(int.parse(taskPrice), userData['points']);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary,
                offset: const Offset(5.0, 5.0),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(taskName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    description == "" || description == null
                        ? Container()
                        : Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            "\'$description\'",
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 204, 198, 196),
                              fontSize: 20,
                              fontFamily: "Karla",
                              fontStyle: FontStyle.italic,
                              height: 1),
                            textAlign: TextAlign.start,
                          ),
                          ),
                    Text(
                      "$taskPrice pts",
                      
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 204, 198, 196),
                          fontSize: 20,
                          fontFamily: "Karla"),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                    buyable
                      ? null
                      : showNotEnoughPointsDialog(context, int.parse(taskPrice), userData['points']);
                },
                child: Container(
                    constraints: const BoxConstraints(minWidth: 0),
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 5,
                          strokeAlign: BorderSide.strokeAlignInside,
                          color: buyable ? colMid : colMid.withOpacity(0.5),
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: buyable ? colMid : colLight),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "BUY",
                              style: TextStyle(
                                fontFamily: "Karla",
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: buyable
                                    ? Theme.of(context).colorScheme.background
                                    : Theme.of(context).colorScheme.secondary,
                              ),
                            )))),
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
