import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_v1/create_new_reward.dart';
import 'package:frontend_v1/detailed_reward_view.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart' as profile;
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

late VoidCallback updateShop;
late int coins;
final Color purple = Color(0xFF7C4ACA);

Future<void> claimReward(int userId, int rewardId) async {
  final Map<String, dynamic> variables = {
    'rewardId': rewardId,
  };

  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql(r'''
  mutation ClaimReward($rewardId: Int!) {
    claimReward(rewardId: $rewardId) {
    }
  }
'''),
    variables: variables,
  );

  final QueryResult result = await client.mutate(options);
  if (result.hasException) {
    print(result.exception.toString());
  } else if (result.isLoading) {
    print('Loading');
  } else {
    print("Claimed the reward: $variables");
  }
}

Future<Map<String, dynamic>> getRewards() async {
  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql('''
      query GetUserRewardsAndBalance {
        getRewards: householdRewards {
          id
          name
          price
          emoji
          stock
          description
        }
        getCoins: me {
          coins
        }
      }
    '''),
  );

  try {
    final result =
        await client.query(options).timeout(const Duration(seconds: 10));

    if (result.hasException) {
      print(result.exception.toString());
      return {};
    } else {
      print(result.data);
      final rewardsData =
          result.data!['getRewards'] as List; // Cast to List explicitly
      final List<Map<String, dynamic>> mappedRewards =
          rewardsData.map<Map<String, dynamic>>((reward) {
        return {
          'id': reward['id'],
          'name': reward['name'],
          'price': reward['price'],
          'stock': reward['stock'] ??
              '0', // Provide a default value for stock if null
          'emoji': reward['emoji'] ?? '0',
          'description': reward['description'] ??
              '', // Provide a default value for description if null
        };
      }).toList(); // Convert the result of map() to a List
      coins = result.data!['getCoins']['coins'];
      print(coins);
      print(mappedRewards);
      return {'rewards': mappedRewards, 'coins': coins};
    }
  } on SocketException catch (e) {
    print('Network error: $e');
  } on TimeoutException catch (e) {
    print('Request timed out: $e');
  } catch (e) {
    print('Unexpected error: $e');
  }
  return {};
}
// FutureBuilder(
//               future: _futureBalance,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else {
//                   userCoins = snapshot.data!;
//                   final String coins = snapshot.data!;
//                   print("coins left: $coins");
//                   return
//                 }
//               },
//             ),
// Future<String> getBalance(int userId) async {
//   final client = await getGraphQLClient();
//   final QueryOptions options = QueryOptions(
//     document: gql('''

// '''),
//   );
//   try {
//     final result =
//         await client.query(options).timeout(const Duration(seconds: 10));

//     if (result.hasException) {
//       print(result.exception.toString());
//     } else if (result.isLoading) {
//       print('Loading');
//     } else {
//       print(result.data!['me']['coins'].toString());
//       return result.data!['me']['coins'].toString();
//     }
//   } on SocketException catch (e) {
//     print('Network error: $e');
//     // Handle network error
//   } on TimeoutException catch (e) {
//     print('Request timed out: $e');
//     // Handle timeout
//   } catch (e) {
//     print('Unexpected error: $e');
//     // Handle other errors
//   }
//   return '0';
// }

Future<void> deleteReward(int id) async {
  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql('''
      mutation DeleteReward(\$rewardId: Int!) {
        deleteReward(rewardId: \$rewardId) 
      }
    '''),
    variables: <String, dynamic>{
      'rewardId': id,
    },
  );
  final QueryResult result = await client.mutate(options);
  if (result.hasException) {
    print(result.exception.toString());
  } else if (result.isLoading) {
    print('Loading');
  } else {
    print("Deleted reward? ");
  }
}

