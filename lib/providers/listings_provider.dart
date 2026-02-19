import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/listing.dart';
import '../models/user.dart';
import '../services/api_service.dart';


class ListingsFilters{

  final VehicleType? vehicleType;
  final double? minPrice;
  final double? maxPrice;
  final double? maxDistanceKm;
  final bool priceNegotiableOnly;
  final String sortBy;

  const ListingsFilters({
    this.vehicleType,
    this.minPrice,
    this.maxPrice,
    this.maxDistanceKm,
    this.priceNegotiableOnly = false,
    this.sortBy = 'date' 
  });

  bool get hasActive => 
    vehicleType != null ||
    minPrice != null ||
    maxPrice != null ||
    maxDistanceKm != null ||
    priceNegotiableOnly ||
    sortBy != 'date';

  ListingsFilters copyWith({
    VehicleType? vehicleType,
    double? minPrice,
    double? maxPrice,
    double? maxDistanceKm,
    bool? priceNegotiableOnly,
    String? sortBy,
    bool clearVehicle = false,
  }) => ListingsFilters(
    vehicleType: clearVehicle ? null : vehicleType ?? this.vehicleType,
    minPrice: minPrice ?? this.minPrice,
    maxPrice: maxPrice ?? this.maxPrice,
    maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
    priceNegotiableOnly: priceNegotiableOnly ?? this.priceNegotiableOnly,
    sortBy: sortBy ?? this.sortBy,
  );

}

class ListingsState {
  final List<Listing> all;
  final List<Listing> onRoute;
  final bool isLoading;
  final String? error;
  final ListingsFilters filters;

  const ListingsState({
    this.all = const [],
    this.onRoute = const [],
    this.isLoading = false,
    this.error,
    this.filters = const ListingsFilters(),
  });

  ListingsState copyWith({
    List<Listing>? all,
    List<Listing>? onRoute,
    bool? isLoading,
    String? error,
    ListingsFilters? filters,
  }) =>
      ListingsState(
        all: all ?? this.all,
        onRoute: onRoute ?? this.onRoute,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        filters: filters ?? this.filters,
      );

  List<Listing> get filtered {
    var list = List<Listing>.from(all);
    final f = filters;
    if (f.vehicleType != null) {
      list = list.where((l) => l.requiredVehicleType == f.vehicleType).toList();
    }
    if (f.minPrice != null) list = list.where((l) => l.price >= f.minPrice!).toList();
    if (f.maxPrice != null) list = list.where((l) => l.price <= f.maxPrice!).toList();
    if (f.maxDistanceKm != null) {
      list = list.where((l) => l.distanceKm <= f.maxDistanceKm!).toList();
    }
    if (f.priceNegotiableOnly) {
      list = list.where((l) => l.priceNegotiable).toList();
    }
    switch (f.sortBy) {
      case 'price':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'distance':
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }
}

// NOTIFIER
class ListingsNotifier extends StateNotifier<ListingsState> {
  ListingsNotifier() : super(const ListingsState());

  final _api = ApiService.instance;

  Future<void> fetch({double? lat, double? lng, UserLocation? home}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final all = await _api.fetchNearbyListings(
        lat: lat ?? 44.0,
        lng: lng ?? 18.0,
      );
      final onRoute = home != null
          ? await _api.fetchListingsOnRoute(
              currentLat: lat ?? home.lat,
              currentLng: lng ?? home.lng,
              homeLat: home.lat, homeLng: home.lng)
          : <Listing>[];
      state = state.copyWith(all: all, onRoute: onRoute, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilters(ListingsFilters f) => state = state.copyWith(filters: f);
  void clearFilters() => state = state.copyWith(filters: const ListingsFilters());

  Future<void> addListing(Listing listing) async {
    state = state.copyWith(isLoading: true);
    try {
      final created = await _api.createListing(listing.toJson());
      state = state.copyWith(
        all: [created, ...state.all],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final listingsProvider =
    StateNotifierProvider<ListingsNotifier, ListingsState>(
        (ref) => ListingsNotifier());

final filteredListingsProvider = Provider<List<Listing>>(
    (ref) => ref.watch(listingsProvider).filtered);

final listingByIdProvider = Provider.family<Listing?, String>((ref, id) {
  try {
    return ref.watch(listingsProvider).all.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
});

// ── Saved listings ────────────────────────────────────────────────────────────
class SavedNotifier extends StateNotifier<Set<String>> {
  SavedNotifier() : super({});
  void toggle(String id) {
    state = state.contains(id)
        ? (Set.from(state)..remove(id))
        : (Set.from(state)..add(id));
  }
}

final savedProvider =
    StateNotifierProvider<SavedNotifier, Set<String>>((ref) => SavedNotifier());

final isSavedProvider = Provider.family<bool, String>(
    (ref, id) => ref.watch(savedProvider).contains(id));
