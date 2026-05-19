import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/models/user_model.dart';
import '../../booking/data/repositories/booking_repository.dart';

// ── Auth state ──────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    bool? isAuthenticated,
  }) => AuthState(
        user: user ?? this.user,
        token: token ?? this.token,
        isLoading: isLoading ?? this.isLoading,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AppDatabase _db;
  // Start with isLoading:true so the splash never sees a false-negative
  // isLoading:false before _checkAuth has had a chance to run.
  AuthNotifier(this._db) : super(const AuthState(isLoading: true)) {
    _checkAuth();
  }

  static const _tokenKey = 'auth_token';

  Future<void> _checkAuth() async {
    try {
      state = state.copyWith(isLoading: true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token != null) {
        final userEntry = await _db.getUserByToken(token);
        if (userEntry != null) {
          state = AuthState(
            isAuthenticated: true,
            token: token,
            user: UserModel(
              id: userEntry.id,
              name: userEntry.name,
              phone: userEntry.phone,
              address: userEntry.address ?? '',
              role: userEntry.role == 'provider' ? UserRole.provider : UserRole.customer,
              createdAt: userEntry.createdAt,
            ),
            isLoading: false,
          );
        } else {
          // Token stale — clear it and treat as logged-out
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_tokenKey);
          state = const AuthState(isLoading: false, isAuthenticated: false);
        }
      } else {
        state = const AuthState(isLoading: false, isAuthenticated: false);
      }
    } catch (e, stack) {
      // In case database path/file issues or missing libs throw, set loading to false so the UI can proceed
      debugPrint('AuthNotifier._checkAuth error: $e\n$stack');
      state = const AuthState(isLoading: false, isAuthenticated: false);
    }
  }

  Future<bool> signUpUser({
    required String name,
    required String phone,
    required String password,
    required String address,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true);

    final user = UserEntry(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      passwordHash: password, // Store password locally in SQLite
      address: address,
      role: role.name,
      otp: null,
      isVerified: true, // Mark verified directly, bypassing OTP!
      createdAt: DateTime.now(),
    );

    // Insert user into SQLite table
    await _db.insertUser(user);
    state = state.copyWith(isLoading: false);
    return true;
  }

  Future<bool> loginUser({
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    final userEntry = await _db.getUserByPhone(phone);

    if (userEntry != null) {
      if (userEntry.passwordHash == password) {
        // Successful login
        final token = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        
        final updatedUser = userEntry.copyWith(token: Value(token));
        await _db.updateUser(updatedUser);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);

        state = AuthState(
          isAuthenticated: true,
          token: token,
          user: UserModel(
            id: userEntry.id,
            name: userEntry.name,
            phone: userEntry.phone,
            address: userEntry.address ?? '',
            role: userEntry.role == 'provider' ? UserRole.provider : UserRole.customer,
            createdAt: userEntry.createdAt,
          ),
          isLoading: false,
        );
        return true;
      }
    }

    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<void> signOut() async {
    if (state.token != null) {
      final userEntry = await _db.getUserByToken(state.token!);
      if (userEntry != null) {
        final clearedUser = userEntry.copyWith(token: const Value(null));
        await _db.updateUser(clearedUser);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    state = const AuthState();
  }

  void updateAvailability(bool isOnline) {
    if (state.user == null) return;
    state = state.copyWith(user: state.user!.copyWith(isOnline: isOnline));
  }
}

// Watch database provider to wire in AppDatabase dependency
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // Retrieve singleton Drift database instance
  final db = ref.watch(appDatabaseProvider);
  return AuthNotifier(db);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
