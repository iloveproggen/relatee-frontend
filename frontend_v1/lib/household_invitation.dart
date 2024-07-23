import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:share/share.dart';

String? inviteCode;
String? inviteEmail;
String? errorCode;

Future<String> setInvite(String email) async {
  final client = await getGraphQLClient();
  final MutationOptions options = MutationOptions(
    document: gql('''
      mutation createInviteByEmail(\$email: String!, \$expiresAt: DateTime!) {
      createInviteByEmail(email: \$email, expiresAt: \$expiresAt) {
        code
      }
      }
    '''),
    variables: <String, dynamic>{
      'email': email,
      'expiresAt':
          '${DateTime.now().add(Duration(days: 7)).toIso8601String().split('.')[0]}Z'
    },
  );
  try {
    final result =
        await client.mutate(options).timeout(const Duration(seconds: 10));
    if (result.hasException) {
      if (result.exception!.graphqlErrors
          .any((error) => error.message.contains('Unique constraint failed'))) {
        print('An invite for this email already exists.');
        errorCode = 'An invite for this email already exists.';
        return ''; // Handle other error
        // Handle the unique constraint error specifically
      } else {
        print('GraphQL error: ${result.exception.toString()}');
        return ''; // Handle other errors
      }
    } else {
      return result.data!['createInviteByEmail']['code'];
    }
  } on SocketException catch (e) {
    print('Network error: $e');
    errorCode = "Network Error";
    // Handle network error
    return ''; // Handle other errors
  } on TimeoutException catch (e) {
    print('Request timed out: $e');
    errorCode = "Request timed out";
    // Handle timeout
    return ''; // Handle other errors
  } catch (e) {
    print('Unexpected error: $e');
    errorCode = "Unexpected error";
    return ''; // Handle other errors
  }
}

class HouseholdInvitation extends StatefulWidget {
  const HouseholdInvitation({super.key});

  @override
  _HouseholdInvitationState createState() => _HouseholdInvitationState();
}

class _HouseholdInvitationState extends State<HouseholdInvitation> {
  final TextEditingController _controller = TextEditingController();
  FocusNode _emailFocusNode = FocusNode();
  bool isValidEmail = false;

  // initialise the controller for the user input field
  @override
  void initState() {
    super.initState();
    _emailFocusNode.requestFocus();
    errorCode = '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool validateEmail(String email) {
    // Regular expression pattern to validate email address
    final pattern =
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$';
    final regExp = RegExp(pattern);

    // Check if the email matches the pattern
    return regExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BackIconRow(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invite_Members_txt'.tr,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  IconButton(
                    style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      animationDuration: Duration.zero,
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    icon: Icon(
                      CupertinoIcons.info,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: const Text("Invite a member"),
                            content: const Text(
                                'The more, the merrier! To invite someone, add their email adress. Only the account with that email will be able to join. They will then have to enter the code.'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('OK',
                                    style: TextStyle(color: Colors.blue)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Send_Invitation_txt'.tr,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              TextField(
                cursorColor: Theme.of(context).colorScheme.tertiary,
                focusNode: _emailFocusNode,
                onChanged: (value) {
                  isValidEmail = validateEmail(value);
                },
                controller: _controller,
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(
                  hintText: 'Mail_address_txt'.tr,
                  hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.tertiary),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10)),
                    ),
                    child: Text(
                      "Create invite code",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      if (isValidEmail == false) {
                        setState(() {
                          errorCode = 'Invalid email address';
                          print(inviteCode);
                        });
                        return;
                      }
                      String email = _controller.text;
                      errorCode = '';
                      String newInviteCode = await setInvite(email);
                      if (newInviteCode != '') {
                        inviteCode = newInviteCode;
                        inviteEmail = email;
                      }
                      setState(() {
                        print(inviteCode);
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 60),
              inviteCode != '' && inviteCode != null
                  ? Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(inviteCode ?? '',
                                    style: Theme.of(context).textTheme.bodyLarge),
                                IconButton(
                                  onPressed: () {
                                    final RenderBox box =
                                        context.findRenderObject() as RenderBox;
                                    Share.share(
                                        'Hey! I am inviting you to join my household. Use the following code to join: $inviteCode', //add the Household ID here
                                        subject: 'Invitation Code',
                                        sharePositionOrigin:
                                            box.localToGlobal(Offset.zero) &
                                                box.size);
                                  },
                                  icon: Icon(CupertinoIcons.share,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary))
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(inviteEmail ?? '',
                              style: Theme.of(context).textTheme.bodySmall),
                          SizedBox(height: 20),
                          
                        ],
                      )
                  : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Center(
                    child: Text(
                  errorCode ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShareButton extends StatefulWidget {
  const ShareButton({super.key});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  void initState() {
    super.initState();
  }

  void updateButton() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          alignment: Alignment.centerLeft,
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.all(0))),
      onPressed: () {
        final RenderBox box = context.findRenderObject() as RenderBox;
        Share.share(
          '$inviteCode\nHey! I am inviting you to join my household. Use the code to join.', //add the Household ID here
          subject: 'Invitation Code',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
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
    );
  }
}
