import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/models/trace_log_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../auth/data/auth_provider.dart';

// ── Database Provider ───────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ── Repository Provider ─────────────────────────────────────────────────────

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(DioClient.instance);
});

// ── Bookings Notifier ───────────────────────────────────────────────────────

class BookingsNotifier extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final AppDatabase _db;
  final BookingRepository _repo;
  final AuthState _authState;

  BookingsNotifier(this._db, this._repo, this._authState) : super(const AsyncValue.loading()) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    final user = _authState.user;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    final userPhone = user.phone;
    final isProvider = user.role == UserRole.provider;

    try {
      // 1. Fetch fresh list from Backend API
      final result = await _repo.getBookings();
      
      if (result is ApiSuccess<List<BookingModel>>) {
        final bookings = result.data;
        // 2. Cache in local Drift database for offline/caching support
        for (final b in bookings) {
          await _db.upsertBooking(
            BookingEntry(
              id: b.id,
              serviceType: b.serviceType,
              description: b.description,
              customerName: b.customerName,
              location: b.location,
              status: b.status.name,
              estimatedCost: b.estimatedCost,
              scheduledAt: b.scheduledAt,
              createdAt: b.createdAt,
              rawJson: jsonEncode(b.toJson()),
            ),
          );
        }

        // Filter bookings belonging to this user
        final filteredBookings = bookings.where((b) {
          if (isProvider) {
            return b.assignedProvider?.phone == userPhone;
          } else {
            return b.customerPhone == userPhone;
          }
        }).toList();

        state = AsyncValue.data(filteredBookings);
        return;
      }
    } catch (_) {}

    // 3. Fallback: Load from Drift local database in case of network issues/offline
    try {
      final dbEntries = await _db.getAllBookings();
      final localBookings = dbEntries.map((e) {
        return BookingModel.fromJson(jsonDecode(e.rawJson) as Map<String, dynamic>);
      }).where((b) {
        if (isProvider) {
          return b.assignedProvider?.phone == userPhone;
        } else {
          return b.customerPhone == userPhone;
        }
      }).toList();
      state = AsyncValue.data(localBookings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> createBooking(BookingModel booking) async {
    // 1. Save to local SQLite cache
    try {
      await _db.upsertBooking(
        BookingEntry(
          id: booking.id,
          serviceType: booking.serviceType,
          description: booking.description,
          customerName: booking.customerName,
          location: booking.location,
          status: booking.status.name,
          estimatedCost: booking.estimatedCost,
          scheduledAt: booking.scheduledAt,
          createdAt: booking.createdAt,
          rawJson: jsonEncode(booking.toJson()),
        ),
      );
    } catch (_) {}

    // 2. Post to Python Backend
    final result = await _repo.createBooking(booking);
    
    // 3. Reload lists reactively
    await loadBookings();
    return result is ApiSuccess;
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    // Try updating status on backend
    try {
      await _repo.updateBookingStatus(bookingId, newStatus);
    } catch (e) {
      debugPrint('Backend update failed, updating local only: $e');
    }
    
    // Update locally in Drift database
    final entry = await _db.getBookingById(bookingId);
    if (entry != null) {
      final currentBooking = BookingModel.fromJson(jsonDecode(entry.rawJson) as Map<String, dynamic>);
      final updatedBooking = currentBooking.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      
      await _db.upsertBooking(
        BookingEntry(
          id: updatedBooking.id,
          serviceType: updatedBooking.serviceType,
          description: updatedBooking.description,
          customerName: updatedBooking.customerName,
          location: updatedBooking.location,
          status: updatedBooking.status.name,
          estimatedCost: updatedBooking.estimatedCost,
          scheduledAt: updatedBooking.scheduledAt,
          createdAt: updatedBooking.createdAt,
          rawJson: jsonEncode(updatedBooking.toJson()),
        ),
      );
    }
    
    await loadBookings();
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, BookingStatus.cancelled);
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
    }
  }

  Future<void> addBooking(BookingModel booking) async {
    try {
      await _db.upsertBooking(
        BookingEntry(
          id: booking.id,
          serviceType: booking.serviceType,
          description: booking.description,
          customerName: booking.customerName,
          location: booking.location,
          status: booking.status.name,
          estimatedCost: booking.estimatedCost,
          scheduledAt: booking.scheduledAt,
          createdAt: booking.createdAt,
          rawJson: jsonEncode(booking.toJson()),
        ),
      );
    } catch (_) {}
    await loadBookings();
  }

  Future<void> clearAllCache() async {
    await _db.delete(_db.bookingsTable).go();
    state = const AsyncValue.data([]);
  }
}

