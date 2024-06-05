import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:share/share.dart';

class HouseholdInvitation extends StatefulWidget {
  const HouseholdInvitation({super.key});

  @override
  _HouseholdInvitationState createState() => _HouseholdInvitationState();
}

class _HouseholdInvitationState extends State<HouseholdInvitation> {
  final TextEditingController _controller = TextEditingController();
  bool _isFieldEmpty = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isFieldEmpty = _controller.text.isEmpty;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackIconRow(),
              Text(
                'Invite Members',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 40),
              Text(
                'Send an email invitation to new members to join your household.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
                TextField(
                controller: _controller,
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Enter email address',
                  hintStyle: _isFieldEmpty
                    ? Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.red)
                    : Theme.of(context).textTheme.bodySmall,
                  errorText:
                    _isFieldEmpty ? 'This field is required' : null,
                  focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  ),
                ),
                ),
              const SizedBox(height: 20),
              TextButton(
                style: ButtonStyle(alignment: Alignment.centerLeft,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(0))),
                onPressed: () {
                  final RenderBox box =
                      context.findRenderObject() as RenderBox;
                  Share.share(
                    'Hey! I am inviting you to join my household on HomeTasks. Use the following to join:',
                    subject: 'Invitation Code',
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size,
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Invitation...',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    //SizedBox(width: 10),
                    //Icon(CupertinoIcons.share, color: Theme.of(context).colorScheme.onSecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
