import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_spinner.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ref.read(bookingsProvider.notifier).fetchBookings());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TabBar(
              controller: _tabs,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w400),
              tabs: [
                _TabLabel('Active', state.active.length),
                _TabLabel('Upcoming', state.upcoming.length),
                _TabLabel('Done', 0),
              ],
            ),
          ),
        ),
      ),
      body: state.isLoading
          ? const LoadingSpinner()
          : TabBarView(
              controller: _tabs,
              children: [
                _BookingList(bookings: state.active),
                _BookingList(bookings: state.upcoming),
                _BookingList(bookings: state.completed),
              ],
            ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final int count;
  const _TabLabel(this.label, this.count);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 5),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text('$count',
                  style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  const _BookingList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Nothing here yet',
        subtitle: 'Bookings will appear once you accept a load',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (_, i) =>
          _BookingCard(booking: bookings[i], index: i),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final Booking booking;
  final int index;
  const _BookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: index * 60), duration: 380.ms),
        SlideEffect(
          delay: Duration(milliseconds: index * 60),
          duration: 380.ms,
          begin: const Offset(0, 0.07),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusBadge(booking.status),
                      const Spacer(),
                      Text(booking.priceDisplay,
                          style: GoogleFonts.syne(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _RouteRow(
                    from: booking.listing.pickup.city,
                    to: booking.listing.delivery.city,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _SmallAvatar(
                          url: booking.shipper.avatarUrl,
                          name: booking.shipper.name),
                      const SizedBox(width: 6),
                      Text(booking.shipper.name,
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                      const Spacer(),
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM')
                            .format(booking.scheduledPickup),
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Progress bar for active jobs ─────────────────────────────
            if (booking.isActive)
              _ProgressBar(status: booking.status),

            // ── Actions row ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  _ActionChip(Icons.chat_bubble_outline_rounded, 'Chat'),
                  const SizedBox(width: 8),
                  _ActionChip(Icons.info_outline_rounded, 'Details'),
                  const Spacer(),
                  if (booking.status == BookingStatus.inTransit)
                    CustomButton(
                      label: 'Mark Delivered',
                      isSmall: true,
                      onPressed: () => ref
                          .read(bookingsProvider.notifier)
                          .updateStatus(
                              booking.id, BookingStatus.delivered),
                    ),
                  if (booking.status == BookingStatus.pending)
                    CustomButton(
                      label: 'Cancel',
                      isSmall: true,
                      variant: ButtonVariant.outlined,
                      onPressed: () => ref
                          .read(bookingsProvider.notifier)
                          .updateStatus(
                              booking.id, BookingStatus.cancelled),
                    ),
                  if (booking.isCompleted && !booking.haulerReviewed)
                    CustomButton(
                      label: 'Leave Review',
                      isSmall: true,
                      onPressed: () {},
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge(this.status);

  Color get _color {
    switch (status) {
      case BookingStatus.pending:         return AppColors.warning;
      case BookingStatus.accepted:
      case BookingStatus.pickupScheduled: return AppColors.info;
      case BookingStatus.pickedUp:
      case BookingStatus.inTransit:       return AppColors.primary;
      case BookingStatus.delivered:
      case BookingStatus.completed:       return AppColors.success;
      default:                            return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(status.label,
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _color)),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final BookingStatus status;
  const _ProgressBar({required this.status});

  static const _order = [
    BookingStatus.accepted,
    BookingStatus.pickupScheduled,
    BookingStatus.pickedUp,
    BookingStatus.inTransit,
    BookingStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final idx = _order.indexOf(status);
    if (idx < 0) return const SizedBox.shrink();
    final progress = (idx + 1) / _order.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgElevated,
              color: AppColors.primary,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 5),
          Text(status.label,
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String from;
  final String to;
  const _RouteRow({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(from,
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Container(
                  width: 4, height: 4,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle)),
              Container(width: 24, height: 1, color: AppColors.primary),
              const Icon(Icons.arrow_forward,
                  size: 13, color: AppColors.primary),
            ],
          ),
        ),
        Expanded(
          child: Text(to,
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  final String? url;
  final String name;
  const _SmallAvatar({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkTeal,
        image: url != null
            ? DecorationImage(
                image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
      ),
      child: url == null
          ? Center(
              child: Text(name.isNotEmpty ? name[0] : '?',
                  style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)))
          : null,
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}