import 'package:flutter/material.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:share/share.dart';

class HouseholdInvitation extends StatefulWidget {
  const HouseholdInvitation({super.key});

  @override
  _HouseholdInvitationState createState() => _HouseholdInvitationState();
}

class _HouseholdInvitationState extends State<HouseholdInvitation> {
  final TextEditingController _controller = TextEditingController();
  bool _isFieldEmpty = false;

  // initialise the controller for the user input field
  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
  }

  // Method to validate the input field
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
                'Invite_Members_txt'.tr,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 40),
              Text(
                'Send_Invitation_txt'.tr,
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
                  hintText: 'Mail_address_txt'.tr,
                  hintStyle: _isFieldEmpty
                      ? Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.red)
                      : Theme.of(context).textTheme.bodySmall,
                  //errorText: _isFieldEmpty ? 'Field_required_txt'.tr : null,
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
              Padding(
                padding: const EdgeInsets.only(left: 220),
                child: ElevatedButton(
                  onPressed: () {
                    //hier den Code einfügen, der die Mail verschickt
                  },
                  child: Text(
                    'Send Mail',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                style: ButtonStyle(
                    alignment: Alignment.centerLeft,
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.all(0))),
                onPressed: () {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  Share.share(
                    'Hey! I am inviting you to join my household. Use the following to join:', //add the Household ID here
                    subject: 'Invitation Code',
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size,
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share_Invitation_Button_txt'.tr,
                      style: Theme.of(context).textTheme.bodySmall,
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
