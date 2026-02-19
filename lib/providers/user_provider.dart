import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/booking.dart';
import '../models/listing.dart';
import '../models/user.dart';
import '../services/mock/mock_users.dart';
import 'auth_provider.dart';

const Object _nothing = Object();

class BookingsState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;

  BookingsState({this.bookings = const [], 
                this.isLoading = false, 
                this.error});

  BookingsState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    Object? error = _nothing,
  }) {
    return BookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error == _nothing ? this.error : (error as String?),
    );
  }

  List<Booking> get active => bookings.where((b) => b.isActive).toList();

  List<Booking> get upcoming =>
      bookings.where((b) => b.status == BookingStatus.pending).toList();

  List<Booking> get completed =>
      bookings.where((b) => b.status == BookingStatus.completed).toList();
}

class BookingsNotifier extends StateNotifier<BookingsState> {
  final Ref _ref;

  BookingsNotifier(this._ref) : super(BookingsState());

  Future<void> fetchBookings() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));

    // Build mock bookings using current user
    final me = _ref.read(currentUserProvider) ?? mockCurrentUser;
    final shipper = mockUsers[1]; // Marko
    final listing  = _buildDummyListing();

    final mockBookings = [
      Booking(
        id: 'booking-1',
        listingId: 'listing-3',
        listing: listing,
        shipperId: shipper.id,
        shipper: shipper,
        haulerId: me.id,
        hauler: me,
        status: BookingStatus.inTransit,
        agreedPrice: 850,
        scheduledPickup: DateTime.now().subtract(const Duration(hours: 2)),
        scheduledDelivery: DateTime.now().add(const Duration(hours: 6)),
        actualPickup: DateTime.now().subtract(const Duration(hours: 2)),
        timeline: [
          BookingTimelineEvent(
              status: BookingStatus.pending,
              timestamp:
                  DateTime.now().subtract(const Duration(days: 1))),
          BookingTimelineEvent(
              status: BookingStatus.accepted,
              timestamp:
                  DateTime.now().subtract(const Duration(hours: 20))),
          BookingTimelineEvent(
              status: BookingStatus.pickedUp,
              timestamp:
                  DateTime.now().subtract(const Duration(hours: 2)),
              note: 'Load picked up at Vienna warehouse'),
          BookingTimelineEvent(
              status: BookingStatus.inTransit,
              timestamp:
                  DateTime.now().subtract(const Duration(hours: 2))),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Booking(
        id: 'booking-2',
        listingId: 'listing-6',
        listing: listing.copyWithId('listing-6'),
        shipperId: shipper.id,
        shipper: shipper,
        haulerId: me.id,
        hauler: me,
        status: BookingStatus.pending,
        agreedPrice: 145,
        scheduledPickup: DateTime.now().add(const Duration(days: 2, hours: 11)),
        scheduledDelivery: DateTime.now().add(const Duration(days: 2, hours: 14)),
        timeline: [
          BookingTimelineEvent(
              status: BookingStatus.pending,
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              note: 'Awaiting confirmation'),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Booking(
        id: 'booking-3',
        listingId: 'listing-1',
        listing: listing.copyWithId('listing-1'),
        shipperId: shipper.id,
        shipper: shipper,
        haulerId: me.id,
        hauler: me,
        status: BookingStatus.completed,
        agreedPrice: 260,
        scheduledPickup: DateTime.now().subtract(const Duration(days: 5)),
        scheduledDelivery:
            DateTime.now().subtract(const Duration(days: 4, hours: 20)),
        actualPickup: DateTime.now().subtract(const Duration(days: 5)),
        actualDelivery:
            DateTime.now().subtract(const Duration(days: 4, hours: 19)),
        timeline: [
          BookingTimelineEvent(
              status: BookingStatus.completed,
              timestamp:
                  DateTime.now().subtract(const Duration(days: 4, hours: 19)),
              note: 'Delivery confirmed by shipper'),
        ],
        proofOfDelivery: ProofOfDelivery(
          photoUrls: [
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400'
          ],
          notes: 'All items delivered in perfect condition.',
          timestamp:
              DateTime.now().subtract(const Duration(days: 4, hours: 19)),
        ),
        shipperReviewed: true,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt:
            DateTime.now().subtract(const Duration(days: 4, hours: 19)),
      ),
    ];

    state = state.copyWith(bookings: mockBookings, isLoading: false);
  }

  Future<void> createBooking(Listing listing, double price) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));

    final me = _ref.read(currentUserProvider) ?? mockCurrentUser;

    final b = Booking(
      id: 'booking-new-${DateTime.now().millisecondsSinceEpoch}',
      listingId: listing.id,
      listing: listing,
      shipperId: listing.userId,
      shipper: listing.user ?? mockUsers[1],
      haulerId: me.id,
      hauler: me,
      status: BookingStatus.pending,
      agreedPrice: price,
      scheduledPickup: listing.pickupDate,
      scheduledDelivery: listing.deliveryDate,
      timeline: [
        BookingTimelineEvent(
            status: BookingStatus.pending,
            timestamp: DateTime.now(),
            note: 'Booking request sent'),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      bookings: [b, ...state.bookings],
      isLoading: false,
    );
  }

  Future<void> updateStatus(String bookingId, BookingStatus newStatus) async {
    final updated = state.bookings
        .map((b) => b.id == bookingId ? b.copyWithStatus(newStatus) : b)
        .toList();
    state = state.copyWith(bookings: updated);
  }

  // Helper — builds a minimal listing for mock bookings
  static Listing _buildDummyListing() {
    return Listing(
      id: 'listing-3',
      userId: 'user-4',
      user: mockUsers[3],
      status: ListingStatus.active,
      pickup: const GeoPoint(
        address: 'Mariahilfer Straße 10',
        city: 'Vienna',
        country: 'Austria',
        lat: 48.1975,
        lng: 16.3531,
      ),
      delivery: const GeoPoint(
        address: 'Kneza Mihaila 32',
        city: 'Belgrade',
        country: 'Serbia',
        lat: 44.8183,
        lng: 20.4579,
      ),
      pickupDate: DateTime.now().add(const Duration(days: 1, hours: 10)),
      deliveryDate: DateTime.now().add(const Duration(days: 2, hours: 8)),
      load: const LoadDetails(
        description: 'Restaurant kitchen equipment — oven, fridges.',
        weightKg: 950,
      ),
      requiredVehicleType: VehicleType.largeTruck,
      price: 890,
      distanceKm: 620,
      estimatedMinutes: 480,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(days: 5)),
    );
  }
}

extension _ListingExt on Listing {
  Listing copyWithId(String newId) => Listing(
        id: newId,
        userId: userId,
        user: user,
        status: status,
        pickup: pickup,
        delivery: delivery,
        pickupDate: pickupDate,
        deliveryDate: deliveryDate,
        load: load,
        requiredVehicleType: requiredVehicleType,
        price: price,
        priceNegotiable: priceNegotiable,
        distanceKm: distanceKm,
        estimatedMinutes: estimatedMinutes,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );
}

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, BookingsState>(
        (ref) => BookingsNotifier(ref));

// ── Earnings (derived) ────────────────────────────────────────────────────────
class EarningsSummary {
  final double total;
  final double thisWeek;
  final double thisMonth;
  final int completedJobs;

  const EarningsSummary({
    required this.total,
    required this.thisWeek,
    required this.thisMonth,
    required this.completedJobs,
  });
}

final earningsSummaryProvider = Provider<EarningsSummary>((ref) {
  final completed = ref.watch(bookingsProvider).completed;
  final total = completed.fold<double>(0, (s, b) => s + b.agreedPrice);
  return EarningsSummary(
    total: total + 12840,
    thisWeek: 850,
    thisMonth: 2340,
    completedJobs: completed.length + 127,
  );
});
