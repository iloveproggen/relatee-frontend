import 'package:get/get.dart';

class LocaleString extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en-US': {
          'welcome_title': 'Welcome',
          'welcome_message': 'Time to get productive.',
          'back_button_text': 'back',
          'Shop_title': 'Shop',
          'Shop_info': 'Spend your hard earned points for goodies!',
          'part_household': 'part of household ',
          'view_txt': 'view',
          'overdue_txt': 'overdue',
          'due_in_txt': 'due in',
          'day_txt': 'day',
          'days_txt': 'days',
        },
        'de-DE': {
          'welcome_title': 'Willkommen',
          'welcome_message': 'Es ist Zeit, produktiv zu sein.',
          'back_button_text': 'zurück',
          'Shop_title': 'Shop',
          'Shop_info': 'Gib deine hart verdienten Punkte für Goodies aus!',
          'part_household': 'Teil des Haushalts ',
          'view_txt': 'siehe',
          'overdue_txt': 'überfällig',
          'due_in_txt': 'fällig in',
          'day_txt': 'Tag',
          'days_txt': 'Tagen',
        }
      };
}
