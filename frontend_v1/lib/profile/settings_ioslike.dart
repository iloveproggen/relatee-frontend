import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_v1/core/logging/app_logger.dart';

class SettingsIOSLike extends StatefulWidget {
  const SettingsIOSLike({super.key});

  @override
  State<SettingsIOSLike> createState() => _SettingsIOSLikeState();
}

class _SettingsIOSLikeState extends State<SettingsIOSLike> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            if (snapshot.hasData) {
              final prefs = snapshot.data!;
              // Retrieve all key-value pairs as an iterable
              final Iterable<MapEntry<String, Object?>> entries =
                  prefs.getKeys().map(
                        (String key) => MapEntry(key, prefs.get(key)),
                      );
              // Convert the iterable to a map
              final Map<String, dynamic> prefsMap =
                  Map<String, dynamic>.fromEntries(entries);
              AppLogger.info(prefsMap);
              return const SettingsIOSLikeWidget();
            } else {
              return const Text('No data found');
            }
          }
        });
  }
}

class SettingsIOSLikeWidget extends StatefulWidget {
  const SettingsIOSLikeWidget({super.key});

  @override
  State<SettingsIOSLikeWidget> createState() => _SettingsIOSLikeWidgetState();
}

class _SettingsIOSLikeWidgetState extends State<SettingsIOSLikeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
      child: ListView(children: <Widget>[
        CupertinoFormSection(
            header: const Text('Account'),
            children: const <Widget>[
              CupertinoFormRow(
                prefix: Text('Name'),
                child: Text('John Doe'),
              ),
            ])
      ]),
    ));
  }
}
