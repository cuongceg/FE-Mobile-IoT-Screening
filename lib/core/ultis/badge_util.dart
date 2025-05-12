import 'package:app_badge_plus/app_badge_plus.dart';

class BadgeUtil {
  static int _badgeCount = 0;
  static int get badgeCount => _badgeCount;

  static Future<void> incrementBadge() async {
    try {
      _badgeCount ++;
      await AppBadgePlus.updateBadge(_badgeCount);
    } catch (e) {
      print('Error setting badge: $e');
    }
  }


  static Future<void> removeBadge() async {
    try {
      await AppBadgePlus.updateBadge(0);
    } catch (e) {
      print('Error removing badge: $e');
    }
  }
}