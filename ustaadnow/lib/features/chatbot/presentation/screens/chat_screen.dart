import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/models/chat_message_model.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/database/app_database.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../auth/data/auth_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/suggestion_chips.dart';
import '../widgets/voice_button.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final sessionIdProvider = StateProvider<String>((ref) {
  final rand = Random();
  final code = 1000 + rand.nextInt(9000);
  return code.toString();
});

final chatMessagesProvider = StateNotifierProvider<ChatNotifier, List<ChatMessageModel>>((ref) {
  return ChatNotifier(ref);
});

final isRecordingProvider = StateProvider<bool>((ref) => false);

final chatLanguageProvider = StateProvider<String>((ref) => 'ur');

class ChatNotifier extends StateNotifier<List<ChatMessageModel>> {
  final Ref _ref;
  ChatNotifier(this._ref) : super([]) {
    _addWelcomeMessage();
  }

  final _uuid = const Uuid();

  void _addWelcomeMessage() {
    state = [
      ChatMessageModel.aiMessage(
        id: _uuid.v4(),
        content: 'Assalam-o-Alaikum! 👋\n\nMai UstaadNow AI hoon. Aap koi bhi service Urdu, Roman Urdu ya English mein book kar sakte hain.\n\nKya chahiye aapko?',
      ),
    ];
  }

