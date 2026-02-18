import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/listing.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/listings/listing_card.dart';
import '../../widgets/listings/listing_card_horizontal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final void Function(Listing listing) onListingTap;

  const HomeScreen({super.key, required this.onListingTap});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query     = '';
  bool   _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final user = ref.read(currentUserProvider);
    ref.read(listingsProvider.notifier).fetch(
          lat: user?.homeLocation.lat,
          lng: user?.homeLocation.lng,
          home: user?.homeLocation,
        );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user    = ref.watch(currentUserProvider);
    final state   = ref.watch(listingsProvider);
    final filtered = ref.watch(filteredListingsProvider);

    final display = _query.isEmpty
        ? filtered
        : filtered.where((l) {
            final q = _query.toLowerCase();
            return l.pickup.city.toLowerCase().contains(q) ||
                l.delivery.city.toLowerCase().contains(q) ||
                l.load.description.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header row ──────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${Helpers.greeting()},',
                                style: GoogleFonts.dmSans(
                                    fontSize: 14, color: AppColors.textMuted),
                              ),
                              Text(
                                user?.name.split(' ').first ?? 'Hauler',
                                style: GoogleFonts.syne(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ).animate().fade().slideX(begin: -0.1),
                        ),
                        _Avatar(user: user).animate().fade().scale(),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Home city pill ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.home_outlined,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Home: ${user?.homeLocation.city ?? 'Set home city'}',
                            style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 80.ms),
                    const SizedBox(height: 14),

                    // ── Search bar ──────────────────────────────────────────
                    _SearchBar(
                      controller: _searchCtrl,
                      searching: _searching,
                      onFocus: () => setState(() => _searching = true),
                      onChanged: (v) => setState(() => _query = v),
                      onClear: () => setState(() {
                        _searching = false;
                        _query = '';
                        _searchCtrl.clear();
                      }),
                    ).animate().fade(delay: 120.ms),
                    const SizedBox(height: 14),

                    // ── Vehicle filter chips ────────────────────────────────
                    if (!_searching) _FilterChips(),
                    if (!_searching) const SizedBox(height: 22),

                    // ── On Your Route section ───────────────────────────────
                    if (!_searching && state.onRoute.isNotEmpty) ...[
                      SectionHeader(
                        title: '🚀 On Your Route Home',
                        actionLabel: 'See all',
                        onAction: () {},
                      ).animate().fade(delay: 180.ms),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.onRoute.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (ctx, i) =>
                              ListingCardHorizontal(
                            listing: state.onRoute[i],
                            index: i,
                            onTap: () =>
                                widget.onListingTap(state.onRoute[i]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                    ],

                    // ── Nearby header ───────────────────────────────────────
                    SectionHeader(
                      title: _query.isNotEmpty
                          ? '${display.length} results'
                          : '📍 Nearby Listings',
                      actionLabel: _query.isEmpty ? 'Filter' : null,
                      onAction: () {},
                    ).animate().fade(delay: 220.ms),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
          body: state.isLoading
              ? const LoadingSpinner(message: 'Finding loads near you…')
              : display.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No listings found',
                      subtitle:
                          'Try adjusting your filters or check back later',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: display.length,
                      itemBuilder: (_, i) => ListingCard(
                        listing: display[i],
                        index: i,
                        onTap: () => widget.onListingTap(display[i]),
                      ),
                    ),
        ),
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool searching;
  final VoidCallback onFocus;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.searching,
    required this.onFocus,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFocus,
      child: AnimatedContainer(
        duration: 250.ms,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: searching ? AppColors.primary : AppColors.border,
            width: searching ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: searching
                  ? TextField(
                      controller: controller,
                      autofocus: true,
                      style: GoogleFonts.dmSans(
                          fontSize: 15, color: AppColors.textPrimary),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Search cities, load types…',
                        hintStyle: GoogleFonts.dmSans(
                            fontSize: 15, color: AppColors.textMuted),
                      ),
                      onChanged: onChanged,
                    )
                  : Text('Search by city or load…',
                      style: GoogleFonts.dmSans(
                          fontSize: 15, color: AppColors.textMuted)),
            ),
            if (searching)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close,
                    size: 16, color: AppColors.textMuted),
              )
            else ...[
              Container(width: 1, height: 18, color: AppColors.border,
                  margin: const EdgeInsets.symmetric(horizontal: 10)),
              const Icon(Icons.tune_rounded,
                  size: 18, color: AppColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Vehicle filter chips ────────────────────────────────────────────────────────
class _FilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(listingsProvider).filters.vehicleType;
    final chips = <(String, VehicleType?)>[
      ('All', null),
      ('Van', VehicleType.van),
      ('Pickup', VehicleType.pickup),
      ('Small Truck', VehicleType.smallTruck),
      ('Large Truck', VehicleType.largeTruck),
      ('Flatbed', VehicleType.flatbed),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (label, type) = chips[i];
          final selected = current == type;
          return GestureDetector(
            onTap: () => ref.read(listingsProvider.notifier).setFilters(
                  ListingsFilters(vehicleType: type),
                ),
            child: AnimatedContainer(
              duration: 180.ms,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Avatar ──────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final AppUser? user;
  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkTeal,
        border: Border.all(color: AppColors.border, width: 1.5),
        image: user?.avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(user!.avatarUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: user?.avatarUrl == null
          ? Center(
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : '?',
                style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            )
          : null,
    );
  }
}