import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/listing.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../widgets/common/custom_input.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/design/app_atoms.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const CreateListingScreen({super.key, required this.onSuccess});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  // Step 0 — Route
  final _pickupStreetCtrl   = TextEditingController();
  final _pickupCityCtrl     = TextEditingController();
  final _pickupCountryCtrl  = TextEditingController();
  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1, hours: 9));

  final _deliveryStreetCtrl  = TextEditingController();
  final _deliveryCityCtrl    = TextEditingController();
  final _deliveryCountryCtrl = TextEditingController();
  DateTime _deliveryDate =
      DateTime.now().add(const Duration(days: 1, hours: 16));

  // Step 1 — Load
  final _descCtrl   = TextEditingController();
  final _weightCtrl = TextEditingController();
  VehicleType _vehicle = VehicleType.smallTruck;
  bool _fragile        = false;
  bool _refrigerated   = false;

  // Step 2 — Price
  final _priceCtrl = TextEditingController();
  bool _negotiable = false;

  static const _steps = ['Route', 'Load', 'Price', 'Review'];

  @override
  void dispose() {
    for (final c in [
      _pickupStreetCtrl, _pickupCityCtrl, _pickupCountryCtrl,
      _deliveryStreetCtrl, _deliveryCityCtrl, _deliveryCountryCtrl,
      _descCtrl, _weightCtrl, _priceCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final listing = Listing(
      id: const Uuid().v4(),
      userId: user.id,
      user: user,
      status: ListingStatus.active,
      pickup: GeoPoint(
        address: _pickupStreetCtrl.text,
        city: _pickupCityCtrl.text,
        country: _pickupCountryCtrl.text,
        lat: 44.0,
        lng: 18.0,
      ),
      delivery: GeoPoint(
        address: _deliveryStreetCtrl.text,
        city: _deliveryCityCtrl.text,
        country: _deliveryCountryCtrl.text,
        lat: 43.5,
        lng: 17.5,
      ),
      pickupDate: _pickupDate,
      deliveryDate: _deliveryDate,
      load: LoadDetails(
        description: _descCtrl.text,
        weightKg: double.tryParse(_weightCtrl.text) ?? 100,
        isFragile: _fragile,
        needsRefrigeration: _refrigerated,
      ),
      requiredVehicleType: _vehicle,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      priceNegotiable: _negotiable,
      distanceKm: 200,
      estimatedMinutes: 240,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 14)),
    );

    await ref.read(listingsProvider.notifier).addListing(listing);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Listing posted!')),
      );
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(listingsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Load'),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step--),
              )
            : null,
      ),
      body: Column(
        children: [
          // ── Step progress ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _StepIndicator(step: _step, steps: _steps),
          ),

          // ── Form body ────────────────────────────────────────────────────
          Expanded(
            child: Form(
              key: _formKey,
              child: AnimatedSwitcher(
                duration: 280.ms,
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  padding: const EdgeInsets.all(20),
                  child: _buildStep(),
                ),
              ),
            ),
          ),

          // ── Continue button ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.smd,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: ActionHierarchy(
              primaryLabel: _step == _steps.length - 1
                  ? 'Post Listing'
                  : 'Continue',
              onPrimary: _next,
              loading: loading,
              secondaryLabel: _step > 0 ? 'Back' : null,
              onSecondary:
                  _step > 0 ? () => setState(() => _step = _step - 1) : null,
              tertiaryLabel: 'Save Draft',
              onTertiary: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Draft saving is coming next.')),
                );
              },
              fullPrimary: _step == 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildRouteStep();
      case 1: return _buildLoadStep();
      case 2: return _buildPriceStep();
      case 3: return _buildReviewStep();
      default: return const SizedBox.shrink();
    }
  }

  // ── Step 0 ───────────────────────────────────────────────────────────────
  Widget _buildRouteStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pickup Location',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Where should the hauler collect the load?',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        CustomInput(
          controller: _pickupStreetCtrl,
          label: 'STREET ADDRESS',
          hint: 'e.g. Trg Republike 3',
          prefixIcon: Icons.location_on_outlined,
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: CustomInput(
              controller: _pickupCityCtrl,
              label: 'CITY',
              hint: 'Belgrade',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomInput(
              controller: _pickupCountryCtrl,
              label: 'COUNTRY',
              hint: 'Serbia',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _DateField(
          label: 'PICKUP DATE',
          date: _pickupDate,
          onChanged: (d) => setState(() => _pickupDate = d),
        ),
        const SizedBox(height: 28),
        Text('Delivery Location',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Where does it need to go?',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        CustomInput(
          controller: _deliveryStreetCtrl,
          label: 'STREET ADDRESS',
          hint: 'e.g. Maršala Tita 15',
          prefixIcon: Icons.flag_outlined,
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: CustomInput(
              controller: _deliveryCityCtrl,
              label: 'CITY',
              hint: 'Sarajevo',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomInput(
              controller: _deliveryCountryCtrl,
              label: 'COUNTRY',
              hint: 'Bosnia',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _DateField(
          label: 'DELIVERY DATE',
          date: _deliveryDate,
          onChanged: (d) => setState(() => _deliveryDate = d),
        ),
        const SizedBox(height: 16),
        CustomCard(
          child: Row(
            children: [
              const Icon(Icons.map_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_pickupCityCtrl.text.isEmpty ? 'Pickup' : _pickupCityCtrl.text} → '
                  '${_deliveryCityCtrl.text.isEmpty ? 'Delivery' : _deliveryCityCtrl.text}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 1 ───────────────────────────────────────────────────────────────
  Widget _buildLoadStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Load Details',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Tell haulers what needs transporting',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        CustomInput(
          controller: _descCtrl,
          label: 'DESCRIPTION',
          hint: 'Describe the goods, quantity, packaging…',
          maxLines: 4,
          validator: (v) =>
              v == null || v.length < 10 ? 'Please describe the load' : null,
        ),
        const SizedBox(height: 14),
        CustomInput(
          controller: _weightCtrl,
          label: 'WEIGHT (kg)',
          hint: '500',
          prefixIcon: Icons.scale_outlined,
          keyboardType: TextInputType.number,
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 20),
        Text('Vehicle Required',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: VehicleType.values.map((t) {
            final sel = _vehicle == t;
            return GestureDetector(
              onTap: () => setState(() => _vehicle = t),
              child: AnimatedContainer(
                duration: 180.ms,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primarySurface : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: sel ? AppColors.primary : AppColors.border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  t.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: sel ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text('Special Requirements',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _SwitchRow(
          label: 'Fragile / Handle with care',
          icon: Icons.warning_amber_rounded,
          value: _fragile,
          onChanged: (v) => setState(() => _fragile = v),
        ),
        _SwitchRow(
          label: 'Needs refrigeration',
          icon: Icons.ac_unit_rounded,
          value: _refrigerated,
          onChanged: (v) => setState(() => _refrigerated = v),
        ),
      ],
    );
  }

  // ── Step 2 ───────────────────────────────────────────────────────────────
  Widget _buildPriceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set Your Price',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Set a fair rate or let haulers make offers',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 200,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('€',
                    style: GoogleFonts.syne(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted)),
                const SizedBox(width: 4),
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.syne(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary),
                    decoration: InputDecoration.collapsed(
                      hintText: '0',
                      hintStyle: GoogleFonts.syne(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter a price' : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('euros',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(height: 24),
        _SwitchRow(
          label: 'Price is negotiable',
          icon: Icons.handshake_outlined,
          value: _negotiable,
          onChanged: (v) => setState(() => _negotiable = v),
          subtitle: 'Allow haulers to send counter-offers',
        ),
        const SizedBox(height: 24),
        CustomCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'For routes 200–400 km, typical rates range from €150–€500 depending on weight and vehicle type.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 3 ───────────────────────────────────────────────────────────────
  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Post',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Double-check before it goes live',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        CustomCard(
          child: Column(
            children: [
              _ReviewRow('Pickup',
                  '${_pickupStreetCtrl.text}, ${_pickupCityCtrl.text}, ${_pickupCountryCtrl.text}'),
              const Divider(height: 20),
              _ReviewRow('Delivery',
                  '${_deliveryStreetCtrl.text}, ${_deliveryCityCtrl.text}, ${_deliveryCountryCtrl.text}'),
              const Divider(height: 20),
              _ReviewRow('Pickup date',
                  DateFormat('EEE dd MMM · HH:mm').format(_pickupDate)),
              const Divider(height: 20),
              _ReviewRow('Vehicle', _vehicle.label),
              const Divider(height: 20),
              _ReviewRow('Price',
                  '€${_priceCtrl.text}${_negotiable ? ' (Negotiable)' : ''}'),
              const Divider(height: 20),
              _ReviewRow('Load', _descCtrl.text.isNotEmpty
                  ? _descCtrl.text
                  : '—'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CustomCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'By posting you agree to FreightMatch\'s terms. '
                  'Your listing expires in 14 days if not fulfilled.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;
  final List<String> steps;
  const _StepIndicator({required this.step, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: steps.asMap().entries.map((e) {
            final i = e.key;
            final done   = i < step;
            final active = i == step;
            return Expanded(
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: 200.ms,
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: done || active
                          ? AppColors.primary
                          : AppColors.bgCard,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done || active
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check, size: 14,
                              color: Colors.white)
                          : Text('${i + 1}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? Colors.white
                                    : AppColors.textMuted,
                              )),
                    ),
                  ),
                  if (i < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 1,
                        color: i < step
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps
              .map((s) => Text(s,
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.textMuted)))
              .toList(),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DateField({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                surface: AppColors.bgCard,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6)),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Text(
                  DateFormat('EEE, dd MMM yyyy').format(date),
                  style: GoogleFonts.dmSans(
                      fontSize: 15, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  const _SwitchRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.bodyLarge),
                if (subtitle != null)
                  Text(subtitle!,
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveTrackColor: AppColors.bgElevated,
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted)),
        ),
        Expanded(
          child: Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
