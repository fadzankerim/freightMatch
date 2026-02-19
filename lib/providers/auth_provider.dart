import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';
import '../utils/constants.dart';

const Object _unset = Object();

class AuthState {
  final AppUser? user;
  final bool isAuthenticated;
  final bool isLoading;
  final bool isInitialized;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  AuthState copyWith({
    Object? user = _unset,
    bool? isAuthenticated,
    bool? isLoading,
    bool? isInitialized,
    Object? error = _unset,
  }) =>
      AuthState(
        user: user == _unset ? this.user : user as AppUser?,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        isInitialized: isInitialized ?? this.isInitialized,
        error: error == _unset ? this.error : error as String?,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  final _api = ApiService.instance;
  final _googleAuth = GoogleAuthService.instance;

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.keyCurrentUser);
      if (raw == null) {
        state = state.copyWith(isInitialized: true);
        return;
      }

      final data = jsonDecode(raw) as Map<String, dynamic>;
      final user = AppUser.fromJson(data);
      state = AuthState(
        user: user,
        isAuthenticated: true,
        isInitialized: true,
      );
    } catch (_) {
      state = const AuthState(isInitialized: true);
    }
  }

  Future<void> _persistUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrentUser, jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyCurrentUser);
    await prefs.remove(AppConstants.keyAuthToken);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _api.login(email, password);
      await _persistUser(user);
      state = AuthState(
        user: user,
        isAuthenticated: true,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _googleAuth.signIn();
      final user = await _api.loginWithGoogle(
        idToken: session.idToken,
        fallbackUser: session.user,
      );
      final prefs = await SharedPreferences.getInstance();
      if (session.idToken != null && session.idToken!.isNotEmpty) {
        await prefs.setString(AppConstants.keyAuthToken, session.idToken!);
      }
      await _persistUser(user);
      state = AuthState(
        user: user,
        isAuthenticated: true,
        isInitialized: true,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        state = state.copyWith(isLoading: false, error: null);
        return;
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserType userType,
    required UserLocation homeLocation,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _api.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        userType: userType,
        homeLocation: homeLocation,
      );
      await _persistUser(user);
      state = AuthState(
        user: user,
        isAuthenticated: true,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _googleAuth.signOut();
    await _clearSession();
    state = const AuthState(isInitialized: true);
  }

  void updateUser(AppUser updated) =>
      state = state.copyWith(user: updated);
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

final currentUserProvider =
    Provider<AppUser?>((ref) => ref.watch(authProvider).user);

final isAuthenticatedProvider =
    Provider<bool>((ref) => ref.watch(authProvider).isAuthenticated);