  void addAiMessage(String content) {
    state = [...state, ChatMessageModel.aiMessage(id: _uuid.v4(), content: content)];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessageModel.userMessage(id: _uuid.v4(), content: text.trim());
    state = [...state, userMsg];

    // Add loading indicator
    final loadingMsg = ChatMessageModel.loadingMessage();
    state = [...state, loadingMsg];

    try {
      final repo = _ref.read(bookingRepositoryProvider);
      final sessionId = _ref.read(sessionIdProvider);
      final result = await repo.submitRequest(text, sessionId: sessionId);

      // Remove loading indicator
      state = state.where((m) => !m.isLoading).toList();

      if (result is ApiSuccess<Map<String, dynamic>>) {
        final data = result.data;
        
        // 1. Display full raw API response inside log terminal
        debugPrint('=== [UstaadNow AI API Response] ===');
        try {
          debugPrint(const JsonEncoder.withIndent('  ').convert(data));
        } catch (_) {
          debugPrint(data.toString());
        }
        debugPrint('===================================');
        
        final errorText = data['error'] as String?;
        final responseText = data['response_text'] as String? ?? 
                            data['output'] as String? ?? 
                            data['summary'] as String?;

        final followup = data['followup'] as Map<String, dynamic>?;
        final isFollowup = followup != null && followup['status'] == 'incomplete';
        final serviceVal = (data['service_type'] ?? data['service'])?.toString().toLowerCase();

        String finalContent = responseText ?? '✅ Perfect Match Found! Please confirm your booking inside the card.';
        final List<Map<String, dynamic>> parsedProviders = [];

        if (errorText != null && errorText.isNotEmpty) {
          finalContent = errorText;
        } else if (serviceVal == 'none') {
          finalContent = responseText ?? 'Information for this service is not available.';
        } else if (isFollowup) {
          finalContent = followup['followup_question'] as String? ?? responseText ?? '';
        } else {
          // Parse ranked_providers from backend (Happy Path)
          final selectedProvider = data['selected_provider'] as Map<String, dynamic>?;
          final selectedReasoning = selectedProvider?['reasoning'] as String? ?? '';
          final rankedRaw = data['ranked_providers'] ?? data['providers_found'];

          if (rankedRaw is List) {
            for (final item in rankedRaw) {
              if (item is Map<String, dynamic>) {
                final isSelected = selectedProvider != null &&
                    item['id'] == selectedProvider['id'];
                parsedProviders.add({
                  'id': item['id'] ?? '',
                  'name': item['name'] ?? 'Unknown Provider',
                  'service_type': item['service_type'] ?? data['service_type'] ?? 'Service',
                  'location': item['location'] ?? '',
                  'rating': item['rating'] ?? 0.0,
                  'reviews_count': item['reviews_count'] ?? 0,
                  'phone': item['phone'] ?? 'N/A',
                  'distance_km': item['distance_km'] ?? 0.0,
                  'score': item['score'] ?? 0.0,
                  'available': item['available'] ?? true,
                  'reasoning': isSelected ? selectedReasoning : '',
                  'is_selected': isSelected,
                  'pricing': item['pricing'],
                });
              }
            }
          } else if (selectedProvider != null) {
            // Fallback: only selected_provider present
            parsedProviders.add({
              'id': selectedProvider['id'] ?? '',
              'name': selectedProvider['name'] ?? 'Unknown Provider',
              'service_type': selectedProvider['service_type'] ?? data['service_type'] ?? 'Service',
              'location': selectedProvider['location'] ?? '',
              'rating': selectedProvider['rating'] ?? 0.0,
              'reviews_count': selectedProvider['reviews_count'] ?? 0,
              'phone': selectedProvider['phone'] ?? 'N/A',
              'distance_km': selectedProvider['distance_km'] ?? 0.0,
              'score': selectedProvider['score'] ?? 0.0,
              'available': selectedProvider['available'] ?? true,
              'reasoning': selectedProvider['reasoning'] ?? '',
              'is_selected': true,
              'pricing': selectedProvider['pricing'],
            });
          }
        }

        final metadata = <String, dynamic>{
          'has_booking_card': !isFollowup && parsedProviders.isNotEmpty,
          'service': data['service_type'] ?? data['service'] ?? 'Service',
          'location': data['location'] ?? '',
          'time': data['time'] ?? data['slot_time'] ?? data['slot'] ?? '',
          'booking_id': data['booking_id'] ?? data['id'] ?? 'bkg_${DateTime.now().millisecondsSinceEpoch}',
          'estimated_cost': data['estimated_cost'],
          'providers': parsedProviders,
          'request_context': {
            'raw_input': data['raw_input'] ?? text,
            'service_type': data['service_type'] ?? '',
            'location': data['location'] ?? '',
            'time_preference': data['time_preference'] ?? '',
            'language_detected': data['language_detected'] ?? '',
          },
        };

        final aiMsg = ChatMessageModel.aiMessage(
          id: _uuid.v4(),
          content: finalContent,
          metadata: metadata,
        );
        state = [...state, aiMsg];
      } else {
        // Display "Backend not reachable" if API returns error
        final aiMsg = ChatMessageModel.aiMessage(
          id: _uuid.v4(),
          content: 'Backend not reachable',
        );
        state = [...state, aiMsg];
      }
    } catch (e) {
      // Remove loading indicator & fallback to "Backend not reachable"
      state = state.where((m) => !m.isLoading).toList();
      final aiMsg = ChatMessageModel.aiMessage(
        id: _uuid.v4(),
        content: 'Backend not reachable',
      );
      state = [...state, aiMsg];
    }
  }

  void clearChat() {
    state = [];
    _addWelcomeMessage();
    
    // Regenerate session id
    final rand = Random();
    final code = 1000 + rand.nextInt(9000);
    _ref.read(sessionIdProvider.notifier).state = code.toString();
    debugPrint('Session ID regenerated on clear chat: ${code.toString()}');
  }

