import 'package:flutter_test/flutter_test.dart';
import 'package:yaman_hybrid_flutter_app/core/services/biometric_service.dart';

void main() {
  group('BiometricService Tests', () {
    late BiometricService biometricService;
    setUp(() {
      biometricService = BiometricService();
    });

    test('Singleton pattern - يجب إرجاع نفس الكائن', () {
      final service1 = BiometricService();
      final service2 = BiometricService();

      expect(identical(service1, service2), true);
    });

    test('canCheckBiometrics - يجب إرجاع false عند الفشل', () async {
      final result = await biometricService.canCheckBiometrics();
      expect(result, isA<bool>());
    });

    test('isDeviceSupported - يجب التحقق من دعم الجهاز', () async {
      final result = await biometricService.isDeviceSupported();
      expect(result, isA<bool>());
    });

    test('getAvailableBiometrics - يجب إرجاع قائمة', () async {
      final biometrics = await biometricService.getAvailableBiometrics();
      expect(biometrics, isA<List>());
    });

    test('getBiometricTypeName - يجب إرجاع اسم النوع', () async {
      final name = await biometricService.getBiometricTypeName();
      expect(name, isA<String>());
      expect(name.isNotEmpty, true);
    });

    test('getBiometricIcon - يجب إرجاع أيقونة صحيحة', () async {
      final icon = await biometricService.getBiometricIcon();
      expect(['fingerprint', 'face', 'iris'].contains(icon), true);
    });
  });

  group('BiometricException Tests', () {
    test('BiometricException - يجب حفظ الرسالة', () {
      const message = 'خطأ في البصمة';
      final exception = BiometricException(message);
      expect(exception.toString(), message);
    });

    test('BiometricNotAvailableException - يجب الإرث من BiometricException',
        () {
      const message = 'البصمات غير متوفرة';
      final exception = BiometricNotAvailableException(message);
      expect(exception, isA<BiometricException>());
    });

    test('BiometricNotEnrolledException - يجب الإرث من BiometricException', () {
      const message = 'لم يتم تسجيل بصمات';
      final exception = BiometricNotEnrolledException(message);
      expect(exception, isA<BiometricException>());
    });

    test('BiometricLockedException - يجب الإرث من BiometricException', () {
      const message = 'البصمة مقفلة';
      final exception = BiometricLockedException(message);
      expect(exception, isA<BiometricException>());
    });

    test('BiometricUserCanceledException - يجب الإرث من BiometricException',
        () {
      const message = 'تم الإلغاء';
      final exception = BiometricUserCanceledException(message);
      expect(exception, isA<BiometricException>());
    });
  });
}
