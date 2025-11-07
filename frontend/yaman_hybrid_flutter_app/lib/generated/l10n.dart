// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of(context, S);
  }

  /// `يمن هايبرد`
  String get appName {
    return Intl.message(
      'يمن هايبرد',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `مرحباً`
  String get welcome {
    return Intl.message(
      'مرحباً',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل الدخول`
  String get login {
    return Intl.message(
      'تسجيل الدخول',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل الخروج`
  String get logout {
    return Intl.message(
      'تسجيل الخروج',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `البريد الإلكتروني`
  String get email {
    return Intl.message(
      'البريد الإلكتروني',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `كلمة المرور`
  String get password {
    return Intl.message(
      'كلمة المرور',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `نسيت كلمة المرور؟`
  String get forgotPassword {
    return Intl.message(
      'نسيت كلمة المرور؟',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `تذكرني`
  String get rememberMe {
    return Intl.message(
      'تذكرني',
      name: 'rememberMe',
      desc: '',
      args: [],
    );
  }

  /// `لوحة التحكم`
  String get dashboard {
    return Intl.message(
      'لوحة التحكم',
      name: 'dashboard',
      desc: '',
      args: [],
    );
  }

  /// `أوامر العمل`
  String get workOrders {
    return Intl.message(
      'أوامر العمل',
      name: 'workOrders',
      desc: '',
      args: [],
    );
  }

  /// `العملاء`
  String get customers {
    return Intl.message(
      'العملاء',
      name: 'customers',
      desc: '',
      args: [],
    );
  }

  /// `المركبات`
  String get vehicles {
    return Intl.message(
      'المركبات',
      name: 'vehicles',
      desc: '',
      args: [],
    );
  }

  /// `المحادثات`
  String get chat {
    return Intl.message(
      'المحادثات',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `الإعدادات`
  String get settings {
    return Intl.message(
      'الإعدادات',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `الملف الشخصي`
  String get profile {
    return Intl.message(
      'الملف الشخصي',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `الإشعارات`
  String get notifications {
    return Intl.message(
      'الإشعارات',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `بحث`
  String get search {
    return Intl.message(
      'بحث',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `تصفية`
  String get filter {
    return Intl.message(
      'تصفية',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `ترتيب`
  String get sort {
    return Intl.message(
      'ترتيب',
      name: 'sort',
      desc: '',
      args: [],
    );
  }

  /// `إضافة`
  String get add {
    return Intl.message(
      'إضافة',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `تعديل`
  String get edit {
    return Intl.message(
      'تعديل',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `حذف`
  String get delete {
    return Intl.message(
      'حذف',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `حفظ`
  String get save {
    return Intl.message(
      'حفظ',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `إلغاء`
  String get cancel {
    return Intl.message(
      'إلغاء',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد`
  String get confirm {
    return Intl.message(
      'تأكيد',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `نعم`
  String get yes {
    return Intl.message(
      'نعم',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `لا`
  String get no {
    return Intl.message(
      'لا',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `موافق`
  String get ok {
    return Intl.message(
      'موافق',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `خطأ`
  String get error {
    return Intl.message(
      'خطأ',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `نجح`
  String get success {
    return Intl.message(
      'نجح',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `تحذير`
  String get warning {
    return Intl.message(
      'تحذير',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `معلومات`
  String get info {
    return Intl.message(
      'معلومات',
      name: 'info',
      desc: '',
      args: [],
    );
  }

  /// `جاري التحميل...`
  String get loading {
    return Intl.message(
      'جاري التحميل...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد بيانات`
  String get noData {
    return Intl.message(
      'لا توجد بيانات',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `إعادة المحاولة`
  String get retry {
    return Intl.message(
      'إعادة المحاولة',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `تحديث`
  String get refresh {
    return Intl.message(
      'تحديث',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `الاسم`
  String get name {
    return Intl.message(
      'الاسم',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `الهاتف`
  String get phone {
    return Intl.message(
      'الهاتف',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `العنوان`
  String get address {
    return Intl.message(
      'العنوان',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `الحالة`
  String get status {
    return Intl.message(
      'الحالة',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `التاريخ`
  String get date {
    return Intl.message(
      'التاريخ',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `الوقت`
  String get time {
    return Intl.message(
      'الوقت',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `الوصف`
  String get description {
    return Intl.message(
      'الوصف',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `ملاحظات`
  String get notes {
    return Intl.message(
      'ملاحظات',
      name: 'notes',
      desc: '',
      args: [],
    );
  }

  /// `الأولوية`
  String get priority {
    return Intl.message(
      'الأولوية',
      name: 'priority',
      desc: '',
      args: [],
    );
  }

  /// `عالية`
  String get high {
    return Intl.message(
      'عالية',
      name: 'high',
      desc: '',
      args: [],
    );
  }

  /// `متوسطة`
  String get medium {
    return Intl.message(
      'متوسطة',
      name: 'medium',
      desc: '',
      args: [],
    );
  }

  /// `منخفضة`
  String get low {
    return Intl.message(
      'منخفضة',
      name: 'low',
      desc: '',
      args: [],
    );
  }

  /// `معلق`
  String get pending {
    return Intl.message(
      'معلق',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `قيد التنفيذ`
  String get inProgress {
    return Intl.message(
      'قيد التنفيذ',
      name: 'inProgress',
      desc: '',
      args: [],
    );
  }

  /// `مكتمل`
  String get completed {
    return Intl.message(
      'مكتمل',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `ملغي`
  String get cancelled {
    return Intl.message(
      'ملغي',
      name: 'cancelled',
      desc: '',
      args: [],
    );
  }

  /// `أمر عمل جديد`
  String get newWorkOrder {
    return Intl.message(
      'أمر عمل جديد',
      name: 'newWorkOrder',
      desc: '',
      args: [],
    );
  }

  /// `تفاصيل أمر العمل`
  String get workOrderDetails {
    return Intl.message(
      'تفاصيل أمر العمل',
      name: 'workOrderDetails',
      desc: '',
      args: [],
    );
  }

  /// `اسم العميل`
  String get customerName {
    return Intl.message(
      'اسم العميل',
      name: 'customerName',
      desc: '',
      args: [],
    );
  }

  /// `معلومات المركبة`
  String get vehicleInfo {
    return Intl.message(
      'معلومات المركبة',
      name: 'vehicleInfo',
      desc: '',
      args: [],
    );
  }

  /// `نوع الخدمة`
  String get serviceType {
    return Intl.message(
      'نوع الخدمة',
      name: 'serviceType',
      desc: '',
      args: [],
    );
  }

  /// `التكلفة المقدرة`
  String get estimatedCost {
    return Intl.message(
      'التكلفة المقدرة',
      name: 'estimatedCost',
      desc: '',
      args: [],
    );
  }

  /// `التكلفة الفعلية`
  String get actualCost {
    return Intl.message(
      'التكلفة الفعلية',
      name: 'actualCost',
      desc: '',
      args: [],
    );
  }

  /// `تاريخ البداية`
  String get startDate {
    return Intl.message(
      'تاريخ البداية',
      name: 'startDate',
      desc: '',
      args: [],
    );
  }

  /// `تاريخ الانتهاء`
  String get endDate {
    return Intl.message(
      'تاريخ الانتهاء',
      name: 'endDate',
      desc: '',
      args: [],
    );
  }

  /// `الفني المكلف`
  String get assignedTechnician {
    return Intl.message(
      'الفني المكلف',
      name: 'assignedTechnician',
      desc: '',
      args: [],
    );
  }

  /// `القطع`
  String get parts {
    return Intl.message(
      'القطع',
      name: 'parts',
      desc: '',
      args: [],
    );
  }

  /// `العمالة`
  String get labor {
    return Intl.message(
      'العمالة',
      name: 'labor',
      desc: '',
      args: [],
    );
  }

  /// `المجموع`
  String get total {
    return Intl.message(
      'المجموع',
      name: 'total',
      desc: '',
      args: [],
    );
  }

  /// `الفاتورة`
  String get invoice {
    return Intl.message(
      'الفاتورة',
      name: 'invoice',
      desc: '',
      args: [],
    );
  }

  /// `الدفع`
  String get payment {
    return Intl.message(
      'الدفع',
      name: 'payment',
      desc: '',
      args: [],
    );
  }

  /// `مدفوع`
  String get paid {
    return Intl.message(
      'مدفوع',
      name: 'paid',
      desc: '',
      args: [],
    );
  }

  /// `غير مدفوع`
  String get unpaid {
    return Intl.message(
      'غير مدفوع',
      name: 'unpaid',
      desc: '',
      args: [],
    );
  }

  /// `مدفوع جزئياً`
  String get partiallyPaid {
    return Intl.message(
      'مدفوع جزئياً',
      name: 'partiallyPaid',
      desc: '',
      args: [],
    );
  }

  /// `عميل جديد`
  String get newCustomer {
    return Intl.message(
      'عميل جديد',
      name: 'newCustomer',
      desc: '',
      args: [],
    );
  }

  /// `تفاصيل العميل`
  String get customerDetails {
    return Intl.message(
      'تفاصيل العميل',
      name: 'customerDetails',
      desc: '',
      args: [],
    );
  }

  /// `الاسم الأول`
  String get firstName {
    return Intl.message(
      'الاسم الأول',
      name: 'firstName',
      desc: '',
      args: [],
    );
  }

  /// `الاسم الأخير`
  String get lastName {
    return Intl.message(
      'الاسم الأخير',
      name: 'lastName',
      desc: '',
      args: [],
    );
  }

  /// `الشركة`
  String get company {
    return Intl.message(
      'الشركة',
      name: 'company',
      desc: '',
      args: [],
    );
  }

  /// `المدينة`
  String get city {
    return Intl.message(
      'المدينة',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `البلد`
  String get country {
    return Intl.message(
      'البلد',
      name: 'country',
      desc: '',
      args: [],
    );
  }

  /// `مركبة جديدة`
  String get newVehicle {
    return Intl.message(
      'مركبة جديدة',
      name: 'newVehicle',
      desc: '',
      args: [],
    );
  }

  /// `تفاصيل المركبة`
  String get vehicleDetails {
    return Intl.message(
      'تفاصيل المركبة',
      name: 'vehicleDetails',
      desc: '',
      args: [],
    );
  }

  /// `الصانع`
  String get make {
    return Intl.message(
      'الصانع',
      name: 'make',
      desc: '',
      args: [],
    );
  }

  /// `الموديل`
  String get model {
    return Intl.message(
      'الموديل',
      name: 'model',
      desc: '',
      args: [],
    );
  }

  /// `السنة`
  String get year {
    return Intl.message(
      'السنة',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `اللون`
  String get color {
    return Intl.message(
      'اللون',
      name: 'color',
      desc: '',
      args: [],
    );
  }

  /// `رقم اللوحة`
  String get plateNumber {
    return Intl.message(
      'رقم اللوحة',
      name: 'plateNumber',
      desc: '',
      args: [],
    );
  }

  /// `رقم الهيكل`
  String get vin {
    return Intl.message(
      'رقم الهيكل',
      name: 'vin',
      desc: '',
      args: [],
    );
  }

  /// `المسافة المقطوعة`
  String get mileage {
    return Intl.message(
      'المسافة المقطوعة',
      name: 'mileage',
      desc: '',
      args: [],
    );
  }

  /// `نوع الوقود`
  String get fuelType {
    return Intl.message(
      'نوع الوقود',
      name: 'fuelType',
      desc: '',
      args: [],
    );
  }

  /// `بنزين`
  String get gasoline {
    return Intl.message(
      'بنزين',
      name: 'gasoline',
      desc: '',
      args: [],
    );
  }

  /// `ديزل`
  String get diesel {
    return Intl.message(
      'ديزل',
      name: 'diesel',
      desc: '',
      args: [],
    );
  }

  /// `كهربائي`
  String get electric {
    return Intl.message(
      'كهربائي',
      name: 'electric',
      desc: '',
      args: [],
    );
  }

  /// `هجين`
  String get hybrid {
    return Intl.message(
      'هجين',
      name: 'hybrid',
      desc: '',
      args: [],
    );
  }

  /// `الرسائل`
  String get messages {
    return Intl.message(
      'الرسائل',
      name: 'messages',
      desc: '',
      args: [],
    );
  }

  /// `إرسال رسالة`
  String get sendMessage {
    return Intl.message(
      'إرسال رسالة',
      name: 'sendMessage',
      desc: '',
      args: [],
    );
  }

  /// `اكتب رسالة...`
  String get typeMessage {
    return Intl.message(
      'اكتب رسالة...',
      name: 'typeMessage',
      desc: '',
      args: [],
    );
  }

  /// `متصل`
  String get online {
    return Intl.message(
      'متصل',
      name: 'online',
      desc: '',
      args: [],
    );
  }

  /// `غير متصل`
  String get offline {
    return Intl.message(
      'غير متصل',
      name: 'offline',
      desc: '',
      args: [],
    );
  }

  /// `آخر ظهور`
  String get lastSeen {
    return Intl.message(
      'آخر ظهور',
      name: 'lastSeen',
      desc: '',
      args: [],
    );
  }

  /// `اللغة`
  String get language {
    return Intl.message(
      'اللغة',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `العربية`
  String get arabic {
    return Intl.message(
      'العربية',
      name: 'arabic',
      desc: '',
      args: [],
    );
  }

  /// `الإنجليزية`
  String get english {
    return Intl.message(
      'الإنجليزية',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `المظهر`
  String get theme {
    return Intl.message(
      'المظهر',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `فاتح`
  String get light {
    return Intl.message(
      'فاتح',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `داكن`
  String get dark {
    return Intl.message(
      'داكن',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `النظام`
  String get system {
    return Intl.message(
      'النظام',
      name: 'system',
      desc: '',
      args: [],
    );
  }

  /// `حول التطبيق`
  String get about {
    return Intl.message(
      'حول التطبيق',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `الإصدار`
  String get version {
    return Intl.message(
      'الإصدار',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `اتصل بنا`
  String get contactUs {
    return Intl.message(
      'اتصل بنا',
      name: 'contactUs',
      desc: '',
      args: [],
    );
  }

  /// `سياسة الخصوصية`
  String get privacyPolicy {
    return Intl.message(
      'سياسة الخصوصية',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `شروط الخدمة`
  String get termsOfService {
    return Intl.message(
      'شروط الخدمة',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// `تغيير كلمة المرور`
  String get changePassword {
    return Intl.message(
      'تغيير كلمة المرور',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `كلمة المرور الحالية`
  String get currentPassword {
    return Intl.message(
      'كلمة المرور الحالية',
      name: 'currentPassword',
      desc: '',
      args: [],
    );
  }

  /// `كلمة المرور الجديدة`
  String get newPassword {
    return Intl.message(
      'كلمة المرور الجديدة',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد كلمة المرور`
  String get confirmPassword {
    return Intl.message(
      'تأكيد كلمة المرور',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `تحديث الملف الشخصي`
  String get updateProfile {
    return Intl.message(
      'تحديث الملف الشخصي',
      name: 'updateProfile',
      desc: '',
      args: [],
    );
  }

  /// `التقارير`
  String get reports {
    return Intl.message(
      'التقارير',
      name: 'reports',
      desc: '',
      args: [],
    );
  }

  /// `اعرض مقاييس عملك وتقارير الأداء.`
  String get reportsPagePlaceholder {
    return Intl.message(
      'اعرض مقاييس عملك وتقارير الأداء.',
      name: 'reportsPagePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `التحليلات`
  String get analytics {
    return Intl.message(
      'التحليلات',
      name: 'analytics',
      desc: '',
      args: [],
    );
  }

  /// `التقرير اليومي`
  String get dailyReport {
    return Intl.message(
      'التقرير اليومي',
      name: 'dailyReport',
      desc: '',
      args: [],
    );
  }

  /// `التقرير الأسبوعي`
  String get weeklyReport {
    return Intl.message(
      'التقرير الأسبوعي',
      name: 'weeklyReport',
      desc: '',
      args: [],
    );
  }

  /// `التقرير الشهري`
  String get monthlyReport {
    return Intl.message(
      'التقرير الشهري',
      name: 'monthlyReport',
      desc: '',
      args: [],
    );
  }

  /// `التقرير السنوي`
  String get yearlyReport {
    return Intl.message(
      'التقرير السنوي',
      name: 'yearlyReport',
      desc: '',
      args: [],
    );
  }

  /// `الإيرادات`
  String get revenue {
    return Intl.message(
      'الإيرادات',
      name: 'revenue',
      desc: '',
      args: [],
    );
  }

  /// `المصروفات`
  String get expenses {
    return Intl.message(
      'المصروفات',
      name: 'expenses',
      desc: '',
      args: [],
    );
  }

  /// `الربح`
  String get profit {
    return Intl.message(
      'الربح',
      name: 'profit',
      desc: '',
      args: [],
    );
  }

  /// `الخسارة`
  String get loss {
    return Intl.message(
      'الخسارة',
      name: 'loss',
      desc: '',
      args: [],
    );
  }

  /// `إجمالي أوامر العمل`
  String get totalWorkOrders {
    return Intl.message(
      'إجمالي أوامر العمل',
      name: 'totalWorkOrders',
      desc: '',
      args: [],
    );
  }

  /// `أوامر العمل المكتملة`
  String get completedWorkOrders {
    return Intl.message(
      'أوامر العمل المكتملة',
      name: 'completedWorkOrders',
      desc: '',
      args: [],
    );
  }

  /// `أوامر العمل المعلقة`
  String get pendingWorkOrders {
    return Intl.message(
      'أوامر العمل المعلقة',
      name: 'pendingWorkOrders',
      desc: '',
      args: [],
    );
  }

  /// `إجمالي العملاء`
  String get totalCustomers {
    return Intl.message(
      'إجمالي العملاء',
      name: 'totalCustomers',
      desc: '',
      args: [],
    );
  }

  /// `العملاء النشطون`
  String get activeCustomers {
    return Intl.message(
      'العملاء النشطون',
      name: 'activeCustomers',
      desc: '',
      args: [],
    );
  }

  /// `العملاء الجدد هذا الشهر`
  String get newCustomersThisMonth {
    return Intl.message(
      'العملاء الجدد هذا الشهر',
      name: 'newCustomersThisMonth',
      desc: '',
      args: [],
    );
  }

  /// `المساعد الذكي`
  String get aiAssistant {
    return Intl.message(
      'المساعد الذكي',
      name: 'aiAssistant',
      desc: '',
      args: [],
    );
  }

  /// `اسأل الذكاء الاصطناعي`
  String get askAI {
    return Intl.message(
      'اسأل الذكاء الاصطناعي',
      name: 'askAI',
      desc: '',
      args: [],
    );
  }

  /// `اقتراحات الذكاء الاصطناعي`
  String get aiSuggestions {
    return Intl.message(
      'اقتراحات الذكاء الاصطناعي',
      name: 'aiSuggestions',
      desc: '',
      args: [],
    );
  }

  /// `التشخيص`
  String get diagnostics {
    return Intl.message(
      'التشخيص',
      name: 'diagnostics',
      desc: '',
      args: [],
    );
  }

  /// `التوصيات`
  String get recommendations {
    return Intl.message(
      'التوصيات',
      name: 'recommendations',
      desc: '',
      args: [],
    );
  }

  /// `الصيانة`
  String get maintenance {
    return Intl.message(
      'الصيانة',
      name: 'maintenance',
      desc: '',
      args: [],
    );
  }

  /// `الإصلاح`
  String get repair {
    return Intl.message(
      'الإصلاح',
      name: 'repair',
      desc: '',
      args: [],
    );
  }

  /// `الفحص`
  String get inspection {
    return Intl.message(
      'الفحص',
      name: 'inspection',
      desc: '',
      args: [],
    );
  }

  /// `تغيير الزيت`
  String get oilChange {
    return Intl.message(
      'تغيير الزيت',
      name: 'oilChange',
      desc: '',
      args: [],
    );
  }

  /// `خدمة الفرامل`
  String get brakeService {
    return Intl.message(
      'خدمة الفرامل',
      name: 'brakeService',
      desc: '',
      args: [],
    );
  }

  /// `خدمة الإطارات`
  String get tireService {
    return Intl.message(
      'خدمة الإطارات',
      name: 'tireService',
      desc: '',
      args: [],
    );
  }

  /// `خدمة المحرك`
  String get engineService {
    return Intl.message(
      'خدمة المحرك',
      name: 'engineService',
      desc: '',
      args: [],
    );
  }

  /// `خدمة ناقل الحركة`
  String get transmissionService {
    return Intl.message(
      'خدمة ناقل الحركة',
      name: 'transmissionService',
      desc: '',
      args: [],
    );
  }

  /// `الخدمة الكهربائية`
  String get electricalService {
    return Intl.message(
      'الخدمة الكهربائية',
      name: 'electricalService',
      desc: '',
      args: [],
    );
  }

  /// `خدمة التكييف`
  String get airConditioningService {
    return Intl.message(
      'خدمة التكييف',
      name: 'airConditioningService',
      desc: '',
      args: [],
    );
  }

  /// `أعمال الهيكل`
  String get bodyWork {
    return Intl.message(
      'أعمال الهيكل',
      name: 'bodyWork',
      desc: '',
      args: [],
    );
  }

  /// `الدهان`
  String get painting {
    return Intl.message(
      'الدهان',
      name: 'painting',
      desc: '',
      args: [],
    );
  }

  /// `التنظيف التفصيلي`
  String get detailing {
    return Intl.message(
      'التنظيف التفصيلي',
      name: 'detailing',
      desc: '',
      args: [],
    );
  }

  /// `عرض الكل`
  String get viewAll {
    return Intl.message(
      'عرض الكل',
      name: 'viewAll',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
