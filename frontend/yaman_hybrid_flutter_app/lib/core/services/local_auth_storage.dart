import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// نموذج بيانات الجلسة المحفوظة محلياً
class LocalSessionData {
  final String username;
  final String password;
  final String email;
  final String userId;
  final String authToken;
  final DateTime lastLoginTime;
  final bool useBiometric;

  LocalSessionData({
    required this.username,
    required this.password,
    required this.email,
    required this.userId,
    required this.authToken,
    required this.lastLoginTime,
    this.useBiometric = false,
  });

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'userId': userId,
      'authToken': authToken,
      'lastLoginTime': lastLoginTime.toIso8601String(),
      'useBiometric': useBiometric,
    };
  }

  /// إنشاء من JSON
  factory LocalSessionData.fromJson(Map<String, dynamic> json) {
    return LocalSessionData(
      username: json['username'] as String,
      password: json['password'] as String,
      email: json['email'] as String,
      userId: json['userId'] as String,
      authToken: json['authToken'] as String,
      lastLoginTime: DateTime.parse(json['lastLoginTime'] as String),
      useBiometric: json['useBiometric'] as bool? ?? false,
    );
  }
}

/// خدمة حفظ واسترجاع بيانات تسجيل الدخول محلياً
class LocalAuthStorage {
  static final LocalAuthStorage _instance = LocalAuthStorage._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  // مفاتيح التخزين
  static const String _lastSessionKey = 'last_session_data';
  static const String _offlineLoginEnabledKey = 'offline_login_enabled';
  static const String _cachedUsernameKey = 'cached_username';

  LocalAuthStorage._internal();

  factory LocalAuthStorage() {
    return _instance;
  }

  /// تهيئة الخدمة
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// التحقق من التهيئة
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// حفظ بيانات الجلسة بعد تسجيل الدخول الناجح
  ///
  /// معاملات:
  /// - [sessionData]: بيانات الجلسة المراد حفظها
  /// - [allowOfflineLogin]: هل نسمح بتسجيل الدخول الأوفلاين لاحقاً
  Future<void> saveSessionData(
    LocalSessionData sessionData, {
    bool allowOfflineLogin = true,
  }) async {
    await _ensureInitialized();

    try {
      await _prefs.setString(
        _lastSessionKey,
        jsonEncode(sessionData.toJson()),
      );

      await _prefs.setBool(_offlineLoginEnabledKey, allowOfflineLogin);
      await _prefs.setString(_cachedUsernameKey, sessionData.username);

      debugPrint('✅ تم حفظ بيانات الجلسة بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في حفظ بيانات الجلسة: $e');
      rethrow;
    }
  }

  /// استرجاع بيانات الجلسة المحفوظة
  ///
  /// Returns:
  /// - [LocalSessionData] إذا كانت موجودة
  /// - `null` إذا لم تكن هناك بيانات محفوظة
  Future<LocalSessionData?> getSessionData() async {
    await _ensureInitialized();

    try {
      final jsonString = _prefs.getString(_lastSessionKey);
      if (jsonString == null) return null;

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return LocalSessionData.fromJson(jsonData);
    } catch (e) {
      debugPrint('❌ خطأ في استرجاع بيانات الجلسة: $e');
      return null;
    }
  }

  /// التحقق من توفر جلسة محفوظة
  Future<bool> hasLocalSession() async {
    await _ensureInitialized();
    return _prefs.containsKey(_lastSessionKey);
  }

  /// التحقق من تفعيل تسجيل الدخول الأوفلاين
  Future<bool> isOfflineLoginEnabled() async {
    await _ensureInitialized();
    return _prefs.getBool(_offlineLoginEnabledKey) ?? false;
  }

  /// الحصول على اسم المستخدم المخزن مؤخراً
  Future<String?> getCachedUsername() async {
    await _ensureInitialized();
    return _prefs.getString(_cachedUsernameKey);
  }

  /// حذف بيانات الجلسة (تسجيل خروج)
  Future<void> clearSessionData() async {
    await _ensureInitialized();

    try {
      await _prefs.remove(_lastSessionKey);
      await _prefs.remove(_offlineLoginEnabledKey);
      debugPrint('✅ تم حذف بيانات الجلسة');
    } catch (e) {
      debugPrint('❌ خطأ في حذف بيانات الجلسة: $e');
      rethrow;
    }
  }

  /// مسح جميع البيانات المحفوظة
  Future<void> clearAll() async {
    await _ensureInitialized();

    try {
      await _prefs.clear();
      debugPrint('✅ تم مسح جميع البيانات المحفوظة');
    } catch (e) {
      debugPrint('❌ خطأ في مسح البيانات: $e');
      rethrow;
    }
  }

  /// التحقق من صحة بيانات الجلسة
  /// بالتحقق من أن البيانات لم تمضِ عليها مدة طويلة
  Future<bool> isSessionValid({
    Duration maxAge = const Duration(days: 30),
  }) async {
    final session = await getSessionData();
    if (session == null) return false;

    final now = DateTime.now();
    final age = now.difference(session.lastLoginTime);

    return age < maxAge;
  }

  /// تحديث آخر وقت للجلسة
  Future<void> updateLastLoginTime() async {
    await _ensureInitialized();

    final session = await getSessionData();
    if (session != null) {
      final updatedSession = LocalSessionData(
        username: session.username,
        password: session.password,
        email: session.email,
        userId: session.userId,
        authToken: session.authToken,
        lastLoginTime: DateTime.now(),
        useBiometric: session.useBiometric,
      );
      await saveSessionData(updatedSession);
    }
  }

  /// تفعيل/تعطيل تسجيل الدخول بالبصمة
  Future<void> setUseBiometric(bool enabled) async {
    await _ensureInitialized();

    final session = await getSessionData();
    if (session != null) {
      final updatedSession = LocalSessionData(
        username: session.username,
        password: session.password,
        email: session.email,
        userId: session.userId,
        authToken: session.authToken,
        lastLoginTime: session.lastLoginTime,
        useBiometric: enabled,
      );
      await saveSessionData(updatedSession);
    }
  }

  /// الحصول على معلومات عن آخر جلسة دون استرجاع البيانات الحساسة
  Future<Map<String, dynamic>?> getLastSessionInfo() async {
    final session = await getSessionData();
    if (session == null) return null;

    return {
      'username': session.username,
      'email': session.email,
      'lastLoginTime': session.lastLoginTime.toLocal().toString(),
      'useBiometric': session.useBiometric,
    };
  }
}
