import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// خدمة المصادقة البيومترية (البصمة والتعرف على الوجه)
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();

  late final LocalAuthentication _auth = LocalAuthentication();

  BiometricService._internal();

  factory BiometricService() {
    return _instance;
  }

  /// التحقق من توافر البصمات على الجهاز
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// التحقق من توافر المصادقة البيولوجية (بصمة/وجه)
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على قائمة أنواع البيومترية المتاحة
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// المصادقة البيومترية
  ///
  /// Parameters:
  /// - [localizedReason]: الرسالة المعروضة للمستخدم
  ///
  /// Returns:
  /// - `true` إذا نجحت المصادقة
  /// - `false` أو رمي exception إذا فشلت
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      // التحقق من توافر البصمات أولاً
      final isAvailable = await canCheckBiometrics();
      if (!isAvailable) {
        throw BiometricNotAvailableException(
          'البصمات غير متوفرة على هذا الجهاز',
        );
      }

      final result = await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
          useErrorDialogs: useErrorDialogs,
        ),
      );

      return result;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        throw BiometricNotAvailableException(
          'البصمات غير متوفرة على هذا الجهاز',
        );
      } else if (e.code == 'NotEnrolled') {
        throw BiometricNotEnrolledException(
          'لم يتم تسجيل أي بصمات على هذا الجهاز',
        );
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        throw BiometricLockedException(
          'تم قفل البصمة مؤقتاً. يرجى المحاولة لاحقاً',
        );
      } else if (e.code == 'UserCanceled') {
        throw BiometricUserCanceledException(
          'تم إلغاء المصادقة من قبل المستخدم',
        );
      }
      throw BiometricException('فشلت المصادقة: ${e.message}');
    } catch (e) {
      throw BiometricException('خطأ غير متوقع: $e');
    }
  }

  /// التحقق من نوع البيومترية المتاح
  Future<BiometricType?> getAvailableBiometricType() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) return null;
      return biometrics.first;
    } catch (e) {
      return null;
    }
  }

  /// معلومات إنسانية عن نوع البيومترية
  Future<String> getBiometricTypeName() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) {
        return 'غير متوفر';
      }

      final names = biometrics.map((type) {
        switch (type) {
          case BiometricType.face:
            return 'التعرف على الوجه';
          case BiometricType.fingerprint:
            return 'بصمة الإصبع';
          case BiometricType.iris:
            return 'بصمة العين';
          case BiometricType.weak:
            return 'مصادقة بيومترية ضعيفة';
          case BiometricType.strong:
            return 'مصادقة بيومترية قوية';
        }
      }).toList();

      return names.join(' و ');
    } catch (e) {
      return 'غير متوفر';
    }
  }

  /// الحصول على أيقونة مناسبة لنوع البيومترية
  Future<String> getBiometricIcon() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) return 'fingerprint';

      for (final type in biometrics) {
        switch (type) {
          case BiometricType.face:
            return 'face';
          case BiometricType.fingerprint:
            return 'fingerprint';
          case BiometricType.iris:
            return 'iris';
          default:
            return 'fingerprint';
        }
      }
      return 'fingerprint';
    } catch (e) {
      return 'fingerprint';
    }
  }
}

// Custom Exceptions
class BiometricException implements Exception {
  final String message;
  BiometricException(this.message);

  @override
  String toString() => message;
}

class BiometricNotAvailableException extends BiometricException {
  BiometricNotAvailableException(super.message);
}

class BiometricNotEnrolledException extends BiometricException {
  BiometricNotEnrolledException(super.message);
}

class BiometricLockedException extends BiometricException {
  BiometricLockedException(super.message);
}

class BiometricUserCanceledException extends BiometricException {
  BiometricUserCanceledException(super.message);
}
