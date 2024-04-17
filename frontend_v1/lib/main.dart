import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'assets/LocaleStrings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations:
          LocaleString(), // Hier wird LocalString() als Wert für translations gesetzt
      locale: Locale('de-DE'),
      fallbackLocale: Locale('en-US'), // Fallback locale is set to English
      debugShowCheckedModeBanner: false,
      title: 'Flutter Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainWidget(),
    );
  }
}

class MainWidget extends StatelessWidget {
  const MainWidget({Key? key});

  @override
  Widget build(BuildContext context) {
    // Ändere den Namen der locale-Variable in mainLocale
    final List<Map<String, dynamic>> mainLocale = [
      {'name': 'English', 'locale': Locale('en-US')},
      {'name': 'German', 'locale': Locale('de-DE')}
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeText(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Funktion zum Auslösen des Dialogs aufrufen
                buildDialog(context, mainLocale);
              },
              child: Text('Open Language Dialog'),
            ),
            SizedBox(height: 20),
            Buttons(),
            SizedBox(height: 20),
            ButtonRow(),
          ],
        ),
      ),
    );
  }

  // Funktion zum Erstellen und Anzeigen des Sprachauswahl-Dialogs
  void buildDialog(BuildContext context, List<Map<String, dynamic>> locale) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose a language'),
          content: Container(
            width: double.maxFinite,
            child: ListView.separated(
              itemBuilder: (context, index) {
                final languageName = locale[index]['name'] ?? '';
                return ListTile(
                  title: Text(languageName),
                  onTap: () {
                    // Setze die Sprache und schließe den Dialog
                    Get.updateLocale(Locale(
                        locale[index]['locale']['languageCode'],
                        locale[index]['locale']['countryCode']));
                    Navigator.of(context).pop();
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.blue,
                );
              },
              itemCount: locale.length,
            ),
          ),
        );
      },
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({Key? key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'welcome_title'.tr, // Using translations
          style: TextStyle(fontSize: 20),
        ),
        Text(
          'welcome_message'.tr, // Using translations
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class Buttons extends StatelessWidget {
  const Buttons({Key? key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Color.fromARGB(255, 243, 243, 243),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(62, 74, 70, 70),
              offset: Offset(5.0, 5.0),
              blurRadius: 10.0,
              spreadRadius: 2.0,
            )
          ],
        ),
      ),
    );
  }
}

class ButtonRow extends StatelessWidget {
  const ButtonRow({Key? key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Buttons()),
        Expanded(child: Buttons()),
      ],
    );
  }
}