final bookingsNotifierProvider = StateNotifierProvider<BookingsNotifier, AsyncValue<List<BookingModel>>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = ref.watch(bookingRepositoryProvider);
  final authState = ref.watch(authProvider);
  return BookingsNotifier(db, repo, authState);
});

final bookingTraceProvider = FutureProvider.family<List<TraceStep>, String>((ref, bookingId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final result = await repo.getTrace(bookingId);
  
  if (result is ApiSuccess<Map<String, dynamic>>) {
    final agentLogs = result.data['agent_logs'] as List?;
    if (agentLogs != null) {
      return agentLogs.map((logMap) {
        final map = logMap as Map<String, dynamic>;
        final agent = map['agent'] as String? ?? 'Agent';
        final status = map['status'] as String? ?? 'success';
        final summary = map['output_summary'] as String? ?? 'Operation completed';
        
        // Map to friendly name
        String agentName = agent;
        if (agent == 'intent_agent') agentName = 'Intent Detector';
        if (agent == 'discovery_agent') agentName = 'Provider Discovery';
        if (agent == 'matching_agent') agentName = 'Provider Ranker';
        
        return TraceStep(
          agentName: agentName,
          action: 'Running $agent',
          result: summary,
          duration: const Duration(milliseconds: 250),
          success: status == 'success',
          timestamp: DateTime.now(),
        );
      }).toList();
    }
  }
  
  // Return fallback mock steps if API down / 404
  return TraceStep.mockSteps;
});

// ── Repository ──────────────────────────────────────────────────────────────

class BookingRepository {
  final Dio _dio;
  BookingRepository(this._dio);

