import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/models/chat_message_model.dart';
import '../../../../features/booking/data/repositories/booking_repository.dart';
import '../screens/chat_screen.dart';

class ChatBubble extends ConsumerWidget {
  final ChatMessageModel message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final meta = message.metadata;
    final safeMeta = meta ?? <String, dynamic>{};
    final hasBookingCard = meta != null && meta['has_booking_card'] == true;
    final hasConfirmation = meta != null && meta['has_booking_confirmation'] == true;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 16),
            ),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width *
                      (isUser ? 0.85 : 0.90)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.userBubble
                      : (isDark ? AppColors.aiBubbleDark : AppColors.aiBubble),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  border: isUser
                      ? null
                      : Border.all(
                          color:
                              isDark ? AppColors.borderDark : AppColors.border,
                          width: 1,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: isUser
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.content.isNotEmpty) ...[
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      if (hasBookingCard || hasConfirmation)
                        const SizedBox(height: 10),
                    ],

                    // Booking confirmation card (after successful booking)
                    if (hasConfirmation)
                      _BookingConfirmationCard(meta: safeMeta, isDark: isDark),

                    // Expandable provider accordion cards
                    if (hasBookingCard)
                      _ProviderAccordionList(
                        meta: safeMeta,
                        isDark: isDark,
                        ref: ref,
                      ),


                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: isUser ? Colors.white60 : AppColors.textHint,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

// ── Booking Confirmation Card ───────────────────────────────────────────────

class _BookingConfirmationCard extends StatelessWidget {
  final Map<String, dynamic> meta;
  final bool isDark;

