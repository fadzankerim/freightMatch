import 'dart:math';

import '../models/listing.dart';
import '../utils/helpers.dart';

class RouteMatchResult {
  final Listing listing;
  final double score;

  const RouteMatchResult({
    required this.listing,
    required this.score,
  });
}

class RouteMatchingService {
  const RouteMatchingService._();

  static List<RouteMatchResult> matchListingsAlongRoute({
    required List<Listing> listings,
    required GeoPoint current,
    required GeoPoint home,
    double corridorRadiusKm = 35,
  }) {
    final totalRouteKm =
        Helpers.distanceKm(current.lat, current.lng, home.lat, home.lng);

    if (totalRouteKm < 5) {
      return const [];
    }

    final scored = <RouteMatchResult>[];
    for (final listing in listings) {
      final pickupToRouteKm = _distanceToSegmentKm(
        pointLat: listing.pickup.lat,
        pointLng: listing.pickup.lng,
        aLat: current.lat,
        aLng: current.lng,
        bLat: home.lat,
        bLng: home.lng,
      );

      if (pickupToRouteKm > corridorRadiusKm) {
        continue;
      }

      final deliveryToHomeKm = Helpers.distanceKm(
        listing.delivery.lat,
        listing.delivery.lng,
        home.lat,
        home.lng,
      );

      final routeProgressKm = Helpers.distanceKm(
        current.lat,
        current.lng,
        listing.pickup.lat,
        listing.pickup.lng,
      );

      final score = (1000 / (pickupToRouteKm + 1)) +
          (500 / (deliveryToHomeKm + 1)) +
          (200 / (routeProgressKm + 1)) +
          listing.price;

      scored.add(RouteMatchResult(listing: listing, score: score));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  static double _distanceToSegmentKm({
    required double pointLat,
    required double pointLng,
    required double aLat,
    required double aLng,
    required double bLat,
    required double bLng,
  }) {
    // Local planar approximation for corridor matching at city-country scale.
    const kmPerDegLat = 111.32;
    final avgLatRad = ((aLat + bLat) / 2) * pi / 180;
    final kmPerDegLng = 111.32 * cos(avgLatRad);

    final px = pointLng * kmPerDegLng;
    final py = pointLat * kmPerDegLat;
    final ax = aLng * kmPerDegLng;
    final ay = aLat * kmPerDegLat;
    final bx = bLng * kmPerDegLng;
    final by = bLat * kmPerDegLat;

    final abx = bx - ax;
    final aby = by - ay;
    final apx = px - ax;
    final apy = py - ay;
    final ab2 = abx * abx + aby * aby;
    if (ab2 == 0) {
      final dx = px - ax;
      final dy = py - ay;
      return sqrt(dx * dx + dy * dy);
    }

    final t = max(0.0, min(1.0, (apx * abx + apy * aby) / ab2));
    final cx = ax + t * abx;
    final cy = ay + t * aby;
    final dx = px - cx;
    final dy = py - cy;
    return sqrt(dx * dx + dy * dy);
  }
}
