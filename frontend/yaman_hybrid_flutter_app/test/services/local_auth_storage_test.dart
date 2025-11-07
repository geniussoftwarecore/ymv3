import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaman_hybrid_flutter_app/core/services/local_auth_storage.dart';

void main() {
  late LocalAuthStorage localStorage;
  late LocalSessionData testSession;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    localStorage = LocalAuthStorage();
    await localStorage.initialize();

    testSession = LocalSessionData(
      username: 'testuser',
      password: 'password123',
      email: 'test@example.com',
      userId: 'user_123',
      authToken: 'token_xyz',
      lastLoginTime: DateTime.now(),
      useBiometric: false,
    );
  });

  group('LocalSessionData Tests', () {
    test('toJson - يجب تحويل البيانات إلى JSON صحيح', () {
      final json = testSession.toJson();

      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['userId'], 'user_123');
      expect(json['authToken'], 'token_xyz');
      expect(json['useBiometric'], false);
    });

    test('fromJson - يجب إنشاء instance من JSON', () {
      final json = testSession.toJson();
      final restored = LocalSessionData.fromJson(json);

      expect(restored.username, testSession.username);
      expect(restored.email, testSession.email);
      expect(restored.userId, testSession.userId);
      expect(restored.authToken, testSession.authToken);
    });
  });

  group('LocalAuthStorage Tests', () {
    test('Singleton pattern - يجب إرجاع نفس الكائن', () {
      final storage1 = LocalAuthStorage();
      final storage2 = LocalAuthStorage();

      expect(identical(storage1, storage2), true);
    });

    test('saveSessionData - يجب حفظ البيانات بنجاح', () async {
      await localStorage.saveSessionData(testSession);

      final saved = await localStorage.hasLocalSession();
      expect(saved, true);
    });

    test('getSessionData - يجب استرجاع البيانات المحفوظة', () async {
      await localStorage.saveSessionData(testSession);

      final retrieved = await localStorage.getSessionData();

      expect(retrieved, isNotNull);
      expect(retrieved!.username, 'testuser');
      expect(retrieved.email, 'test@example.com');
    });

    test('hasLocalSession - يجب إرجاع true عند وجود جلسة', () async {
      final beforeSave = await localStorage.hasLocalSession();
      expect(beforeSave, false);

      await localStorage.saveSessionData(testSession);

      final afterSave = await localStorage.hasLocalSession();
      expect(afterSave, true);
    });

    test('getCachedUsername - يجب إرجاع اسم المستخدم المخزن', () async {
      await localStorage.saveSessionData(testSession);

      final username = await localStorage.getCachedUsername();

      expect(username, 'testuser');
    });

    test('clearSessionData - يجب حذف الجلسة', () async {
      await localStorage.saveSessionData(testSession);
      expect(await localStorage.hasLocalSession(), true);

      await localStorage.clearSessionData();

      expect(await localStorage.hasLocalSession(), false);
    });

    test('isOfflineLoginEnabled - يجب التحقق من تفعيل الأوفلاين', () async {
      await localStorage.saveSessionData(
        testSession,
        allowOfflineLogin: true,
      );

      final isEnabled = await localStorage.isOfflineLoginEnabled();
      expect(isEnabled, true);
    });

    test('isSessionValid - يجب التحقق من صلاحية الجلسة', () async {
      await localStorage.saveSessionData(testSession);

      // جلسة حديثة يجب أن تكون صحيحة
      final isValid = await localStorage.isSessionValid(
        maxAge: const Duration(days: 30),
      );
      expect(isValid, true);

      // جلسة قديمة جداً (0 يوم)
      final isInvalid = await localStorage.isSessionValid(
        maxAge: const Duration(days: 0),
      );
      expect(isInvalid, false);
    });

    test('updateLastLoginTime - يجب تحديث الوقت', () async {
      await localStorage.saveSessionData(testSession);

      final oldTime = (await localStorage.getSessionData())!.lastLoginTime;

      await Future.delayed(const Duration(milliseconds: 100));
      await localStorage.updateLastLoginTime();

      final newTime = (await localStorage.getSessionData())!.lastLoginTime;

      expect(newTime.isAfter(oldTime), true);
    });

    test('setUseBiometric - يجب تفعيل/تعطيل البصمة', () async {
      await localStorage.saveSessionData(testSession);

      expect((await localStorage.getSessionData())!.useBiometric, false);

      await localStorage.setUseBiometric(true);

      expect((await localStorage.getSessionData())!.useBiometric, true);
    });

    test('getLastSessionInfo - يجب إرجاع البيانات آمنة', () async {
      await localStorage.saveSessionData(testSession);

      final info = await localStorage.getLastSessionInfo();

      expect(info, isNotNull);
      expect(info!['username'], 'testuser');
      expect(info['email'], 'test@example.com');
      expect(info.containsKey('password'), false); // لا تحفظ الكلمة!
    });

    test('clearAll - يجب مسح جميع البيانات', () async {
      await localStorage.saveSessionData(testSession);

      await localStorage.clearAll();

      expect(await localStorage.hasLocalSession(), false);
      expect(await localStorage.getCachedUsername(), null);
    });
  });

  group('Edge Cases Tests', () {
    test('getSessionData عند عدم وجود جلسة - يجب إرجاع null', () async {
      final session = await localStorage.getSessionData();
      expect(session, null);
    });

    test('getCachedUsername عند عدم وجود جلسة - يجب إرجاع null', () async {
      final username = await localStorage.getCachedUsername();
      expect(username, null);
    });

    test('isOfflineLoginEnabled عند عدم وجود جلسة - يجب إرجاع false', () async {
      final isEnabled = await localStorage.isOfflineLoginEnabled();
      expect(isEnabled, false);
    });

    test('updateLastLoginTime عند عدم وجود جلسة - لا يجب أن يرمي exception',
        () async {
      expect(
        () => localStorage.updateLastLoginTime(),
        returnsNormally,
      );
    });

    test('setUseBiometric عند عدم وجود جلسة - لا يجب أن يرمي exception',
        () async {
      expect(
        () => localStorage.setUseBiometric(true),
        returnsNormally,
      );
    });
  });

  group('Multiple Operations Tests', () {
    test('حفظ واسترجاع عدة جلسات - تبديل بينهم', () async {
      final session1 = LocalSessionData(
        username: 'user1',
        password: 'pass1',
        email: 'user1@example.com',
        userId: 'id1',
        authToken: 'token1',
        lastLoginTime: DateTime.now(),
      );

      final session2 = LocalSessionData(
        username: 'user2',
        password: 'pass2',
        email: 'user2@example.com',
        userId: 'id2',
        authToken: 'token2',
        lastLoginTime: DateTime.now(),
      );

      // حفظ الأولى
      await localStorage.saveSessionData(session1);
      expect((await localStorage.getSessionData())!.username, 'user1');

      // الكتابة فوق بالثانية
      await localStorage.saveSessionData(session2);
      expect((await localStorage.getSessionData())!.username, 'user2');

      // مسح
      await localStorage.clearSessionData();
      expect(await localStorage.getSessionData(), null);
    });
  });
}