  const _BookingConfirmationCard({required this.meta, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bookingId = meta['booking_id']?.toString() ?? '';
    final providerName = meta['provider_name']?.toString() ?? '';
    final providerPhone = meta['provider_phone']?.toString() ?? '';
    final serviceType = meta['service_type']?.toString() ?? '';
    final location = meta['location']?.toString() ?? '';
    final slotTime = meta['slot_time']?.toString() ?? '';
    final confirmMsg = meta['confirmation_message']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D2018) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green header banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Booking Confirmed! 🎉',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                if (bookingId.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bookingId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (providerName.isNotEmpty)
                  _infoRow(Icons.person_rounded, 'Provider', providerName, isDark),
                if (providerPhone.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  _infoRow(Icons.phone_android_rounded, 'Contact', providerPhone, isDark),
                ],
                if (serviceType.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  _infoRow(Icons.build_circle_rounded, 'Service', serviceType, isDark),
                ],
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  _infoRow(Icons.location_on_rounded, 'Location', location, isDark),
                ],
                if (slotTime.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  _infoRow(Icons.access_time_filled_rounded, 'Scheduled', slotTime, isDark,
                      valueColor: AppColors.primary),
                ],
                if (confirmMsg.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 13,
                            color: AppColors.success.withValues(alpha: 0.8)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            confirmMsg,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.4,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF166534),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.success.withValues(alpha: 0.75)),
        const SizedBox(width: 7),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ??
                  (isDark ? Colors.white : const Color(0xFF1A1A2E)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Accordion list ─────────────────────────────────────────────────────────

class _ProviderAccordionList extends StatefulWidget {
  final Map<String, dynamic> meta;
  final bool isDark;
  final WidgetRef ref;

  const _ProviderAccordionList({
    required this.meta,
    required this.isDark,
    required this.ref,
  });

  @override
  State<_ProviderAccordionList> createState() => _ProviderAccordionListState();
}

class _ProviderAccordionListState extends State<_ProviderAccordionList> {
  final Set<int> _expanded = {};
  final Set<int> _ignored = {};

  @override
  void initState() {
    super.initState();
    final providers = _getProviders();
    for (int i = 0; i < providers.length; i++) {
      if (providers[i]['is_selected'] == true) {
        _expanded.add(i);
        break;
      }
    }
    if (_expanded.isEmpty && providers.isNotEmpty) {
      _expanded.add(0);
    }
  }

  List<Map<String, dynamic>> _getProviders() {
    final raw = widget.meta['providers'];
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final providers = _getProviders();
    if (providers.isEmpty) return const SizedBox.shrink();

    final service = widget.meta['service']?.toString() ?? 'Service';
    final requestContext =
        widget.meta['request_context'] as Map<String, dynamic>? ?? {};

    // Build a Set of provider IDs that already have active bookings in DB
    final bookings = widget.ref.watch(bookingsNotifierProvider).value ?? [];
    final bookedProviderIds = <String>{};
    for (final b in bookings) {
      if (b.status == BookingStatus.pending || b.status == BookingStatus.inProgress) {
        final pid = b.assignedProvider?.id ?? '';
        if (pid.isNotEmpty) bookedProviderIds.add(pid);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header pill
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 11, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${providers.length} $service Provider${providers.length > 1 ? 's' : ''} Found',
                  style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // Horizontal Cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(providers.length, (i) {
              if (_ignored.contains(i)) return const SizedBox.shrink();
              final providerId = (providers[i]['id'] ?? '').toString();
              return Container(
                width: 270,
                margin: const EdgeInsets.only(right: 12),
                child: _ProviderAccordionCard(
                  provider: providers[i],
                  index: i,
                  isExpanded: _expanded.contains(i),
                  isAlreadyBooked: providerId.isNotEmpty && bookedProviderIds.contains(providerId),
                  onToggle: () => setState(() {
                    if (_expanded.contains(i)) {
                      _expanded.remove(i);
                    } else {
                      _expanded.add(i);
                    }
                  }),
                  onIgnore: () => setState(() {
                    _ignored.add(i);
                    _expanded.remove(i);
                  }),
                  onConfirm: () {
                    widget.ref.read(chatMessagesProvider.notifier).confirmBooking(
                          provider: providers[i],
                          requestContext: requestContext,
                        );
                  },
                  isDark: widget.isDark,
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 6),
      ],
    );
  }
}

// ── Single accordion card ──────────────────────────────────────────────────

class _ProviderAccordionCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final int index;
  final bool isExpanded;
  final bool isDark;
  final bool isAlreadyBooked;
  final VoidCallback onToggle;
  final VoidCallback onIgnore;
  final VoidCallback onConfirm;

  const _ProviderAccordionCard({
    required this.provider,
    required this.index,
    required this.isExpanded,
    required this.isDark,
    required this.isAlreadyBooked,
    required this.onToggle,
    required this.onIgnore,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final name = provider['name']?.toString() ?? 'Unknown';
    final rating = (provider['rating'] ?? 0.0) as num;
    final reviews = (provider['reviews_count'] ?? 0) as int;
    final phone = provider['phone']?.toString() ?? 'N/A';
    final location = provider['location']?.toString() ?? '';
    final distanceKm = (provider['distance_km'] ?? 0.0) as num;
    final score = (provider['score'] ?? 0.0) as num;
    final reasoning = provider['reasoning']?.toString() ?? '';
    final isSelected = provider['is_selected'] == true;
    final available = provider['available'] == true;

    final cardBorderColor = isSelected
        ? AppColors.primary
        : AppColors.primary.withValues(alpha: 0.2);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D23) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorderColor, width: isSelected ? 1.6 : 1),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header row (always visible, tappable) ──
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(14),
              bottom: Radius.circular(isExpanded ? 0 : 14),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Name + meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'AI Pick',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: Color(0xFFFFC107)),
                            Text(
                              '$rating ($reviews)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                            Text('•',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54)),
                            Icon(Icons.location_on_rounded,
                                size: 11,
                                color:
                                    AppColors.primary.withValues(alpha: 0.7)),
                            Text(
                              '${distanceKm.toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable body ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedBody(context, name, phone, location,
                distanceKm, score, reasoning, available),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedBody(
    BuildContext context,
    String name,
    String phone,
    String location,
    num distanceKm,
    num score,
    String reasoning,
    bool available,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
            height: 1,
            thickness: 1,
            color: AppColors.primary.withValues(alpha: 0.12)),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(Icons.phone_android_rounded, 'Phone', phone,
                  isDark: isDark),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 6),
                _detailRow(Icons.location_on_rounded, 'Address', location,
                    isDark: isDark),
              ],
              const SizedBox(height: 6),
              _detailRow(Icons.route_rounded, 'Distance',
                  '${distanceKm.toStringAsFixed(2)} km away',
                  isDark: isDark),
              const SizedBox(height: 6),
              _detailRow(
                  Icons.analytics_outlined,
                  'Match Score',
                  '${(score * 100).toStringAsFixed(0)}%',
                  isDark: isDark,
                  valueColor: _scoreColor(score)),
              const SizedBox(height: 6),
              _detailRow(
                  available
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  'Availability',
                  available ? 'Available Now' : 'Not Available',
                  isDark: isDark,
                  valueColor: available ? AppColors.success : Colors.red),
              if (reasoning.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 13, color: AppColors.primary),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          reasoning,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.2),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      onPressed: onIgnore,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded, size: 15),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text('Ignore',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 12.5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: isAlreadyBooked
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy_rounded,
                                    size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Already Booked',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                        color: Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              elevation: 1,
                            ),
                            onPressed: onConfirm,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 15),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text('Confirm',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5)),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Color _scoreColor(num score) {
    if (score >= 0.85) return AppColors.success;
    if (score >= 0.65) return const Color(0xFFFFA726);
    return Colors.red;
  }

  Widget _detailRow(IconData icon, String label, String value,
      {required bool isDark, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.primary.withValues(alpha: 0.75)),
        const SizedBox(width: 7),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  valueColor ?? (isDark ? Colors.white : const Color(0xFF1A1A2E)),
            ),
          ),
        ),
      ],
    );
  }
}
