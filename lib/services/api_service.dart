import 'package:dio/dio.dart';
import '../models/listing.dart';
import '../models/user.dart';
import '../models/booking.dart';
import '../utils/constants.dart';
import 'mock/mock_listings.dart';
import 'mock/mock_users.dart';

/// ApiService acts as the single data gateway.
/// While [useMock] is true every method returns mock data instantly.
/// Flip [useMock] to false and point [_dio] at your real backend to go live.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const bool useMock = true; // ← flip to false when backend is ready

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // AUTH

  Future<AppUser> login(String email, String password) async {
    if (useMock) {
      await _delay();
      return mockCurrentUser;
    }
    final res =
        await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return AppUser.fromJson(res.data['user']);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserType userType,
    required UserLocation homeLocation,
  }) async {
    if (useMock) {
      await _delay(ms: 1500);
      return AppUser(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        userType: userType,
        homeLocation: homeLocation,
        memberSince: DateTime.now(),
        verification: const UserVerification(email: true,driverLicense: true, identity: true, insurance: true, phone: true),
      );
    }
    final res = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'userType': userType.name,
      'homeLocation': homeLocation.toJson(),
    });
    return AppUser.fromJson(res.data['user']);
  }

  // LISTINGS

  Future<List<Listing>> fetchNearbyListings({
    required double lat,
    required double lng,
    double radiusKm = 500,
  }) async {
    if (useMock) {
      await _delay();
      return List.from(mockListings);
    }
    final res = await _dio.get('/listings/nearby',
        queryParameters: {'lat': lat, 'lng': lng, 'radius': radiusKm});
    return (res.data as List).map((j) => Listing.fromJson(j)).toList();
  }

  Future<List<Listing>> fetchListingsOnRoute({
    required double homeLat,
    required double homeLng,
  }) async {
    if (useMock) {
      await _delay(ms: 600);
      return listingsOnRoute(homeLat, homeLng);
    }
    final res = await _dio.get('/listings/on-route',
        queryParameters: {'homeLat': homeLat, 'homeLng': homeLng});
    return (res.data as List).map((j) => Listing.fromJson(j)).toList();
  }

  Future<Listing> fetchListingById(String id) async {
    if (useMock) {
      await _delay(ms: 300);
      return mockListings.firstWhere((l) => l.id == id);
    }
    final res = await _dio.get('/listings/$id');
    return Listing.fromJson(res.data);
  }

  Future<Listing> createListing(Map<String, dynamic> data) async {
    if (useMock) {
      await _delay(ms: 800);
      return Listing.fromJson(data);
    }
    final res = await _dio.post('/listings', data: data);
    return Listing.fromJson(res.data);
  }

  // BOOKINGS

  Future<List<Booking>> fetchMyBookings(String userId) async {
    if (useMock) {
      await _delay();
      return []; // populated by provider with mock data
    }
    final res = await _dio.get('/bookings', queryParameters: {'userId': userId});
    return (res.data as List).map((j) => Booking.fromJson(j)).toList();
  }

  Future<Booking> createBooking({
    required String listingId,
    required String haulerId,
    required double offeredPrice,
  }) async {
    if (useMock) {
      await _delay(ms: 800);
      throw UnimplementedError('Use mock provider directly');
    }
    final res = await _dio.post('/bookings', data: {
      'listingId': listingId,
      'haulerId': haulerId,
      'offeredPrice': offeredPrice,
    });
    return Booking.fromJson(res.data);
  }

  // HELPERS

  Future<void> _delay({int ms = 800}) =>
      Future.delayed(Duration(milliseconds: ms));
}