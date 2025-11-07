import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../generated/l10n.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../../../core/themes/app_theme.dart';

class EnhancedInspectionPage extends ConsumerStatefulWidget {
  const EnhancedInspectionPage({super.key});

  @override
  ConsumerState<EnhancedInspectionPage> createState() =>
      _EnhancedInspectionPageState();
}

class _EnhancedInspectionPageState
    extends ConsumerState<EnhancedInspectionPage> {
  late PageController _pageController;
  int _currentStep = 0;

  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _vehicleVinController = TextEditingController();
  final _vehicleLicensePlateController = TextEditingController();
  final _vehicleMileageController = TextEditingController();
  final _customerComplaintController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedVehicleMake;
  String? _selectedInspectionType;

  final List<File> _attachedFiles = [];
  final List<String> _faults = [];
  final List<Map<String, dynamic>> _services = [];

  final List<String> _vehicleMakes = [
    'Toyota',
    'Honda',
    'Ford',
    'Chevrolet',
    'BMW',
    'Mercedes-Benz',
    'Nissan',
    'Hyundai',
    'Kia',
    'Mazda'
  ];

  final List<String> _inspectionTypes = ['فحص قياسي', 'فحص مخصص'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _vehicleVinController.dispose();
    _vehicleLicensePlateController.dispose();
    _vehicleMileageController.dispose();
    _customerComplaintController.dispose();
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _attachedFiles.addAll(result.paths.map((path) => File(path!)));
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _attachedFiles.add(File(pickedFile.path));
      });
    }
  }

  void _addFault() {
    showDialog(
      context: context,
      builder: (context) {
        String faultCategory = 'ميكانيكي';
        String faultDescription = '';
        String severity = 'متوسط';

        return AlertDialog(
          title: const Text('إضافة عيب'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomDropdown(
                  labelText: 'فئة العيب',
                  hintText: 'اختر فئة العيب',
                  value: faultCategory,
                  items: const [
                    'ميكانيكي',
                    'كهربائي',
                    'هيكل',
                    'دهان',
                    'داخلي',
                    'تعليق',
                    'محرك'
                  ],
                  onChanged: (value) {
                    setState(() => faultCategory = value!);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'وصف العيب'),
                  onChanged: (value) => faultDescription = value,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                CustomDropdown(
                  labelText: 'درجة الخطورة',
                  hintText: 'اختر درجة الخطورة',
                  value: severity,
                  items: const ['منخفض', 'متوسط', 'عالي', 'حرج'],
                  onChanged: (value) {
                    setState(() => severity = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _faults.add('$faultCategory - $faultDescription ($severity)');
                });
                Navigator.pop(context);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _addService() {
    showDialog(
      context: context,
      builder: (context) {
        String serviceName = '';
        String engineerId = '';
        double estimatedCost = 0;

        return AlertDialog(
          title: const Text('إضافة خدمة'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'اسم الخدمة'),
                  onChanged: (value) => serviceName = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'معرف المهندس'),
                  onChanged: (value) => engineerId = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'التكلفة المقدرة'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      estimatedCost = double.tryParse(value) ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _services.add({
                    'name': serviceName,
                    'engineer_id': engineerId,
                    'cost': estimatedCost,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('معلومات العميل'),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _customerNameController,
            labelText: S.of(context).email,
            hintText: 'أدخل اسم العميل',
            validator: (value) =>
                (value?.isEmpty ?? true) ? 'اسم العميل مطلوب' : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _customerPhoneController,
            labelText: 'رقم الهاتف',
            hintText: 'أدخل رقم الهاتف',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _customerEmailController,
            labelText: S.of(context).email,
            hintText: 'أدخل البريد الإلكتروني',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('معلومات المركبة'),
          const SizedBox(height: 16),
          CustomDropdown(
            labelText: 'ماركة المركبة',
            hintText: 'اختر ماركة المركبة',
            value: _selectedVehicleMake,
            items: _vehicleMakes,
            onChanged: (value) {
              setState(() => _selectedVehicleMake = value);
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _vehicleVinController,
            labelText: 'رقم الهيكل (VIN)',
            hintText: 'أدخل رقم الهيكل',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _vehicleLicensePlateController,
            labelText: 'رقم اللوحة',
            hintText: 'أدخل رقم اللوحة',
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('نوع الفحص'),
          const SizedBox(height: 16),
          CustomDropdown(
            labelText: 'نوع الفحص',
            hintText: 'اختر نوع الفحص',
            value: _selectedInspectionType,
            items: _inspectionTypes,
            onChanged: (value) {
              setState(() => _selectedInspectionType = value);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('شكوى العميل'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerComplaintController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'أوصف المشكلة',
              hintText: 'أدخل وصف المشكلة التي يشتكي منها العميل',
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('المرفقات'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('التقط صورة'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('إرفق ملف'),
                ),
              ),
            ],
          ),
          if (_attachedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _attachedFiles.map((file) {
                return Chip(
                  label: Text(file.path.split('/').last),
                  onDeleted: () {
                    setState(() => _attachedFiles.remove(file));
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('العيوب المكتشفة'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addFault,
            icon: const Icon(Icons.add),
            label: const Text('إضافة عيب'),
          ),
          if (_faults.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._faults.map((fault) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(fault),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() => _faults.remove(fault));
                      },
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 24),
          _buildSectionHeader('الخدمات المقترحة'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addService,
            icon: const Icon(Icons.add),
            label: const Text('إضافة خدمة'),
          ),
          if (_services.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._services.map((service) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(service['name']),
                    subtitle: Text('${service['cost']} ريال'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() => _services.remove(service));
                      },
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ملخص الفحص'),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'العميل',
            '${_customerNameController.text}\n${_customerPhoneController.text}',
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'المركبة',
            '$_selectedVehicleMake\n${_vehicleVinController.text}',
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'عدد العيوب',
            _faults.length.toString(),
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'عدد الخدمات',
            _services.length.toString(),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ملاحظات إضافية',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('فحص جديد'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            if (_currentStep > 0)
              TextButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child:
                    const Text('رجوع', style: TextStyle(color: Colors.white)),
              ),
            const SizedBox(width: 8),
            if (_currentStep < 3)
              TextButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child:
                    const Text('التالي', style: TextStyle(color: Colors.white)),
              )
            else
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حفظ الفحص بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child:
                    const Text('إكمال', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index <= _currentStep
                                ? AppTheme.primaryGreen
                                : AppTheme.lightGray,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: index <= _currentStep
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (index < 3)
                          Container(
                            height: 2,
                            color: index < _currentStep
                                ? AppTheme.primaryGreen
                                : AppTheme.lightGray,
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
