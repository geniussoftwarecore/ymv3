import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_dropdown.dart';

class EngineersManagementPage extends ConsumerStatefulWidget {
  const EngineersManagementPage({super.key});

  @override
  ConsumerState<EngineersManagementPage> createState() =>
      _EngineersManagementPageState();
}

class _EngineersManagementPageState
    extends ConsumerState<EngineersManagementPage> {
  // Dialog controllers - prevent memory leaks
  late final TextEditingController _addNameController;
  late final TextEditingController _addPhoneController;
  late final TextEditingController _addEmailController;
  late final TextEditingController _addMaxTasksController;
  late final TextEditingController _editNameController;
  late final TextEditingController _editPhoneController;
  late final TextEditingController _editEmailController;
  late final TextEditingController _editMaxTasksController;

  @override
  void initState() {
    super.initState();
    // Initialize dialog controllers
    _addNameController = TextEditingController();
    _addPhoneController = TextEditingController();
    _addEmailController = TextEditingController();
    _addMaxTasksController = TextEditingController(text: '5');
    _editNameController = TextEditingController();
    _editPhoneController = TextEditingController();
    _editEmailController = TextEditingController();
    _editMaxTasksController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose all dialog controllers
    _addNameController.dispose();
    _addPhoneController.dispose();
    _addEmailController.dispose();
    _addMaxTasksController.dispose();
    _editNameController.dispose();
    _editPhoneController.dispose();
    _editEmailController.dispose();
    _editMaxTasksController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _engineers = [
    {
      'id': 1,
      'name': 'أحمد محمد',
      'phone': '967701234567',
      'email': 'ahmed@workshop.com',
      'specialty': 'ميكانيكي',
      'status': 'متاح',
      'maxTasks': 5,
      'currentTasks': 2,
    },
    {
      'id': 2,
      'name': 'علي الحسن',
      'phone': '967702345678',
      'email': 'ali@workshop.com',
      'specialty': 'كهربائي',
      'status': 'مشغول',
      'maxTasks': 5,
      'currentTasks': 5,
    },
    {
      'id': 3,
      'name': 'محمود عبده',
      'phone': '967703456789',
      'email': 'mahmoud@workshop.com',
      'specialty': 'سمكري',
      'status': 'متاح',
      'maxTasks': 4,
      'currentTasks': 1,
    },
  ];

  final List<String> _specialties = [
    'ميكانيكي',
    'كهربائي',
    'سمكري',
    'دهان',
    'تنظيف',
  ];
  final List<String> _statuses = ['متاح', 'مشغول', 'إجازة'];

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المهندسين'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.primaryWhite,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primaryGreen,
          onPressed: () => _showAddEngineerDialog(),
          tooltip: 'إضافة مهندس جديد',
          child: const Icon(Icons.add, color: AppTheme.primaryWhite),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'قائمة المهندسين والفنيين',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _engineers.length,
                  itemBuilder: (context, index) {
                    final engineer = _engineers[index];
                    return _buildEngineerCard(engineer, context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEngineerCard(
    Map<String, dynamic> engineer,
    BuildContext context,
  ) {
    Color statusColor = engineer['status'] == 'متاح'
        ? AppTheme.successGreen
        : engineer['status'] == 'مشغول'
        ? AppTheme.warningOrange
        : AppTheme.errorRed;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: statusColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.primaryGreen.withValues(
                                alpha: 0.2,
                              ),
                              child: Text(
                                engineer['name'].substring(0, 2),
                                style: const TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    engineer['name'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.darkGray,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          engineer['specialty'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.primaryGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: statusColor,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              engineer['status'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: statusColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.infoBlue),
                        onPressed: () =>
                            _showEditEngineerDialog(engineer, context),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppTheme.errorRed,
                        ),
                        onPressed: () => _showDeleteConfirmation(engineer),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: AppTheme.mediumGray.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'البريد الإلكتروني',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.darkGray.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          engineer['email'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'رقم الهاتف',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.darkGray.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          engineer['phone'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'المهام الجارية',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.darkGray.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${engineer['currentTasks']}/${engineer['maxTasks']}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    engineer['currentTasks'] >=
                                        engineer['maxTasks']
                                    ? AppTheme.errorRed
                                    : AppTheme.successGreen,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: engineer['currentTasks'] / engineer['maxTasks'],
                  minHeight: 6,
                  backgroundColor: AppTheme.lightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    engineer['currentTasks'] >= engineer['maxTasks']
                        ? AppTheme.errorRed
                        : AppTheme.successGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEngineerDialog() {
    // ✅ FIXED: Use class-level controllers instead of creating new ones
    // Clear controllers for new input
    _addNameController.clear();
    _addPhoneController.clear();
    _addEmailController.clear();
    _addMaxTasksController.text = '5';
    String selectedSpecialty = _specialties.first;
    String selectedStatus = _statuses.first;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة مهندس جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Display
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                      border: Border.all(color: AppTheme.errorRed),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorRed,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.errorRed,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                CustomTextField(
                  controller: _addNameController,
                  labelText: 'اسم المهندس',
                  hintText: 'أدخل اسم المهندس',
                  enabled: errorMessage == null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _addPhoneController,
                  labelText: 'رقم الهاتف',
                  hintText: 'أدخل رقم الهاتف',
                  keyboardType: TextInputType.phone,
                  enabled: errorMessage == null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _addEmailController,
                  labelText: 'البريد الإلكتروني',
                  hintText: 'أدخل البريد الإلكتروني',
                  keyboardType: TextInputType.emailAddress,
                  enabled: errorMessage == null,
                ),
                const SizedBox(height: 12),
                CustomDropdown(
                  labelText: 'التخصص',
                  hintText: 'اختر التخصص',
                  value: selectedSpecialty,
                  items: _specialties,
                  onChanged: errorMessage == null
                      ? (value) => setState(
                          () => selectedSpecialty =
                              value?.toString() ?? selectedSpecialty,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                CustomDropdown(
                  labelText: 'الحالة',
                  hintText: 'اختر الحالة',
                  value: selectedStatus,
                  items: _statuses,
                  onChanged: errorMessage == null
                      ? (value) => setState(
                          () => selectedStatus =
                              value?.toString() ?? selectedStatus,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _addMaxTasksController,
                  labelText: 'الحد الأقصى للمهام',
                  hintText: 'أدخل الحد الأقصى',
                  keyboardType: TextInputType.number,
                  enabled: errorMessage == null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إغلاق',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            ),
            if (errorMessage != null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                onPressed: () {
                  setState(() {
                    errorMessage = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة محاولة'),
              )
            else ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                onPressed: () {
                  // Validation
                  if (_addNameController.text.isEmpty) {
                    setState(() {
                      errorMessage = 'يرجى إدخال اسم المهندس';
                    });
                    return;
                  }
                  if (_addPhoneController.text.isEmpty) {
                    setState(() {
                      errorMessage = 'يرجى إدخال رقم الهاتف';
                    });
                    return;
                  }
                  if (_addEmailController.text.isEmpty) {
                    setState(() {
                      errorMessage = 'يرجى إدخال البريد الإلكتروني';
                    });
                    return;
                  }

                  try {
                    setState(() {
                      _engineers.add({
                        'id': _engineers.length + 1,
                        'name': _addNameController.text,
                        'phone': _addPhoneController.text,
                        'email': _addEmailController.text,
                        'specialty': selectedSpecialty,
                        'status': selectedStatus,
                        'maxTasks':
                            int.tryParse(_addMaxTasksController.text) ?? 5,
                        'currentTasks': 0,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة المهندس بنجاح')),
                    );
                  } catch (e) {
                    setState(() {
                      errorMessage = 'فشل في إضافة المهندس: ${e.toString()}';
                    });
                  }
                },
                child: const Text(
                  'إضافة',
                  style: TextStyle(color: AppTheme.primaryWhite),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditEngineerDialog(
    Map<String, dynamic> engineer,
    BuildContext context,
  ) {
    // ✅ FIXED: Use class-level controllers instead of creating new ones
    _editNameController.text = engineer['name'];
    _editPhoneController.text = engineer['phone'];
    _editEmailController.text = engineer['email'];
    _editMaxTasksController.text = engineer['maxTasks'].toString();
    String selectedSpecialty = engineer['specialty'];
    String selectedStatus = engineer['status'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات المهندس'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _editNameController,
                labelText: 'اسم المهندس',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _editPhoneController,
                labelText: 'رقم الهاتف',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _editEmailController,
                labelText: 'البريد الإلكتروني',
              ),
              const SizedBox(height: 12),
              CustomDropdown(
                labelText: 'التخصص',
                hintText: 'اختر التخصص',
                value: selectedSpecialty,
                items: _specialties,
                onChanged: (value) => selectedSpecialty = value!,
              ),
              const SizedBox(height: 12),
              CustomDropdown(
                labelText: 'الحالة',
                hintText: 'اختر الحالة',
                value: selectedStatus,
                items: _statuses,
                onChanged: (value) => selectedStatus = value!,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _editMaxTasksController,
                labelText: 'الحد الأقصى للمهام',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            onPressed: () {
              setState(() {
                engineer['name'] = _editNameController.text;
                engineer['phone'] = _editPhoneController.text;
                engineer['email'] = _editEmailController.text;
                engineer['specialty'] = selectedSpecialty;
                engineer['status'] = selectedStatus;
                engineer['maxTasks'] =
                    int.tryParse(_editMaxTasksController.text) ?? 5;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
              );
            },
            child: const Text(
              'حفظ',
              style: TextStyle(color: AppTheme.primaryWhite),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> engineer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المهندس'),
        content: Text('هل أنت متأكد من حذف "${engineer['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () {
              setState(() {
                _engineers.removeWhere((e) => e['id'] == engineer['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف المهندس بنجاح')),
              );
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: AppTheme.primaryWhite),
            ),
          ),
        ],
      ),
    );
  }
}
