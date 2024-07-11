import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/main.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<PageViewModel> introPages = [
    PageViewModel(
      title: "Welcome to Relatee!",
      body:
          "The following pages will give you a quick overview of how to use the app. \n\n Swipe or click next to continue or skip to start using the app.",
      image: Padding(
        padding: const EdgeInsets.only(top: 40.0, right: 25.0),
        child: Image.network(
          'https://i.pinimg.com/originals/4c/23/63/4c236364db3543337354bc3acc1fe792.gif',
          width: 200.0,
          height: 200.0,
        ),
      ),
      decoration: PageDecoration(
        pageColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: Theme.of(context).textTheme.bodyLarge!,
        bodyTextStyle: Theme.of(context).textTheme.bodySmall!,
      ),
    ),
    PageViewModel(
      title: "Create a Household!",
      body:
          "Add members to your household and assign them tasks.",
      image: const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: Text("🏡❤️", style: TextStyle(fontSize: 100.0)),
        ),
      ),
      decoration: PageDecoration(
        pageColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: Theme.of(context).textTheme.bodyLarge!,
        bodyTextStyle: Theme.of(context).textTheme.bodySmall!,
      ),
    ),
    PageViewModel(
      title: "Create Tasks!",
      body:
          "Create Tasks and earn coins by completing them. \n\nAssign them to Routines to make them recurring.",
      image: const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: Text("📌📝", style: TextStyle(fontSize: 100.0)),
        ),
      ),
      decoration: PageDecoration(
        pageColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: Theme.of(context).textTheme.bodyLarge!,
        bodyTextStyle: Theme.of(context).textTheme.bodySmall!,
      ),
    ),
    PageViewModel(
      title: "Compete!",
      body:
          "Compare your progress with your household members and see who's the most productive. Earn coins and rewards to stay motivated!",
      image: const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: Text("🏆🥇", style: TextStyle(fontSize: 100.0)),
        ),
      ),
      decoration: PageDecoration(
        pageColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: Theme.of(context).textTheme.bodyLarge!,
        bodyTextStyle: Theme.of(context).textTheme.bodySmall!,
      ),
    ),
    PageViewModel(
      title: "Go Shopping!",
      body:
          "The shop is where you can spend your hard-earned coins. Create custom rewards to make cleaning fun!",
      image: const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: Text("🛒🛍️", style: TextStyle(fontSize: 100.0)),
        ),
      ),
      decoration: PageDecoration(
        pageColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: Theme.of(context).textTheme.bodyLarge!,
        bodyTextStyle: Theme.of(context).textTheme.bodySmall!,
      ),
    ),
    PageViewModel(
      footer:  Center(child: Text("made with love by rhinebytes", style: Theme.of(context).textTheme.labelSmall)),
      title: "You're all set!",
      body: "Click 'Start!' to begin your journey with Relatee.",
      image: const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: Text("ദ്ദി(˵ •̀ ᴗ - ˵ ) ✧", style: TextStyle(fontSize: 50.0)),
        ),
      ),
      decoration: PageDecoration(
        pageColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: Theme.of(context).textTheme.bodyLarge!,
        bodyTextStyle: Theme.of(context).textTheme.bodySmall!,
      ),
    ),
  ];
  return Scaffold(
    body: IntroductionScreen(
      bodyPadding: const EdgeInsets.all(30),
      controlsPadding: EdgeInsets.only(bottom: 50, left: 20, right: 20),
      dotsFlex: 2,
      dotsDecorator: DotsDecorator(
        activeColor: purple,
        color: Theme.of(context).colorScheme.tertiary
      ),
      pages: introPages,
      onDone: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('seenIntro', true);
        Get.back();
      },
      showSkipButton: true,
      skip: Text("Skip", style: Theme.of(context).textTheme.labelLarge),
      next: Text("Next", style: Theme.of(context).textTheme.labelLarge),
      done: Text("Start!", style: Theme.of(context).textTheme.labelLarge),
      back: Text("Back", style: Theme.of(context).textTheme.labelLarge),
    ),
  );
  }
}