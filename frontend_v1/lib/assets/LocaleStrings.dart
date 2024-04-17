import 'package:get/get.dart';

class LocaleString extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en-US': {
          'welcome_title': 'Welcome',
          'welcome_message': 'Time to get productive.',
          'back_button_text': 'back',
          'Shop_title': 'Shop',
          'Shop_info': 'Spend your hard earned points for goodies'
        },
        'de-DE': {
          'welcome_title': 'Willkommen',
          'welcome_message': 'Es ist Zeit, produktiv zu sein.',
          'back_button_text': 'zurück',
          'Shop_title': 'Shop',
          'Shop_info': 'Geben Sie Ihre hart verdienten Punkte für Goodies aus'
        }
      };
}
