import 'dart:math';
import 'package:intl/intl.dart';

class Helpers {
  Helpers._();

  /// Haversine formula — returns km between two lat/lng pairs.
  static double distanceKm(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * pi / 180;

  /// Greeting based on time of day.
  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Format DateTime → "Tue, 20 Feb · 09:00"
  static String formatPickup(DateTime dt) =>
      DateFormat('EEE, dd MMM · HH:mm').format(dt);

  /// Format DateTime → "20 Feb"
  static String formatShort(DateTime dt) =>
      DateFormat('dd MMM').format(dt);

  /// Format DateTime → relative ("2 hours ago", "3 days ago")
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return formatShort(dt);
  }

  /// Capitalise first letter.
  static String capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}