  Future<void> confirmBooking({
    required Map<String, dynamic> provider,
    required Map<String, dynamic> requestContext,
  }) async {
    final serviceType = (requestContext['service_type'] as String? ?? provider['service_type'] as String? ?? '').trim();

    final loadingMsg = ChatMessageModel.loadingMessage();
    state = [...state, loadingMsg];
    try {
      final repo = _ref.read(bookingRepositoryProvider);

      // ── DEBUG: dump exact keys so we can see if 'id' key exists ──
      debugPrint('\n┌── confirmBooking() called ──');
      debugPrint('│ provider map  : ${jsonEncode(provider)}');
      debugPrint('│ requestContext: ${jsonEncode(requestContext)}');
      debugPrint('└──────────────────────────────');

      final result = await repo.confirmBookingRequest(
        selectedProvider: provider,
        rawInput: requestContext['raw_input'] as String? ?? '',
        serviceType: requestContext['service_type'] as String? ?? '',
        location: requestContext['location'] as String? ?? '',
        timePreference: requestContext['time_preference'] as String? ?? '',
        languageDetected: requestContext['language_detected'] as String? ?? '',
      );
      state = state.where((m) => !m.isLoading).toList();
      if (result is ApiSuccess<Map<String, dynamic>>) {
        final data = result.data;
        final booking = (data['booking'] as Map<String, dynamic>?) ?? data;

        final bookingId = (booking['id'] ?? booking['booking_id'] ?? 'bkg_${DateTime.now().millisecondsSinceEpoch}').toString();
        final serviceType = (booking['service_type'] ?? requestContext['service_type'] ?? 'Service').toString();
        final description = (booking['description'] ?? requestContext['raw_input'] ?? '').toString();
        
        // Get user phone and name from auth provider
        final auth = _ref.read(authProvider);
        final customerName = auth.user?.name ?? (booking['customer_name'] ?? 'Customer').toString();
        final customerPhone = auth.user?.phone ?? (booking['customer_phone'] ?? '').toString();
        
        final location = (booking['location'] ?? requestContext['location'] ?? '').toString();
        final statusStr = (booking['status'] ?? 'pending').toString();
        final status = BookingStatus.values.firstWhere((s) => s.name == statusStr, orElse: () => BookingStatus.pending);
        
        final estimatedCost = (booking['estimated_cost'] as num?)?.toDouble() ?? (requestContext['estimated_cost'] as num?)?.toDouble();
        final finalCost = (booking['final_cost'] as num?)?.toDouble();
        
        final scheduledAtStr = (booking['scheduled_at'] ?? booking['slot_time'] ?? booking['time_preference'] ?? requestContext['time_preference'] ?? DateTime.now().add(const Duration(hours: 2)).toIso8601String()).toString();
        final scheduledAt = DateTime.tryParse(scheduledAtStr) ?? DateTime.now();
        
        final createdAtStr = (booking['created_at'] ?? DateTime.now().toIso8601String()).toString();
        final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

        // Build the assigned provider
        ProviderSummary? assignedProvider;
        final providerMap = booking['assigned_provider'] as Map<String, dynamic>? ?? booking['selected_provider'] as Map<String, dynamic>? ?? provider;
        if (providerMap != null && providerMap.isNotEmpty) {
          assignedProvider = ProviderSummary(
            id: (providerMap['id'] ?? providerMap['provider_id'] ?? '').toString(),
            name: (providerMap['name'] ?? '').toString(),
            phone: (providerMap['phone'] ?? '').toString(),
            serviceType: (providerMap['service_type'] ?? serviceType).toString(),
            rating: (providerMap['rating'] as num?)?.toDouble() ?? 4.8,
            totalJobs: (providerMap['total_jobs'] as num?)?.toInt() ?? (providerMap['reviews_count'] as num?)?.toInt() ?? 12,
            avatarUrl: providerMap['avatar_url'] as String?,
          );
        }
        
        final newBooking = BookingModel(
          id: bookingId,
          serviceType: serviceType,
          description: description,
          customerName: customerName,
          customerPhone: customerPhone,
          location: location,
          scheduledAt: scheduledAt,
          status: status,
          assignedProvider: assignedProvider,
          estimatedCost: estimatedCost,
          finalCost: finalCost,
          originalRequest: requestContext['raw_input'] as String?,
          createdAt: createdAt,
        );

        // Update local Drift DB and update UI reactively
        _ref.read(bookingsNotifierProvider.notifier).addBooking(newBooking);

        state = [
          ...state,
          ChatMessageModel.aiMessage(
            id: _uuid.v4(),
            content: '',
            metadata: <String, dynamic>{
              'has_booking_confirmation': true,
              'booking_id'        : booking['booking_id']    ?? '',
              'provider_name'     : booking['provider_name'] ?? provider['name']  ?? '',
              'provider_phone'    : booking['provider_phone']?? provider['phone'] ?? '',
              'service_type'      : booking['service_type']  ?? requestContext['service_type'] ?? '',
              'location'          : booking['location']       ?? requestContext['location'] ?? '',
              'slot_time'         : booking['slot_time']      ?? requestContext['time_preference'] ?? '',
              'status'            : booking['status']         ?? 'CONFIRMED',
              'confirmation_message': booking['confirmation_message'] ?? '',
            },
          ),
        ];
      } else {
        state = [...state, ChatMessageModel.aiMessage(id: _uuid.v4(), content: '❌ Booking failed. Please try again.')];
      }
    } catch (e) {
      state = state.where((m) => !m.isLoading).toList();
      state = [...state, ChatMessageModel.aiMessage(id: _uuid.v4(), content: '❌ Booking error: ${e.toString()}')];
    }
  }
}


