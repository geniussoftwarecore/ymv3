import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;

import '../../../../generated/l10n.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/language_toggle_button.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/local_auth_storage.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isBiometricAvailable = false;
  bool _hasLocalSession = false;
  String? _cachedUsername;
  bool _isConnected = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _biometricService = BiometricService();
  final _localAuthStorage = LocalAuthStorage();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription?
      _connectivitySubscription; // Handle both old and new connectivity_plus API

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeAuth();
    _checkConnectivity();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  /// تهيئة خدمات المصادقة
  Future<void> _initializeAuth() async {
    try {
      // تهيئة التخزين المحلي
      await _localAuthStorage.initialize();

      // التحقق من توفر البصمات
      final biometricAvailable = await _biometricService.canCheckBiometrics();

      // التحقق من الجلسة المحفوظة
      final hasSession = await _localAuthStorage.hasLocalSession();
      final cachedUsername = await _localAuthStorage.getCachedUsername();

      if (mounted) {
        setState(() {
          _isBiometricAvailable = biometricAvailable;
          _hasLocalSession = hasSession;
          _cachedUsername = cachedUsername;
        });
      }
    } catch (e) {
      debugPrint('خطأ في تهيئة المصادقة: $e');
    }
  }

  /// التحقق من الاتصال بالإنترنت
  void _checkConnectivity() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((dynamic result) {
      if (mounted) {
        setState(() {
          // Handle both old (ConnectivityResult) and new (List<ConnectivityResult>) API
          try {
            if (result is List) {
              // New API (6.0+): returns List<ConnectivityResult>
              _isConnected = !(result as List<ConnectivityResult>)
                  .contains(ConnectivityResult.none);
            } else {
              // Old API (5.0.x): returns ConnectivityResult
              _isConnected = result != ConnectivityResult.none;
            }
          } catch (e) {
            debugPrint('خطأ في التحقق من الاتصال: $e');
            _isConnected = true; // Default to connected if there's an error
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// معالج تسجيل الدخول العادي (اسم المستخدم + كلمة المرور)
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // محاكاة عملية تسجيل الدخول من الخادم
      await Future.delayed(const Duration(seconds: 2));

      // حفظ الجلسة محلياً إذا كان "تذكرني" مفعلاً
      if (_rememberMe) {
        final sessionData = LocalSessionData(
          username: username,
          password: password, // تحذير: عادة لا يتم حفظ الكلمات المرورية!
          email: '$username@example.com',
          userId: 'user_123',
          authToken: 'token_xyz',
          lastLoginTime: DateTime.now(),
          useBiometric: false,
        );
        await _localAuthStorage.saveSessionData(sessionData);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // الانتقال إلى لوحة التحكم
        Future.microtask(() {
          if (mounted) context.go('/dashboard');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('فشل تسجيل الدخول: $e');
      }
    }
  }

  /// تسجيل الدخول الأوفلاين باستخدام البيانات المحفوظة
  Future<void> _handleOfflineLogin() async {
    final sessionData = await _localAuthStorage.getSessionData();
    if (sessionData == null) {
      _showErrorDialog('لا توجد بيانات محفوظة لتسجيل دخول أوفلاين');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // في التطبيق الحقيقي، يمكن التحقق من البيانات المحفوظة محلياً
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showSuccessDialog('تم تسجيل الدخول أوفلاين بنجاح');

        // تحديث آخر وقت دخول
        await _localAuthStorage.updateLastLoginTime();

        // الانتقال إلى لوحة التحكم
        Future.microtask(() {
          if (mounted) context.go('/dashboard');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('فشل تسجيل الدخول الأوفلاين: $e');
      }
    }
  }

  /// تسجيل الدخول باستخدام البصمة
  Future<void> _handleBiometricLogin() async {
    try {
      final sessionData = await _localAuthStorage.getSessionData();
      if (sessionData == null) {
        _showErrorDialog('لا توجد بيانات محفوظة للمصادقة البيومترية');
        return;
      }

      // محاولة المصادقة البيومترية
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'يرجى استخدام البصمة لتسجيل الدخول',
      );

      if (authenticated) {
        setState(() {
          _isLoading = true;
        });

        // محاكاة عملية التحقق
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          _showSuccessDialog('تم تسجيل الدخول بالبصمة بنجاح');

          // تحديث آخر وقت دخول
          await _localAuthStorage.updateLastLoginTime();

          // الانتقال إلى لوحة التحكم
          Future.microtask(() {
            if (mounted) context.go('/dashboard');
          });
        }
      }
    } on BiometricUserCanceledException {
      // المستخدم ألغى العملية
      debugPrint('تم إلغاء المصادقة');
    } on BiometricLockedException {
      _showErrorDialog('تم قفل البصمة مؤقتاً. يرجى المحاولة لاحقاً');
    } on BiometricNotEnrolledException {
      _showErrorDialog('لم يتم تسجيل أي بصمات على هذا الجهاز');
    } on BiometricNotAvailableException {
      _showErrorDialog('البصمات غير متوفرة على هذا الجهاز');
    } catch (e) {
      _showErrorDialog('فشلت المصادقة البيومترية: $e');
    }
  }

  /// عرض رسالة الخطأ
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  /// عرض رسالة النجاح
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ نجح'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isRTL = locale.isRTL;

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Language Toggle Button
                            Align(
                              alignment: isRTL
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: const LanguageToggleButton(),
                            ),

                            const SizedBox(height: 16),

                            // App Logo and Title
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.build_circle,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 24),

                            Text(
                              S.of(context).appName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              S.of(context).welcome,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),

                            const SizedBox(height: 32),

                            // ⚠️ الحالة (أوفلاين/اتصال)
                            if (!_isConnected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(51, 255, 152, 0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  border: Border(
                                    top: BorderSide(
                                        color: Colors.orange, width: 1),
                                    bottom: BorderSide(
                                        color: Colors.orange, width: 1),
                                    left: BorderSide(
                                        color: Colors.orange, width: 1),
                                    right: BorderSide(
                                        color: Colors.orange, width: 1),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.wifi_off,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '⚠️ أنت غير متصل بالإنترنت',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (!_isConnected) const SizedBox(height: 16),

                            // Login Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Username Field (جديد)
                                  CustomTextField(
                                    controller: _usernameController,
                                    labelText: 'اسم المستخدم',
                                    prefixIcon: Icons.person_outline,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال اسم المستخدم';
                                      }
                                      if (value.length < 3) {
                                        return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Password Field
                                  CustomTextField(
                                    controller: _passwordController,
                                    labelText: S.of(context).password,
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال كلمة المرور';
                                      }
                                      if (value.length < 6) {
                                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                      }
                                      return null;
                                    },
                                    onSubmitted: (_) => _handleLogin(),
                                  ),

                                  const SizedBox(height: 16),

                                  // Remember Me and Forgot Password
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                      Text(
                                        S.of(context).rememberMe,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {
                                          // Handle forgot password
                                        },
                                        child:
                                            Text(S.of(context).forgotPassword),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _handleLogin,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(S.of(context).login),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Divider
                                  Row(
                                    children: [
                                      const Expanded(
                                          child: Divider(thickness: 1)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          'أو',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                      const Expanded(
                                          child: Divider(thickness: 1)),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Biometric Login Button (إذا كانت متاحة)
                                  if (_isBiometricAvailable) ...[
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: OutlinedButton.icon(
                                        onPressed: _isLoading
                                            ? null
                                            : _handleBiometricLogin,
                                        icon: const Icon(Icons.fingerprint),
                                        label: const Text('تسجيل دخول بالبصمة'),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // Offline Login Button (إذا كانت جلسة محفوظة وبدون إنترنت)
                                  if (_hasLocalSession && !_isConnected) ...[
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: OutlinedButton.icon(
                                        onPressed: _isLoading
                                            ? null
                                            : _handleOfflineLogin,
                                        icon: const Icon(Icons.cloud_off),
                                        label: Text(
                                          'تسجيل دخول أوفلاين كـ $_cachedUsername',
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