  /// POST /api/request — submit a text service request
  Future<ApiResult<Map<String, dynamic>>> submitRequest(String input, {String? sessionId}) async {
    try {
      final payload = <String, dynamic>{
        'input': input,
      };
      if (sessionId != null) {
        payload['session_id'] = sessionId;
      }
      final response = await _dio.post(
        ApiConstants.request,
        data: payload,
      );
      return ApiSuccess(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiError(
        message: NetworkException.fromDioException(e).message,
        type: NetworkException.fromDioException(e).type,
      );
    } catch (e) {
      return ApiError(message: e.toString(), type: ApiErrorType.unknown);
    }
  }

  /// POST /api/bookings — confirm and save a booking with the selected provider
  Future<ApiResult<Map<String, dynamic>>> confirmBookingRequest({
    required Map<String, dynamic> selectedProvider,
    required String rawInput,
    required String serviceType,
    required String location,
    required String timePreference,
    required String languageDetected,
  }) async {
    // Build a payload that matches the backend /api/bookings contract.
    debugPrint('\n┌── confirmBookingRequest: raw selectedProvider keys ──');
    debugPrint('│ ${selectedProvider.keys.toList()}');
    debugPrint('│ id          = ${selectedProvider['id']}');
    debugPrint('│ provider_id = ${selectedProvider['provider_id']}');
    debugPrint('│ name        = ${selectedProvider['name']}');
    debugPrint('└─────────────────────────────────────────────────────');

    // Support both 'id' and 'provider_id' key from backend
    final resolvedProviderId =
        (selectedProvider['id'] as String? ?? '').isNotEmpty
            ? selectedProvider['id'] as String
            : (selectedProvider['provider_id'] as String? ?? '');

    final payload = <String, dynamic>{
      'raw_input': rawInput,
      'service_type': serviceType.isNotEmpty ? serviceType : (selectedProvider['service_type'] ?? ''),
      'location': location.isNotEmpty ? location : (selectedProvider['location'] ?? ''),
      'time_preference': timePreference.isNotEmpty ? timePreference : 'As soon as possible',
      'language_detected': languageDetected,
      'is_booking_confirmed': true,
      'selected_provider': {
        'id': resolvedProviderId,
        'name': selectedProvider['name'] ?? '',
        'phone': selectedProvider['phone'] ?? 'N/A',
      },
    };
    debugPrint('\n╔══ POST ${ApiConstants.bookings} [confirmBookingRequest] ══');
    debugPrint('║ PAYLOAD: ${jsonEncode(payload)}');
    debugPrint('╚════════════════════════════════════════════════');
    try {
      final response = await _dio.post(ApiConstants.bookings, data: payload);
      debugPrint('✅ confirmBookingRequest ${response.statusCode}: ${jsonEncode(response.data)}');
      return ApiSuccess(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('❌ confirmBookingRequest DioException:');
      debugPrint('   Status  : ${e.response?.statusCode}');
      debugPrint('   Headers : ${e.response?.headers}');
      debugPrint('   Body    : ${jsonEncode(e.response?.data)}');
      debugPrint('   Message : ${e.message}');
      return ApiError(
        message: NetworkException.fromDioException(e).message,
        type: NetworkException.fromDioException(e).type,
      );
    } catch (e) {
      debugPrint('❌ confirmBookingRequest unknown error: $e');
      return ApiError(message: e.toString(), type: ApiErrorType.unknown);
    }
  }



  Future<ApiResult<Map<String, dynamic>>> submitAudioRequest(String filePath, {String? sessionId, String lang = 'ur'}) async {
    try {
      final map = <String, dynamic>{
        'audio': await MultipartFile.fromFile(filePath, filename: 'voice.m4a'),
        'lang': lang,
      };
      if (sessionId != null) {
        map['session_id'] = sessionId;
      }
      final formData = FormData.fromMap(map);
      
      debugPrint('=== [Dio Multipart Audio Request] ===');
      debugPrint('Sending file path: $filePath');
      debugPrint('session_id: $sessionId');
      for (var file in formData.files) {
        debugPrint('File key: ${file.key}, filename: ${file.value.filename}, length: ${file.value.length}');
      }
      for (var field in formData.fields) {
        debugPrint('Field: ${field.key} = ${field.value}');
      }
      debugPrint('======================================');

      final response = await _dio.post(
        ApiConstants.requestAudio,
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      return ApiSuccess(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiError(
        message: NetworkException.fromDioException(e).message,
        type: NetworkException.fromDioException(e).type,
      );
    } catch (e) {
      return ApiError(message: e.toString(), type: ApiErrorType.unknown);
    }
  }

  /// POST /api/bookings — create a booking on backend
  Future<ApiResult<Map<String, dynamic>>> createBooking(BookingModel booking) async {
    final payload = booking.toJson();
    debugPrint('\n╔══ POST ${ApiConstants.bookings} [createBooking] ══');
    debugPrint('║ PAYLOAD: ${jsonEncode(payload)}');
    debugPrint('╚════════════════════════════════════════════════');
    try {
      final response = await _dio.post(
        ApiConstants.bookings,
        data: payload,
      );
      debugPrint('✅ createBooking ${response.statusCode}: ${jsonEncode(response.data)}');
      return ApiSuccess(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('❌ createBooking DioException:');
      debugPrint('   Status  : ${e.response?.statusCode}');
      debugPrint('   Headers : ${e.response?.headers}');
      debugPrint('   Body    : ${jsonEncode(e.response?.data)}');
      debugPrint('   Message : ${e.message}');
      return ApiError(
        message: NetworkException.fromDioException(e).message,
        type: NetworkException.fromDioException(e).type,
      );
    } catch (e) {
      debugPrint('❌ createBooking unknown error: $e');
      return ApiError(message: e.toString(), type: ApiErrorType.unknown);
    }
  }

  /// PATCH /api/bookings/{id} — update booking status on backend
  Future<ApiResult<Map<String, dynamic>>> updateBookingStatus(String id, BookingStatus status) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.bookings}/$id',
        data: {'status': status.name},
      );
      return ApiSuccess(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiError(
        message: NetworkException.fromDioException(e).message,
        type: NetworkException.fromDioException(e).type,
      );
    } catch (e) {
      return ApiError(message: e.toString(), type: ApiErrorType.unknown);
    }
  }

  /// GET /api/bookings — fetch all bookings
  Future<ApiResult<List<BookingModel>>> getBookings() async {
    try {
      final response = await _dio.get(ApiConstants.bookings);
      final list = (response.data as List)
          .map((j) => BookingModel.fromJson(j as Map<String, dynamic>))
          .toList();
      return ApiSuccess(list);
    } on DioException catch (e) {
      return ApiError(
        message: NetworkException.fromDioException(e).message,
        type: NetworkException.fromDioException(e).type,
      );
    } catch (e) {
      return ApiError(message: e.toString(), type: ApiErrorType.unknown);
    }
  }

  /// GET /api/trace/{booking_id} — fetch AI agent trace logs
  Future<ApiResult<Map<String, dynamic>>> getTrace(String bookingId) async {
    try {
      final response = await _dio.get(ApiConstants.trace(bookingId));
      return ApiSuccess(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiError(
        message: NetworkException.fromDioException(e).message,
        type: NetworkException.fromDioException(e).type,
      );
    } catch (e) {
      return ApiError(message: e.toString(), type: ApiErrorType.unknown);
    }
  }

  /// GET /api/health — health check
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(ApiConstants.health);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
