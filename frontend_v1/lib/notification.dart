import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationCentre extends StatefulWidget {
  const NotificationCentre({Key? key}) : super(key: key);

  @override
  _NotificationCentreState createState() => _NotificationCentreState();
}

class _NotificationCentreState extends State<NotificationCentre> {
  bool showNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              showNotifications = !showNotifications;
            });
          },
          child:Icon(CupertinoIcons.bell_fill, color: Theme.of(context).colorScheme.tertiary, size: 30),
        ),
        if (showNotifications)
          Container(
            width: double.infinity,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Notification 1'),
                Text('Notification 2'),
                Text('Notification 3'),
                // Add more notifications here
              ],
            ),
          ),
      ],
    );
  }
}