// ── Screen ─────────────────────────────────────────────────────────────────

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage([String? text]) {
    final msg = text ?? _textController.text;
    if (msg.trim().isEmpty) return;
    _textController.clear();
    ref.read(chatMessagesProvider.notifier).sendMessage(msg);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final showSuggestions = messages.isEmpty;
    final theme = Theme.of(context);

    ref.listen(chatMessagesProvider, (_, next) {
      if (next.isNotEmpty) _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('UstaadNow AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Online', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_voice_rounded, color: Colors.white),
            tooltip: 'Voice Language Settings',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Voice Settings', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Set your preferred language for voice feature:', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 24),
                      Consumer(
                        builder: (context, ref, child) {
                          final lang = ref.watch(chatLanguageProvider);
                          final isUrdu = lang == 'ur';
                          return Center(
                            child: GestureDetector(
                              onTap: () {
                                ref.read(chatLanguageProvider.notifier).state = isUrdu ? 'en' : 'ur';
                              },
                              child: Container(
                                width: 120,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedAlign(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      alignment: isUrdu ? Alignment.centerLeft : Alignment.centerRight,
                                      child: Container(
                                        width: 60,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              'URDU',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: isUrdu ? Colors.white : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              'ENG',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: !isUrdu ? Colors.white : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => ref.read(chatMessagesProvider.notifier).clearChat(),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: messages.length + (showSuggestions ? 1 : 0),
              itemBuilder: (context, index) {
                if (showSuggestions && index == messages.length) {
                  return SuggestionChips(
                    suggestions: AppStrings.chatSuggestions,
                    onTap: (s) => _sendMessage(s),
                  );
                }
                final msg = messages[index];
                if (msg.isLoading) return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: TypingIndicator(),
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ChatBubble(message: msg),
                );
              },
            ),
          ),

          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppDimensions.chatInputMinHeight,
                maxHeight: AppDimensions.chatInputMaxHeight,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: AppStrings.chatPlaceholder,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          VoiceButton(
            lang: ref.watch(chatLanguageProvider),
            onVoiceResult: (text) => _sendMessage(text),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: AppDimensions.sendButtonSize,
            height: AppDimensions.sendButtonSize,
            decoration: BoxDecoration(
              gradient: _textController.text.isNotEmpty ? AppColors.primaryGradient : null,
              color: _textController.text.isEmpty ? theme.colorScheme.surfaceContainerHighest : null,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: _textController.text.isNotEmpty ? Colors.white : AppColors.textHint,
                size: 20,
              ),
              onPressed: _textController.text.isNotEmpty ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }
}
