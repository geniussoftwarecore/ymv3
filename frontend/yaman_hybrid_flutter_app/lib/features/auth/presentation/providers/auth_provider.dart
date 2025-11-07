import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaman_hybrid_flutter_app/core/services/biometric_service.dart';
import 'package:yaman_hybrid_flutter_app/core/services/local_auth_storage.dart';

/// حالة المصادقة
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// نموذج حالة المصادقة
class AuthStateData {
  final AuthState state;
  final String? username;
  final String? errorMessage;
  final bool isBiometricAvailable;
  final bool hasLocalSession;
  final bool isConnected;

  AuthStateData({
    required this.state,
    this.username,
    this.errorMessage,
    this.isBiometricAvailable = false,
    this.hasLocalSession = false,
    this.isConnected = true,
  });

  AuthStateData copyWith({
    AuthState? state,
    String? username,
    String? errorMessage,
    bool? isBiometricAvailable,
    bool? hasLocalSession,
    bool? isConnected,
  }) {
    return AuthStateData(
      state: state ?? this.state,
      username: username ?? this.username,
      errorMessage: errorMessage,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      hasLocalSession: hasLocalSession ?? this.hasLocalSession,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

/// Provider للحالة الأولية
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthStateData>(
  (ref) => AuthNotifier(),
);

/// Notifier لإدارة حالة المصادقة
class AuthNotifier extends StateNotifier<AuthStateData> {
  final _biometricService = BiometricService();
  final _localStorage = LocalAuthStorage();

  AuthNotifier() : super(AuthStateData(state: AuthState.initial)) {
    _initialize();
  }

  /// تهيئة الخدمات
  Future<void> _initialize() async {
    try {
      // تهيئة التخزين المحلي
      await _localStorage.initialize();

      // التحقق من توفر البصمات
      final biometricAvailable = await _biometricService.canCheckBiometrics();

      // التحقق من الجلسة المحفوظة
      final hasSession = await _localStorage.hasLocalSession();
      final cachedUsername = await _localStorage.getCachedUsername();

      state = state.copyWith(
        isBiometricAvailable: biometricAvailable,
        hasLocalSession: hasSession,
        username: cachedUsername,
      );
    } catch (e) {
      debugPrint('❌ خطأ في التهيئة: $e');
    }
  }

  /// تسجيل دخول عادي
  Future<bool> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(state: AuthState.loading);

    try {
      // محاكاة التحقق من الخادم
      // في التطبيق الحقيقي، ستستدعي API الخادم
      await Future.delayed(const Duration(seconds: 2));

      // حفظ الجلسة إذا كان "تذكرني" مفعلاً
      if (rememberMe) {
        final sessionData = LocalSessionData(
          username: username,
          password: password,
          email: '$username@example.com',
          userId: 'user_123',
          authToken: 'token_from_server',
          lastLoginTime: DateTime.now(),
          useBiometric: false,
        );

        await _localStorage.saveSessionData(sessionData);
      }

      state = state.copyWith(
        state: AuthState.authenticated,
        username: username,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: 'فشل تسجيل الدخول: $e',
      );
      return false;
    }
  }

  /// تسجيل دخول بالبصمة
  Future<bool> loginWithBiometric() async {
    state = state.copyWith(state: AuthState.loading);

    try {
      // التحقق من وجود جلسة
      final sessionData = await _localStorage.getSessionData();
      if (sessionData == null) {
        throw Exception('لا توجد جلسة محفوظة');
      }

      // المصادقة البيومترية
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'يرجى استخدام البصمة لتسجيل الدخول',
      );

      if (authenticated) {
        // تحديث آخر وقت دخول
        await _localStorage.updateLastLoginTime();

        state = state.copyWith(
          state: AuthState.authenticated,
          username: sessionData.username,
          errorMessage: null,
        );

        return true;
      }

      state = state.copyWith(
        state: AuthState.error,
        errorMessage: 'فشلت المصادقة البيومترية',
      );
      return false;
    } on BiometricUserCanceledException {
      state = state.copyWith(
        state: AuthState.unauthenticated,
        errorMessage: 'تم إلغاء المصادقة',
      );
      return false;
    } on BiometricLockedException catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      return false;
    } on BiometricNotEnrolledException catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      return false;
    } on BiometricNotAvailableException catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: 'خطأ: $e',
      );
      return false;
    }
  }

  /// تسجيل دخول أوفلاين
  Future<bool> loginOffline() async {
    state = state.copyWith(state: AuthState.loading);

    try {
      final sessionData = await _localStorage.getSessionData();
      if (sessionData == null) {
        throw Exception('لا توجد جلسة محفوظة للدخول الأوفلاين');
      }

      // التحقق من صلاحية الجلسة
      final isValid = await _localStorage.isSessionValid();
      if (!isValid) {
        await _localStorage.clearSessionData();
        throw Exception('انتهت صلاحية الجلسة');
      }

      // تحديث آخر وقت دخول
      await _localStorage.updateLastLoginTime();

      state = state.copyWith(
        state: AuthState.authenticated,
        username: sessionData.username,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: 'فشل الدخول الأوفلاين: $e',
      );
      return false;
    }
  }

  /// تسجيل خروج
  Future<void> logout() async {
    try {
      await _localStorage.clearSessionData();

      state = state.copyWith(
        state: AuthState.unauthenticated,
        username: null,
        errorMessage: null,
      );
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الخروج: $e');
    }
  }

  /// تحديث حالة الاتصال
  void updateConnectivityStatus(bool isConnected) {
    state = state.copyWith(isConnected: isConnected);
  }

  /// الحصول على نوع البصمة بصيغة إنسانية
  Future<String> getBiometricTypeName() async {
    return await _biometricService.getBiometricTypeName();
  }

  /// تفعيل/تعطيل البصمة
  Future<void> toggleBiometric(bool enabled) async {
    try {
      await _localStorage.setUseBiometric(enabled);
    } catch (e) {
      debugPrint('❌ خطأ في تحديث إعدادات البصمة: $e');
    }
  }

  /// الحصول على معلومات الجلسة الآمنة
  Future<Map<String, dynamic>?> getSessionInfo() async {
    return await _localStorage.getLastSessionInfo();
  }
}

/// Providers مساعدة
final biometricTypeNameProvider = FutureProvider<String>((ref) async {
  final auth = ref.watch(authStateProvider);
  if (auth.isBiometricAvailable) {
    final authNotifier = ref.read(authStateProvider.notifier);
    return await authNotifier.getBiometricTypeName();
  }
  return 'غير متوفر';
});

final sessionInfoProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authNotifier = ref.read(authStateProvider.notifier);
  return await authNotifier.getSessionInfo();
});
