import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_dropdown.dart';

class ServicesManagementPage extends ConsumerStatefulWidget {
  const ServicesManagementPage({super.key});

  @override
  ConsumerState<ServicesManagementPage> createState() =>
      _ServicesManagementPageState();
}

class _ServicesManagementPageState
    extends ConsumerState<ServicesManagementPage> {
  // Dialog controllers - prevent memory leaks
  late final TextEditingController _addNameController;
  late final TextEditingController _addDescriptionController;
  late final TextEditingController _addDurationController;
  late final TextEditingController _addCostController;
  late final TextEditingController _editNameController;
  late final TextEditingController _editDescriptionController;
  late final TextEditingController _editDurationController;
  late final TextEditingController _editCostController;

  @override
  void initState() {
    super.initState();
    // Initialize dialog controllers
    _addNameController = TextEditingController();
    _addDescriptionController = TextEditingController();
    _addDurationController = TextEditingController();
    _addCostController = TextEditingController();
    _editNameController = TextEditingController();
    _editDescriptionController = TextEditingController();
    _editDurationController = TextEditingController();
    _editCostController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose all dialog controllers
    _addNameController.dispose();
    _addDescriptionController.dispose();
    _addDurationController.dispose();
    _addCostController.dispose();
    _editNameController.dispose();
    _editDescriptionController.dispose();
    _editDurationController.dispose();
    _editCostController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _services = [
    {
      'id': 1,
      'name': 'تغيير زيت المحرك',
      'description': 'استبدال زيت المحرك بزيت جديد عالي الجودة',
      'category': 'ميكانيكا',
      'duration': 30,
      'cost': 50.00,
    },
    {
      'id': 2,
      'name': 'فحص الفرامل',
      'description': 'فحص شامل لنظام الفرامل والتأكد من سلامته',
      'category': 'ميكانيكا',
      'duration': 45,
      'cost': 75.00,
    },
    {
      'id': 3,
      'name': 'استبدال البطارية',
      'description': 'تركيب بطارية جديدة للسيارة',
      'category': 'كهرباء',
      'duration': 20,
      'cost': 120.00,
    },
  ];

  final List<String> _categories = [
    'ميكانيكا',
    'كهرباء',
    'هيكل',
    'دهان',
    'تنظيف',
  ];

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الخدمات'),
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
          onPressed: () => _showAddServiceDialog(),
          child: const Icon(Icons.add, color: AppTheme.primaryWhite),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'قائمة الخدمات المتاحة',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return _buildServiceCard(service, context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: AppTheme.primaryGreen, width: 4),
          ),
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
                        Text(
                          service['name'],
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkGray,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service['description'],
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.darkGray.withValues(alpha: 0.7),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.infoBlue),
                        onPressed: () =>
                            _showEditServiceDialog(service, context),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppTheme.errorRed,
                        ),
                        onPressed: () => _showDeleteConfirmation(service),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip('التصنيف: ${service['category']}'),
                  _buildInfoChip('المدة: ${service['duration']} دقيقة'),
                  _buildInfoChip(
                    'السعر: \$${service['cost'].toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.lightGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightGreen),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.primaryGreen,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAddServiceDialog() {
    // ✅ FIXED: Use class-level controllers instead of creating new ones
    _addNameController.clear();
    _addDescriptionController.clear();
    _addDurationController.clear();
    _addCostController.clear();
    String selectedCategory = _categories.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة خدمة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _addNameController,
                labelText: 'اسم الخدمة',
                hintText: 'أدخل اسم الخدمة',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addDescriptionController,
                labelText: 'الوصف',
                hintText: 'أدخل وصف الخدمة',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              CustomDropdown(
                labelText: 'التصنيف',
                hintText: 'اختر التصنيف',
                value: selectedCategory,
                items: _categories,
                onChanged: (value) => selectedCategory = value!,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addDurationController,
                labelText: 'المدة (بالدقائق)',
                hintText: 'أدخل المدة المتوقعة',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addCostController,
                labelText: 'السعر',
                hintText: 'أدخل السعر',
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
              if (_addNameController.text.isNotEmpty &&
                  _addDescriptionController.text.isNotEmpty) {
                setState(() {
                  _services.add({
                    'id': _services.length + 1,
                    'name': _addNameController.text,
                    'description': _addDescriptionController.text,
                    'category': selectedCategory,
                    'duration': int.tryParse(_addDurationController.text) ?? 0,
                    'cost': double.tryParse(_addCostController.text) ?? 0.0,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إضافة الخدمة بنجاح')),
                );
              }
            },
            child: const Text(
              'إضافة',
              style: TextStyle(color: AppTheme.primaryWhite),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(
    Map<String, dynamic> service,
    BuildContext context,
  ) {
    // ✅ FIXED: Use class-level controllers instead of creating new ones
    _editNameController.text = service['name'];
    _editDescriptionController.text = service['description'];
    _editDurationController.text = service['duration'].toString();
    _editCostController.text = service['cost'].toString();
    String selectedCategory = service['category'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الخدمة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _editNameController,
                labelText: 'اسم الخدمة',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _editDescriptionController,
                labelText: 'الوصف',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              CustomDropdown(
                labelText: 'التصنيف',
                hintText: 'اختر التصنيف',
                value: selectedCategory,
                items: _categories,
                onChanged: (value) => selectedCategory = value!,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _editDurationController,
                labelText: 'المدة (بالدقائق)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _editCostController,
                labelText: 'السعر',
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
                service['name'] = _editNameController.text;
                service['description'] = _editDescriptionController.text;
                service['category'] = selectedCategory;
                service['duration'] =
                    int.tryParse(_editDurationController.text) ?? 0;
                service['cost'] =
                    double.tryParse(_editCostController.text) ?? 0.0;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث الخدمة بنجاح')),
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

  void _showDeleteConfirmation(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الخدمة'),
        content: Text('هل أنت متأكد من حذف خدمة "${service['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () {
              setState(() {
                _services.removeWhere((s) => s['id'] == service['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الخدمة بنجاح')),
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
