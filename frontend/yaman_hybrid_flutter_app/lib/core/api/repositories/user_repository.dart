import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';

class UserModel {
  final int id;
  final String uuid;
  final String username;
  final String email;
  final String? fullName;
  final String? phone;
  final List<String> roles;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.uuid,
    required this.username,
    required this.email,
    this.fullName,
    this.phone,
    required this.roles,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      roles: List<String>.from(json['roles'] as List? ?? []),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'username': username,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'roles': roles,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final int expiresIn;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      expiresIn: json['expires_in'] as int,
    );
  }
}

class UserRepository {
  final Dio _dio;
  final SharedPreferences _prefs;

  UserRepository(this._dio, this._prefs);

  Future<TokenResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '${APIConstants.userManagementServiceUrl}${APIEndpoints.login}',
        data: {
          'username': username,
          'password': password,
        },
      );

      final tokenResponse =
          TokenResponse.fromJson(response.data as Map<String, dynamic>);

      // Save tokens
      await _prefs.setString('access_token', tokenResponse.accessToken);
      await _prefs.setString('refresh_token', tokenResponse.refreshToken);
      await _prefs.setString('user', tokenResponse.user.toJson().toString());

      return tokenResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TokenResponse> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '${APIConstants.userManagementServiceUrl}/users/register',
        data: data,
      );

      final tokenResponse =
          TokenResponse.fromJson(response.data as Map<String, dynamic>);

      await _prefs.setString('access_token', tokenResponse.accessToken);
      await _prefs.setString('refresh_token', tokenResponse.refreshToken);

      return tokenResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get(
        '${APIConstants.userManagementServiceUrl}${APIEndpoints.profile}',
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(
        '${APIConstants.userManagementServiceUrl}${APIEndpoints.logout}',
      );
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await _prefs.remove('access_token');
      await _prefs.remove('refresh_token');
      await _prefs.remove('user');
    }
  }

  Future<TokenResponse> refreshToken() async {
    try {
      final refreshToken = _prefs.getString('refresh_token');
      if (refreshToken == null) throw Exception('No refresh token');

      final response = await _dio.post(
        '${APIConstants.userManagementServiceUrl}/users/refresh',
        data: {'refresh_token': refreshToken},
      );

      final tokenResponse =
          TokenResponse.fromJson(response.data as Map<String, dynamic>);
      await _prefs.setString('access_token', tokenResponse.accessToken);

      return tokenResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String? getStoredToken() => _prefs.getString('access_token');

  String _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return 'البيانات غير صحيحة';
    } else if (e.response?.statusCode == 404) {
      return 'المستخدم غير موجود';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'انتهت مهلة الاتصال';
    }
    return e.message ?? 'خطأ غير معروف';
  }
}
