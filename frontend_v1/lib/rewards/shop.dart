import 'package:frontend_v1/core/services/reward_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_v1/rewards/create_new_reward.dart';
import 'package:frontend_v1/core/logging/app_logger.dart';
import 'package:frontend_v1/rewards/detailed_reward_view.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profile/profile_v2.dart' as profile;
import 'package:get/get.dart';

bool didUserDataChange = false;

Future<void> claimReward(int userId, int rewardId) async {
  didUserDataChange = true;
  AppLogger.info('Claim reward requested by userId=$userId');
  await RewardService.claimReward(rewardId);
}

Future<Map<String, dynamic>> getRewards() =>
    RewardService.getRewardsWithCoins();

Future<void> deleteReward(int id) async {
  await RewardService.deleteReward(id);
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
            end: userColor // Target color
            )
        .animate(_controller);
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
  State<ShopView> createState() => ShopViewState();
}

class ShopViewState extends State<ShopView> {
  late Future<Map<String, dynamic>> _futureRewards;
  int _coins = 0;

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
              final List<Map<String, dynamic>> rewards =
                  snapshot.data!['rewards'];
              _coins = snapshot.data!['coins'];
              rewards.sort((a, b) => a['price'].compareTo(b['price']));
              rewards.sort((a, b) {
                if (a['stock'] == 0 && b['stock'] != 0) {
                  return 1;
                } else if (a['stock'] != 0 && b['stock'] == 0) {
                  return -1;
                } else {
                  return 0;
                }
              });
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  profile.BackIconRow(updateNeeded: didUserDataChange),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const ShopIcon(),
                          const SizedBox(width: 10),
                          Text('Shop_title'.tr,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                      TextButton(
                          onPressed: () async {
                            var result = await Get.to(
                                () => NewShopItem(userData: widget.userData));
                            if (result != null) {
                              _updateRewards();
                            }
                          },
                          child: Icon(CupertinoIcons.add,
                              color: userColor, size: 35))
                    ],
                  ),
                  Text(
                    ('Shop_info'.tr),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  rewards.isEmpty
                      ? Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                                'No rewards available. Create new ones!',
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 20),
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
                                                style: TextStyle(
                                                    color: Colors.red)),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
                                      userData: widget.userData,
                                      coins: _coins,
                                      onPurchase: _updateRewards,
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
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/images/relatee.svg",
                              height: 20,
                              width: 20,
                              colorFilter:
                                  ColorFilter.mode(userColor, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 5),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 100,
                              ),
                              child: Text(
                                maxLines: 1,
                                _coins.toString(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
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
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "lvl ${widget.userData['level'].toString()}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50)
                ],
              );
            }
          }),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.reward,
    required this.userData,
    required this.coins,
    required this.onPurchase,
  });

  final Map<String, dynamic> reward;
  final Map<String, dynamic> userData;
  final int coins;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final buyable = isBuyable(reward['price'] ?? 0, coins);
    final hasEmoji = reward['emoji'] != null &&
        reward['emoji'] != "" &&
        !reward['emoji'].contains(" ");
    final displayEmoji = hasEmoji ? "${reward['emoji']} " : "";
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                    Text(
                      "$displayEmoji${reward['name']}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          "${reward['price']}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 5),
                        Opacity(
                          opacity: 0.8,
                          child: SvgPicture.asset(
                            "assets/images/relatee.svg",
                            height: 15,
                            colorFilter:
                                ColorFilter.mode(userColor, BlendMode.srcIn),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        reward['stock'] == -1
                            ? const Text("")
                            : reward['stock'] == 0
                                ? Text("out of stock!",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold))
                                : Text("${reward['stock'].toString()}x",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            fontWeight: FontWeight.bold)),
                      ],
                    ),
                    reward['description'] == "" || reward['description'] == null
                        ? Container(height: 10)
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              child: Text(
                                "'${reward['description']}'",
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          )
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  if (reward['stock'] == 0) {
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          title: const Text("No items left!"),
                          content: const Text(
                            'Edit the item to increase the stock.',
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
                  } else {
                    if (buyable) {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: const Text(
                              'Confirm Purchase',
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              "Are you sure you want to buy this item for ${reward['price']} coins? You'll have ${coins - reward['price']} coins left.",
                            ),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text('Cancel',
                                    style: TextStyle(color: Colors.red)),
                              ),
                              CupertinoDialogAction(
                                onPressed: () async {
                                  await claimReward(
                                      userData['id'], reward['id']);
                                  onPurchase();
                                  // Perform the purchase logic here
                                  if (!context.mounted) return;
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text('Buy',
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          int difference = reward['price'] - userData['coins'];
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
                    }
                  }
                },
                child: Container(
                    constraints: const BoxConstraints(minWidth: 0),
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                          color: buyable && reward['stock'] != 0
                              ? userColor
                              : Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withValues(alpha: 0.5),
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: buyable && reward['stock'] != 0
                            ? userColor
                            : Theme.of(context).colorScheme.primary),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text("BUY",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: buyable && reward['stock'] != 0
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                        fontWeight: FontWeight.bold))))),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
