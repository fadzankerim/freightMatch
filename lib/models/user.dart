enum UserType { hauler, shipper, both }

enum VehicleType { van, pickup, smallTruck, largeTruck, flatbed }

extension VehicleTypeExt on VehicleType {
  String get label {
    switch (this) {
      case VehicleType.van:
        return "Van";
      case VehicleType.pickup:
        return "Pickup";
      case VehicleType.smallTruck:
        return "Small Truck";
      case VehicleType.largeTruck:
        return "Large Truck";
      case VehicleType.flatbed:
        return "Flatbed";
    }
  }
}

extension UserTypeExt on UserType {
  String get label {
    switch (this) {
      case UserType.hauler:
        return "Hauler";
      case UserType.shipper:
        return "Shipper";
      case UserType.both:
        return "Both";
    }
  }
}

class UserLocation {
  final String city;
  final String country;
  final double lat;
  final double lng;

  const UserLocation({
    required this.city,
    required this.country,
    required this.lat,
    required this.lng,
  });

  String get displayName => '$city, $country';

  factory UserLocation.fromJson(Map<String, dynamic> j) => UserLocation(
    city: j['city'],
    country: j['country'],
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'city': city,
    'country': country,
    'lat': lat,
    'lng': lng,
  };
}

class UserVerification {
  final bool email;
  final bool phone;
  final bool identity;
  final bool insurance;
  final bool driverLicense;

  const UserVerification({
    required this.email,
    required this.phone,
    required this.identity,
    required this.insurance,
    required this.driverLicense,
  });

  int get count {
    int c = 0;
    if (email) c++;
    if (phone) c++;
    if (identity) c++;
    if (insurance) c++;
    if (driverLicense) c++;
    return c;
  }

  factory UserVerification.fromJson(Map<String, dynamic> j) => UserVerification(
    email: j['email'] ?? false,
    phone: j['phone'] ?? false,
    identity: j['identity'] ?? false,
    insurance: j['insurance'] ?? false,
    driverLicense: j['driverLicense'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'phone': phone,
    'identity': identity,
    'insurance': insurance,
    'driverLicense': driverLicense,
  };
}


class Vehicle {
  final String id;
  final VehicleType type;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final double weightCapacity;
  final double volumeCapacity;
  final bool insuranceVerified;
  final String? photoUrl;

  const Vehicle({
    required this.id,
    required this.type,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.weightCapacity,
    required this.volumeCapacity,
    this.insuranceVerified = false,
    this.photoUrl,
  });

  String get displayName => '$year $make $model';

  factory Vehicle.fromJson(Map<String, dynamic> j) => Vehicle(
        id: j['id'],
        type: VehicleType.values.byName(j['type']),
        make: j['make'],
        model: j['model'],
        year: j['year'],
        licensePlate: j['licensePlate'],
        weightCapacity: (j['weightCapacity'] as num).toDouble(),
        volumeCapacity: (j['volumeCapacity'] as num).toDouble(),
        insuranceVerified: j['insuranceVerified'] ?? false,
        photoUrl: j['photoUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'make': make,
        'model': model,
        'year': year,
        'licensePlate': licensePlate,
        'weightCapacity': weightCapacity,
        'volumeCapacity': volumeCapacity,
        'insuranceVerified': insuranceVerified,
        'photoUrl': photoUrl,
      };
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final String? avatarUrl;
  final UserLocation homeLocation;
  final double rating;
  final int totalDeliveries;
  final double responseRate;
  final DateTime memberSince;
  final UserVerification verification;
  final List<Vehicle> vehicles;
  final String? bio;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.avatarUrl,
    required this.homeLocation,
    this.rating = 0,
    this.totalDeliveries = 0,
    this.responseRate = 0,
    required this.memberSince,
    required this.verification,
    this.vehicles = const [],
    this.bio,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        phone: j['phone'],
        userType: UserType.values.byName(j['userType']),
        avatarUrl: j['avatarUrl'],
        homeLocation: UserLocation.fromJson(j['homeLocation']),
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        totalDeliveries: j['totalDeliveries'] ?? 0,
        responseRate: (j['responseRate'] as num?)?.toDouble() ?? 0,
        memberSince: DateTime.parse(j['memberSince']),
        verification: UserVerification.fromJson(j['verification']),
        vehicles: (j['vehicles'] as List<dynamic>?)
                ?.map((v) => Vehicle.fromJson(v))
                .toList() ??
            [],
        bio: j['bio'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'userType': userType.name,
        'avatarUrl': avatarUrl,
        'homeLocation': homeLocation.toJson(),
        'rating': rating,
        'totalDeliveries': totalDeliveries,
        'responseRate': responseRate,
        'memberSince': memberSince.toIso8601String(),
        'verification': verification.toJson(),
        'vehicles': vehicles.map((v) => v.toJson()).toList(),
        'bio': bio,
      };
}

