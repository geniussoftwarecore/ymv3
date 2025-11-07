# 💡 أمثلة الاستخدام - نظام التسجيل المتقدم

## 📚 جدول المحتويات

1. [أمثلة أساسية](#أمثلة-أساسية)
2. [أمثلة متقدمة](#أمثلة-متقدمة)
3. [الحالات الخاصة](#الحالات-الخاصة)
4. [معالجة الأخطاء](#معالجة-الأخطاء)

---

## 🎯 أمثلة أساسية

### مثال 1: التحقق من توفر البصمات

```dart
import 'package:yaman_hybrid_flutter_app/core/services/biometric_service.dart';

void checkBiometrics() async {
  final biometricService = BiometricService();
  
  // التحقق من توفر البصمات
  final isAvailable = await biometricService.canCheckBiometrics();
  print('هل البصمات متاحة؟ $isAvailable');
  
  // الحصول على نوع البصمة
  final biometrics = await biometricService.getAvailableBiometrics();
  print('أنواع البيومترية: $biometrics');
  
  // الحصول على اسم البصمة بالعربية
  final name = await biometricService.getBiometricTypeName();
  print('نوع البصمة: $name');
}
```

### مثال 2: حفظ جلسة بعد التسجيل الناجح

```dart
import 'package:yaman_hybrid_flutter_app/core/services/local_auth_storage.dart';

Future<void> saveUserSession(String username, String password, String token) async {
  final localStorage = LocalAuthStorage();
  
  // تهيئة التخزين أولاً
  await localStorage.initialize();
  
  // إنشاء بيانات الجلسة
  final sessionData = LocalSessionData(
    username: username,
    password: password,
    email: 'user@example.com',
    userId: 'user_id_123',
    authToken: token,
    lastLoginTime: DateTime.now(),
    useBiometric: false,
  );
  
  // حفظ الجلسة
  await localStorage.saveSessionData(
    sessionData,
    allowOfflineLogin: true,  // السماح بالدخول الأوفلاين
  );
  
  print('✅ تم حفظ الجلسة بنجاح');
}
```

### مثال 3: استرجاع الجلسة المحفوظة

```dart
Future<void> loadUserSession() async {
  final localStorage = LocalAuthStorage();
  await localStorage.initialize();
  
  // التحقق من وجود جلسة
  final hasSession = await localStorage.hasLocalSession();
  
  if (hasSession) {
    // استرجاع الجلسة
    final sessionData = await localStorage.getSessionData();
    
    if (sessionData != null) {
      print('اسم المستخدم: ${sessionData.username}');
      print('البريد: ${sessionData.email}');
      print('آخر دخول: ${sessionData.lastLoginTime}');
    }
  } else {
    print('لا توجد جلسة محفوظة');
  }
}
```

---

## 🚀 أمثلة متقدمة

### مثال 4: مصادقة متقدمة مع معالجة الأخطاء

```dart
Future<bool> advancedBiometricAuth() async {
  final biometricService = BiometricService();
  
  try {
    // التحقق من التوفر
    final isAvailable = await biometricService.canCheckBiometrics();
    if (!isAvailable) {
      throw BiometricNotAvailableException(
        'البصمات غير متوفرة على هذا الجهاز',
      );
    }
    
    // الحصول على نوع البصمة
    final typeName = await biometricService.getBiometricTypeName();
    print('نوع البصمة المتاح: $typeName');
    
    // محاولة المصادقة
    final authenticated = await biometricService.authenticate(
      localizedReason: 'يرجى استخدام $typeName للتحقق من هويتك',
      useErrorDialogs: true,
      stickyAuth: false,
    );
    
    return authenticated;
    
  } on BiometricUserCanceledException {
    print('❌ تم إلغاء المصادقة من قبل المستخدم');
    return false;
    
  } on BiometricLockedException catch (e) {
    print('🔒 ${e.message}');
    return false;
    
  } on BiometricNotEnrolledException catch (e) {
    print('⚠️ ${e.message}');
    return false;
    
  } on BiometricException catch (e) {
    print('❌ خطأ: ${e.message}');
    return false;
  }
}
```

### مثال 5: نظام تسجيل دخول متكامل

```dart
class AdvancedLoginController {
  final _biometricService = BiometricService();
  final _localStorage = LocalAuthStorage();
  
  /// دورة حياة التسجيل الكاملة
  Future<LoginResult> handleCompleteLogin({
    required String username,
    required String password,
    required bool rememberMe,
    required bool useBiometric,
  }) async {
    try {
      // 1. التحقق من صحة البيانات
      if (username.isEmpty || password.isEmpty) {
        return LoginResult.failure('يرجى إدخال البيانات');
      }
      
      // 2. محاكاة التحقق من الخادم
      final isValid = await _verifyWithServer(username, password);
      if (!isValid) {
        return LoginResult.failure('بيانات خاطئة');
      }
      
      // 3. حفظ الجلسة إذا طُلب ذلك
      if (rememberMe) {
        final sessionData = LocalSessionData(
          username: username,
          password: password,
          email: '$username@example.com',
          userId: 'generated_id',
          authToken: 'token_from_server',
          lastLoginTime: DateTime.now(),
          useBiometric: useBiometric,
        );
        
        await _localStorage.initialize();
        await _localStorage.saveSessionData(sessionData);
      }
      
      // 4. تفعيل البصمة إذا كان مطلوباً
      if (useBiometric && rememberMe) {
        await _localStorage.setUseBiometric(true);
        print('✅ تم تفعيل المصادقة البيومترية');
      }
      
      return LoginResult.success('تم تسجيل الدخول بنجاح');
      
    } catch (e) {
      return LoginResult.failure('خطأ: $e');
    }
  }
  
  Future<bool> _verifyWithServer(String username, String password) async {
    // محاكاة التحقق من الخادم
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

class LoginResult {
  final bool success;
  final String message;
  
  LoginResult.success(this.message) : success = true;
  LoginResult.failure(this.message) : success = false;
}
```

### مثال 6: فحص صلاحية الجلسة

```dart
Future<void> validateSessionExpiry() async {
  final localStorage = LocalAuthStorage();
  await localStorage.initialize();
  
  // التحقق من صلاحية الجلسة (30 يوم)
  final isValid = await localStorage.isSessionValid(
    maxAge: const Duration(days: 30),
  );
  
  if (isValid) {
    print('✅ الجلسة سارية الصلاحية');
    
    // تحديث آخر وقت دخول
    await localStorage.updateLastLoginTime();
  } else {
    print('❌ انتهت صلاحية الجلسة - يرجى تسجيل الدخول مجدداً');
    
    // حذف الجلسة القديمة
    await localStorage.clearSessionData();
  }
}
```

### مثال 7: عرض معلومات الجلسة الآمنة

```dart
Future<void> displaySessionInfo() async {
  final localStorage = LocalAuthStorage();
  await localStorage.initialize();
  
  // الحصول على معلومات الجلسة (بدون كلمة المرور!)
  final info = await localStorage.getLastSessionInfo();
  
  if (info != null) {
    print('👤 اسم المستخدم: ${info['username']}');
    print('📧 البريد: ${info['email']}');
    print('⏰ آخر دخول: ${info['lastLoginTime']}');
    print('🔐 يستخدم البصمة: ${info['useBiometric']}');
  }
}
```

---

## 🎪 الحالات الخاصة

### مثال 8: التعامل مع تسجيل الخروج

```dart
Future<void> handleLogout() async {
  final localStorage = LocalAuthStorage();
  await localStorage.initialize();
  
  try {
    // حذف بيانات الجلسة
    await localStorage.clearSessionData();
    print('✅ تم تسجيل الخروج بنجاح');
    
    // مسح جميع البيانات (اختياري)
    // await localStorage.clearAll();
    
  } catch (e) {
    print('❌ خطأ في تسجيل الخروج: $e');
  }
}
```

### مثال 9: الدخول الأوفلاين

```dart
Future<bool> loginOffline() async {
  final localStorage = LocalAuthStorage();
  await localStorage.initialize();
  
  // التحقق من توفر جلسة
  final sessionData = await localStorage.getSessionData();
  if (sessionData == null) {
    print('❌ لا توجد بيانات للدخول الأوفلاين');
    return false;
  }
  
  // التحقق من صلاحية الجلسة
  final isValid = await localStorage.isSessionValid();
  if (!isValid) {
    print('❌ انتهت صلاحية الجلسة');
    await localStorage.clearSessionData();
    return false;
  }
  
  // تحديث وقت الدخول
  await localStorage.updateLastLoginTime();
  
  print('✅ تم تسجيل الدخول بنجاح (أوفلاين)');
  print('👤 المستخدم: ${sessionData.username}');
  
  return true;
}
```

### مثال 10: الدخول بالبصمة مع الأوفلاين

```dart
Future<bool> loginWithBiometricOffline() async {
  final biometricService = BiometricService();
  final localStorage = LocalAuthStorage();
  
  await localStorage.initialize();
  
  try {
    // 1. التحقق من توفر الجلسة
    final sessionData = await localStorage.getSessionData();
    if (sessionData == null || !sessionData.useBiometric) {
      print('❌ البصمة غير مفعلة أو لا توجد جلسة');
      return false;
    }
    
    // 2. محاولة المصادقة البيومترية
    final authenticated = await biometricService.authenticate(
      localizedReason: 'استخدم البصمة للدخول الأوفلاين',
    );
    
    if (!authenticated) {
      print('❌ فشلت المصادقة البيومترية');
      return false;
    }
    
    // 3. تحديث وقت الدخول
    await localStorage.updateLastLoginTime();
    
    print('✅ تسجيل دخول بالبصمة (أوفلاين) ناجح');
    return true;
    
  } catch (e) {
    print('❌ خطأ: $e');
    return false;
  }
}
```

---

## ⚠️ معالجة الأخطاء

### مثال 11: معالج شامل للأخطاء

```dart
String getErrorMessage(dynamic error) {
  if (error is BiometricNotAvailableException) {
    return '🔧 البصمات غير متوفرة على هذا الجهاز';
  } else if (error is BiometricNotEnrolledException) {
    return '📝 يرجى تسجيل بصمتك في إعدادات الجهاز أولاً';
  } else if (error is BiometricLockedException) {
    return '🔒 تم قفل البصمة مؤقتاً - حاول لاحقاً';
  } else if (error is BiometricUserCanceledException) {
    return '❌ تم إلغاء العملية';
  } else if (error is BiometricException) {
    return '❌ خطأ في البصمة: ${error.message}';
  } else {
    return '❌ حدث خطأ غير متوقع: $error';
  }
}

void showBiometricError(dynamic error) {
  final message = getErrorMessage(error);
  print(message);
  
  // يمكن عرض رسالة للمستخدم
  // showDialog(context: context, builder: (ctx) => AlertDialog(
  //   title: Text('خطأ'),
  //   content: Text(message),
  // ));
}
```

### مثال 12: إعادة محاولة ذكية

```dart
Future<bool> smartBiometricRetry({
  int maxRetries = 3,
}) async {
  final biometricService = BiometricService();
  int attempts = 0;
  
  while (attempts < maxRetries) {
    try {
      final result = await biometricService.authenticate(
        localizedReason: 'حاول مرة أخرى (${attempts + 1}/$maxRetries)',
      );
      
      if (result) return true;
      
    } on BiometricUserCanceledException {
      print('تم إلغاء المحاولة');
      return false;
      
    } on BiometricLockedException {
      print('تم قفل البصمة - توقف المحاولات');
      return false;
      
    } catch (e) {
      attempts++;
      if (attempts < maxRetries) {
        print('محاولة $attempts فشلت - إعادة المحاولة...');
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }
  
  print('❌ فشلت جميع المحاولات');
  return false;
}
```

---

## 📋 نموذج الاستخدام الكامل

### مثال 13: تطبيق كامل للتسجيل

```dart
import 'package:flutter/material.dart';
import 'package:yaman_hybrid_flutter_app/core/services/biometric_service.dart';
import 'package:yaman_hybrid_flutter_app/core/services/local_auth_storage.dart';

class CompleteLoginExample extends StatefulWidget {
  const CompleteLoginExample({Key? key}) : super(key: key);

  @override
  State<CompleteLoginExample> createState() => _CompleteLoginExampleState();
}

class _CompleteLoginExampleState extends State<CompleteLoginExample> {
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _rememberMe = false;
  bool _useBiometric = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final localStorage = LocalAuthStorage();
    await localStorage.initialize();

    final hasSession = await localStorage.hasLocalSession();
    if (hasSession) {
      final username = await localStorage.getCachedUsername();
      setState(() {
        _usernameCtl.text = username ?? '';
        _rememberMe = true;
      });
    }
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      // محاكاة تسجيل الدخول
      await Future.delayed(const Duration(seconds: 1));

      final localStorage = LocalAuthStorage();
      await localStorage.initialize();

      if (_rememberMe) {
        final sessionData = LocalSessionData(
          username: _usernameCtl.text,
          password: _passwordCtl.text,
          email: '${_usernameCtl.text}@example.com',
          userId: 'user_123',
          authToken: 'token_xyz',
          lastLoginTime: DateTime.now(),
          useBiometric: _useBiometric,
        );
        await localStorage.saveSessionData(sessionData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تسجيل الدخول بنجاح')),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ خطأ: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نموذج التسجيل')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameCtl,
              decoration: const InputDecoration(labelText: 'اسم المستخدم'),
            ),
            TextField(
              controller: _passwordCtl,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            CheckboxListTile(
              title: const Text('تذكرني'),
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('استخدام البصمة'),
              value: _useBiometric,
              onChanged: (v) => setState(() => _useBiometric = v ?? false),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('دخول'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }
}
```

---

## 🎓 الخلاصة

هذه الأمثلة توضح:
- ✅ كيفية استخدام خدمات البيومترية
- ✅ كيفية حفظ واسترجاع الجلسات
- ✅ معالجة الأخطاء بشكل صحيح
- ✅ الأوفلاين والدخول بدون إنترنت
- ✅ الممارسات الأمنة

للمزيد من التفاصيل، انظر `LOGIN_ENHANCEMENT_GUIDE.md`