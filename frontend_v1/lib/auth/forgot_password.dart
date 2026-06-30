import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/auth/login.dart';
import 'package:frontend_v1/profile/profile_v2.dart';

class ForgotPasswordScaffold extends StatelessWidget {
  const ForgotPasswordScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          children: [
            const BackIconRow(),
            ForgotPasswordForm(), // Add this line to display the ForgotPasswordForm widget
          ],
        ),
      )),
    );
  }
}

class ForgotPasswordForm extends StatelessWidget {
  ForgotPasswordForm({super.key});

  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();
  final focusNodeSwitch = FocusNode();
  final focusNodeButton = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              TextFormField(
                autofillHints: const [AutofillHints.email],
                cursorColor: Theme.of(context).colorScheme.onSecondary,
                autocorrect: false,
                focusNode: focusNode1,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(focusNode2);
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 2,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 2,
                    ),
                  ),
                  hintText: 'Email adress',
                  contentPadding: const EdgeInsets.all(20),
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.tertiary),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 40),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          title: Text('Password resetted',
                              style: Theme.of(context).textTheme.bodyMedium),
                          content: Text(
                              'You will retcieve an email in which you can reset your password',
                              style: Theme.of(context).textTheme.bodySmall),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('Okay',
                                  style: Theme.of(context).textTheme.bodySmall),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginWidget()),
                                );
                              },
                            ),
                          ],
                        );
                      });
                },
                child: Text(
                  'Reset password',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ));
  }
}
