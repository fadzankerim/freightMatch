import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../config/theme.dart';
import '../../models/listing.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/design/app_atoms.dart';

class MapScreen extends ConsumerStatefulWidget {
  final void Function(Listing listing) onListingTap;

  const MapScreen({
    super.key,
    required this.onListingTap,
  });

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _controller;
  Listing? _selected;
  LatLng? _currentLatLng;
  bool _loadingLocation = false;

  static const _fallbackCamera = CameraPosition(
    target: LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
    zoom: AppConstants.defaultZoom,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _resolveCurrentLocation();
      final listingsState = ref.read(listingsProvider);
      if (listingsState.all.isEmpty && mounted) {
        final user = ref.read(currentUserProvider);
        await ref.read(listingsProvider.notifier).fetch(
              lat: _currentLatLng?.latitude ?? user?.homeLocation.lat,
              lng: _currentLatLng?.longitude ?? user?.homeLocation.lng,
              home: user?.homeLocation,
            );
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _resolveCurrentLocation() async {
    if (_loadingLocation) return;
    setState(() => _loadingLocation = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      final ll = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _currentLatLng = ll);
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(ll, 10));
    } catch (_) {
      // Keep fallback camera when location retrieval fails.
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  Set<Marker> _buildMarkers(List<Listing> listings) {
    return listings
        .map(
          (listing) => Marker(
            markerId: MarkerId(listing.id),
            position: LatLng(listing.pickup.lat, listing.pickup.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _markerHue(listing.requiredVehicleType),
            ),
            infoWindow: InfoWindow(
              title: '${listing.pickup.city} → ${listing.delivery.city}',
              snippet: listing.priceDisplay,
            ),
            onTap: () {
              setState(() => _selected = listing);
            },
          ),
        )
        .toSet();
  }

  double _markerHue(VehicleType type) {
    return switch (type) {
      VehicleType.van => BitmapDescriptor.hueViolet,
      VehicleType.pickup => BitmapDescriptor.hueGreen,
      VehicleType.smallTruck => BitmapDescriptor.hueAzure,
      VehicleType.largeTruck => BitmapDescriptor.hueBlue,
      VehicleType.flatbed => BitmapDescriptor.hueOrange,
    };
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(filteredListingsProvider);
    final markers = _buildMarkers(listings);
    final camera = _currentLatLng == null
        ? _fallbackCamera
        : CameraPosition(target: _currentLatLng!, zoom: 10);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: camera,
              markers: markers,
              myLocationEnabled: _currentLatLng != null,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) => _controller = controller,
              onTap: (_) => setState(() => _selected = null),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.smd,
                AppSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.smd,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${listings.length} listings on map',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location_rounded),
                      onPressed: _resolveCurrentLocation,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selected != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _MapListingSheet(
                listing: _selected!,
                onChat: () {},
                onAccept: () => widget.onListingTap(_selected!),
                onClose: () => setState(() => _selected = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapListingSheet extends StatelessWidget {
  final Listing listing;
  final VoidCallback onChat;
  final VoidCallback onAccept;
  final VoidCallback onClose;

  const _MapListingSheet({
    required this.listing,
    required this.onChat,
    required this.onAccept,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.smd,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          RouteCityRow(
            from: listing.pickup.city,
            to: listing.delivery.city,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            listing.priceDisplay,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              VehicleTypeChip(type: listing.requiredVehicleType),
              const SizedBox(width: AppSpacing.sm),
              MetaChip(icon: Icons.straighten_rounded, label: listing.distanceDisplay),
              const SizedBox(width: AppSpacing.sm),
              MetaChip(icon: Icons.timer_outlined, label: listing.durationDisplay),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Posted by: ${listing.user?.name ?? 'Unknown user'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ActionHierarchy(
            primaryLabel: 'Accept / Arrange',
            onPrimary: onAccept,
            secondaryLabel: 'Chat',
            onSecondary: onChat,
            tertiaryLabel: 'Close',
            onTertiary: onClose,
          ),
        ],
      ),
    );
  }
}