bool isBuyable(int price, int? points) {
  return points != null && points >= price;
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

class MainShopView extends StatelessWidget {
  const MainShopView({super.key, required this.userData});

  final Map<String, dynamic> userData; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ShopView(userData: userData));
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
  late Future<Map<String, dynamic>> _futureRewards;

  @override
  void initState() {
    super.initState();
    _futureRewards = getRewards();
  }

  void _updateRewards() {
    setState(() {
      _futureRewards = getRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    updateShop = _updateRewards;
    return Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: FutureBuilder<Map<String, dynamic>>(
            future: _futureRewards,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                print("snapshot data: " + snapshot.data.toString());
                final List<Map<String, dynamic>> rewards =
                    snapshot.data!['rewards'];
                print("rewards: $rewards");
                coins = snapshot.data!['coins'];
                if (rewards.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      Text('No rewards available. Create new ones!',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  );
                } else {
                  rewards.sort((a, b) => a['price'].compareTo(b['price']));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const profile.BackIconRow(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // ShopIcon(),
                              // SizedBox(width: 10),
                              Text('Shop_title'.tr,
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                          TextButton(
                              onPressed: () async {
                                var result = await Get.to(
                                    () => NewShopItem(userData: userData));
                                if (result != null) {
                                  _updateRewards();
                                }
                              },
                              child: const Icon(CupertinoIcons.add,
                                  color: Color.fromARGB(255, 204, 198, 196),
                                  size: 35))
                        ],
                      ),
                      Text(
                        ('Shop_info'.tr),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 20),
                          scrollDirection: Axis.vertical,
                          itemCount: rewards.length,
                          itemBuilder: (context, index) {
                            final reward = rewards[index];
                            return Dismissible(
                              key: Key(reward.toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: Text(
                                          'Are you sure you want to delete the reward "${reward['name']}"?'),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _updateRewards();
                                          },
                                          child: const Text('Back',
                                              style: TextStyle(
                                                  color: Colors.blue)),
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          onPressed: () async {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            await deleteReward(reward['id']);
                                            _updateRewards();
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
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                title: TextButton(
                                  onPressed: () async {
                                    var result = await Get.to(
                                        UpdateShopItem(shopItem: reward));
                                    if (result != null) {
                                      _updateRewards();
                                    }
                                  },
                                  child: ItemCard(
                                    reward: reward,
                                    userData: userData,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 27, vertical: 9),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/relatee.svg",
                                  height: 20,
                                  width: 20,
                                  color: purple,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  coins.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 25),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 27, vertical: 9),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "lvl ${userData['level'].toString()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 25),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50)
                    ],
                  );
                }
              }
            }),
      );
  }
}


// ignore: must_be_immutable
class ItemCard extends StatefulWidget {
  const ItemCard({
    super.key,
    required this.reward,
    required this.userData,
  });

  final Map<String, dynamic> reward;
  final Map<String, dynamic> userData;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late bool buyable = false;

  @override
  void initState() {
    super.initState();
    print(widget.reward['emoji']);
    if (widget.reward['emoji'] != "") {
      widget.reward['emoji'] = widget.reward['emoji'] + " ";
    }
    buyable = isBuyable(widget.reward['price'], coins);
  }

  @override
  Widget build(BuildContext context) {
    print(buyable);
    print(coins);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary,
                offset: const Offset(5.0, 5.0),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${widget.reward['emoji']}${widget.reward['name']}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text(
                          "${widget.reward['price']}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 5),
                        Opacity(
                          opacity: 0.8,
                          child: SvgPicture.asset(
                            "assets/images/relatee.svg",
                            height: 15,
                            color: purple,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                            widget.reward['stock'] == -1
                                ? ""
                                : "${widget.reward['stock'].toString()}x",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    widget.reward['description'] == "" ||
                            widget.reward['description'] == null
                        ? Container(height: 10)
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              child: Text(
                                "\'${widget.reward['description']}\'",
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          )
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  buyable
                      ? showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text(
                                'Confirm Purchase',
                                textAlign: TextAlign.center,
                              ),
                              content: Text(
                                  "Are you sure you want to buy this item for ${widget.reward['price']} coins?"),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                CupertinoDialogAction(
                                  onPressed: () async {
                                    await claimReward(widget.userData['id'],
                                        widget.reward['id']);

                                    updateShop();
                                    // Perform the purchase logic here
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Buy',
                                      style: TextStyle(color: Colors.blue)),
                                ),
                              ],
                            );
                          },
                        )
                      : showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            int difference = widget.reward['price'] -
                                widget.userData['coins'];
                            return CupertinoAlertDialog(
                              title: const Text("Not enough Points to buy"),
                              content: Text(
                                'You\'re missing $difference coins!',
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(color: Colors.blue),
                                    )),
                              ],
                            );
                          },
                        );
                },
                child: Container(
                    constraints: const BoxConstraints(minWidth: 0),
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                          color: buyable
                              ? purple.withOpacity(0.0)
                              : Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.5),
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: buyable
                            ? purple.withOpacity(0.8)
                            : Theme.of(context).colorScheme.primary),
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
                                      : Theme.of(context)
                                          .colorScheme
                                          .tertiary
                                          .withOpacity(0.5)),
                            )))),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
