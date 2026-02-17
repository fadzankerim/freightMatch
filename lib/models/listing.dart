import 'user.dart';

enum ListingStatus{ active, accepted, inProgress, completed, cancelled, expired }

class GeoPoint {
  final String address;
  final String city;
  final String country;
  final double lat;
  final double lng;

  const GeoPoint({
    required this.address,
    required this.city,
    required this.country,
    required this.lat,
    required this.lng,
  });

  String get fullAddress => '$address, $city, $country';
  String get shortAddress => '$city, $country';

  factory GeoPoint.fromJson(Map<String, dynamic> j) => GeoPoint(
        address: j['address'],
        city: j['city'],
        country: j['country'],
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'city': city,
        'country': country,
        'lat': lat,
        'lng': lng,
      };
}

class LoadDetails {
  final String description;
  final double weightKg;
  final double lengthM;
  final double widthM;
  final double heightM;
  final int quantity;
  final List<String> photoUrls;
  final List<String> specialRequirements;
  final bool isFragile;
  final bool needsRefrigeration;
  final bool hazardous;

  const LoadDetails({
    required this.description,
    required this.weightKg,
    this.lengthM = 0,
    this.widthM = 0,
    this.heightM = 0,
    this.quantity = 1,
    this.photoUrls = const [],
    this.specialRequirements = const [],
    this.isFragile = false,
    this.needsRefrigeration = false,
    this.hazardous = false,
  });

  String get weightDisplay {
    if (weightKg >= 1000) return '${(weightKg / 1000).toStringAsFixed(1)}t';
    return '${weightKg.toStringAsFixed(0)}kg';
  }

  factory LoadDetails.fromJson(Map<String, dynamic> j) => LoadDetails(
        description: j['description'],
        weightKg: (j['weightKg'] as num).toDouble(),
        lengthM: (j['lengthM'] as num?)?.toDouble() ?? 0,
        widthM: (j['widthM'] as num?)?.toDouble() ?? 0,
        heightM: (j['heightM'] as num?)?.toDouble() ?? 0,
        quantity: j['quantity'] ?? 1,
        photoUrls: List<String>.from(j['photoUrls'] ?? []),
        specialRequirements: List<String>.from(j['specialRequirements'] ?? []),
        isFragile: j['isFragile'] ?? false,
        needsRefrigeration: j['needsRefrigeration'] ?? false,
        hazardous: j['hazardous'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'weightKg': weightKg,
        'lengthM': lengthM,
        'widthM': widthM,
        'heightM': heightM,
        'quantity': quantity,
        'photoUrls': photoUrls,
        'specialRequirements': specialRequirements,
        'isFragile': isFragile,
        'needsRefrigeration': needsRefrigeration,
        'hazardous': hazardous,
      };
}

class Listing {
  final String id;
  final String userId;
  final AppUser? user;
  final ListingStatus status;
  final GeoPoint pickup;
  final GeoPoint delivery;
  final DateTime pickupDate;
  final DateTime deliveryDate;
  final LoadDetails load;
  final VehicleType requiredVehicleType;
  final double price;
  final bool priceNegotiable;
  final double distanceKm;
  final int estimatedMinutes;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int views;
  final int saves;
  final String? contactName;
  final String? contactPhone;

  const Listing({
    required this.id,
    required this.userId,
    this.user,
    required this.status,
    required this.pickup,
    required this.delivery,
    required this.pickupDate,
    required this.deliveryDate,
    required this.load,
    required this.requiredVehicleType,
    required this.price,
    this.priceNegotiable = false,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.createdAt,
    required this.expiresAt,
    this.views = 0,
    this.saves = 0,
    this.contactName,
    this.contactPhone,
  });

  String get priceDisplay => '€${price.toStringAsFixed(0)}';

  String get distanceDisplay {
    if (distanceKm >= 1000) return '${(distanceKm / 1000).toStringAsFixed(1)}k km';
    return '${distanceKm.toStringAsFixed(0)} km';
  }

  String get durationDisplay {
    if (estimatedMinutes >= 60) {
      final h = estimatedMinutes ~/ 60;
      final m = estimatedMinutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${estimatedMinutes}m';
  }

  factory Listing.fromJson(Map<String, dynamic> j) => Listing(
        id: j['id'],
        userId: j['userId'],
        user: j['user'] != null ? AppUser.fromJson(j['user']) : null,
        status: ListingStatus.values.byName(j['status']),
        pickup: GeoPoint.fromJson(j['pickup']),
        delivery: GeoPoint.fromJson(j['delivery']),
        pickupDate: DateTime.parse(j['pickupDate']),
        deliveryDate: DateTime.parse(j['deliveryDate']),
        load: LoadDetails.fromJson(j['load']),
        requiredVehicleType: VehicleType.values.byName(j['requiredVehicleType']),
        price: (j['price'] as num).toDouble(),
        priceNegotiable: j['priceNegotiable'] ?? false,
        distanceKm: (j['distanceKm'] as num).toDouble(),
        estimatedMinutes: j['estimatedMinutes'],
        createdAt: DateTime.parse(j['createdAt']),
        expiresAt: DateTime.parse(j['expiresAt']),
        views: j['views'] ?? 0,
        saves: j['saves'] ?? 0,
        contactName: j['contactName'],
        contactPhone: j['contactPhone'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'status': status.name,
        'pickup': pickup.toJson(),
        'delivery': delivery.toJson(),
        'pickupDate': pickupDate.toIso8601String(),
        'deliveryDate': deliveryDate.toIso8601String(),
        'load': load.toJson(),
        'requiredVehicleType': requiredVehicleType.name,
        'price': price,
        'priceNegotiable': priceNegotiable,
        'distanceKm': distanceKm,
        'estimatedMinutes': estimatedMinutes,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'views': views,
        'saves': saves,
        'contactName': contactName,
        'contactPhone': contactPhone,
      };
}