import 'package:flutter/foundation.dart';

import 'user.dart';
import 'listing.dart';

enum BookingStatus {
  pending,
  accepted,
  pickupScheduled,
  pickedUp,
  inTransit,
  delivered,
  completed,
  cancelled,
  disputed,
}

extension BookingStatusExt on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.pickupScheduled:
        return 'Pickup Scheduled';
      case BookingStatus.pickedUp:
        return 'Picked Up';
      case BookingStatus.inTransit:
        return 'In Transit';
      case BookingStatus.delivered:
        return 'Delivered';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.disputed:
        return 'Disputed';
    }
  }

  bool get isActive => [
    BookingStatus.accepted,
    BookingStatus.pickupScheduled,
    BookingStatus.pickedUp,
    BookingStatus.inTransit,
  ].contains(this);

  bool get isCompleted =>
      this == BookingStatus.completed || this == BookingStatus.delivered;
}

class BookingTimelineEvent {
  final BookingStatus status;
  final DateTime timestamp;
  final String? note;

  const BookingTimelineEvent({
    required this.status,
    required this.timestamp,
    this.note,
  });

  factory BookingTimelineEvent.fromJson(Map<String, dynamic> j) =>
      BookingTimelineEvent(
        status: BookingStatus.values.byName(j['status']),
        timestamp: DateTime.parse(j['timestamp']),
        note: j['note'],
      );

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
  };
}

class ProofOfDelivery {
  final List<String> photoUrls;
  final String? notes;
  final DateTime timestamp;

  const ProofOfDelivery({
    this.photoUrls = const [],
    this.notes,
    required this.timestamp,
  });

  factory ProofOfDelivery.fromJson(Map<String, dynamic> j) => ProofOfDelivery(
    photoUrls: List<String>.from(j['photoUrls'] ?? []),
    notes: j['notes'],
    timestamp: DateTime.parse(j['timestamp']),
  );

  Map<String, dynamic> toJson() => {
    'photoUrls': photoUrls,
    'notes': notes,
    'timestamp': timestamp.toIso8601String(),
  };
}

class Booking {
  final String id;
  final String listingId;
  final Listing listing;
  final String shipperId;
  final AppUser shipper;
  final String haulerId;
  final AppUser hauler;
  final BookingStatus status;
  final double agreedPrice;
  final DateTime scheduledPickup;
  final DateTime scheduledDelivery;
  final DateTime? actualPickup;
  final DateTime? actualDelivery;
  final List<BookingTimelineEvent> timeline;
  final ProofOfDelivery? proofOfDelivery;
  final bool shipperReviewed;
  final bool haulerReviewed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.listingId,
    required this.listing,
    required this.shipperId,
    required this.shipper,
    required this.haulerId,
    required this.hauler,
    required this.status,
    required this.agreedPrice,
    required this.scheduledPickup,
    required this.scheduledDelivery,
    this.actualPickup,
    this.actualDelivery,
    this.timeline = const [],
    this.proofOfDelivery,
    this.shipperReviewed = false,
    this.haulerReviewed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get priceDisplay => '€${agreedPrice.toStringAsFixed(0)}';
  bool get isActive => status.isActive;
  bool get isCompleted => status.isCompleted;

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
    id: j['id'],
    listingId: j['listingId'],
    listing: Listing.fromJson(j['listing']),
    shipperId: j['shipperId'],
    shipper: AppUser.fromJson(j['shipper']),
    haulerId: j['haulerId'],
    hauler: AppUser.fromJson(j['hauler']),
    status: BookingStatus.values.byName(j['status']),
    agreedPrice: j['agreedPrice'],
    scheduledPickup: DateTime.parse(j['scheduledPickup']),
    scheduledDelivery: DateTime.parse(j['scheduledDelivery']),
    actualPickup: j['actualPickup'] == null
        ? null
        : DateTime.parse(j['actualPickup']),
    actualDelivery: j['actualDelivery'] == null
        ? null
        : DateTime.parse(j['actualDelivery']),
    timeline: List<BookingTimelineEvent>.from(
      j['timeline']?.map((e) => BookingTimelineEvent.fromJson(e)),
    ),
    proofOfDelivery: j['proofOfDelivery'] == null
        ? null
        : ProofOfDelivery.fromJson(j['proofOfDelivery']),
    shipperReviewed: j['shipperReviewed'],
    haulerReviewed: j['haulerReviewed'],
    createdAt: DateTime.parse(j['createdAt']),
    updatedAt: DateTime.parse(j['updatedAt']),
  );

  Booking copyWithStatus(BookingStatus newStatus) => Booking(
    id: id,
    listingId: listingId,
    listing: listing,
    shipperId: shipperId,
    shipper: shipper,
    haulerId: haulerId,
    hauler: hauler,
    status: newStatus,
    agreedPrice: agreedPrice,
    scheduledPickup: scheduledPickup,
    scheduledDelivery: scheduledDelivery,
    actualPickup: actualPickup,
    actualDelivery: actualDelivery,
    timeline: [
      ...timeline,
      BookingTimelineEvent(status: newStatus, timestamp: DateTime.now()),
    ],
    proofOfDelivery: proofOfDelivery,
    shipperReviewed: shipperReviewed,
    haulerReviewed: haulerReviewed,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'listingId': listingId,
    'listing': listing.toJson(),
    'shipperId': shipperId,
    'shipper': shipper.toJson(),
    'haulerId': haulerId,
    'hauler': hauler.toJson(),
    'status': status.name,
    'agreedPrice': agreedPrice,
    'scheduledPickup': scheduledPickup.toIso8601String(),
    'scheduledDelivery': scheduledDelivery.toIso8601String(),
    'actualPickup': actualPickup?.toIso8601String(),
    'actualDelivery': actualDelivery?.toIso8601String(),
    'timeline': timeline.map((e) => e.toJson()).toList(),
    'proofOfDelivery': proofOfDelivery?.toJson(),
    'shipperReviewed': shipperReviewed,
    'haulerReviewed': haulerReviewed,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
