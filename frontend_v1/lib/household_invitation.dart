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
            children: [
              const BackIconRow(),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                child: Text(
                  'HouseholdInvitation',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Who do you want to invite?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
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
                              color: _isFieldEmpty
                                  ? Colors.blue
                                  : Colors.transparent)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: _isFieldEmpty
                                  ? Colors.green
                                  : Colors.transparent)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
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
                    child: Text(
                      'Share Invitation',
                      style: Theme.of(context).textTheme.bodySmall,
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
