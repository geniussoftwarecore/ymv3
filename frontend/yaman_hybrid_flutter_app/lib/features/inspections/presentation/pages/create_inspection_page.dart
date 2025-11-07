import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/api/repositories/inspection_repository.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../domain/entities/inspection_entity.dart';

class CreateInspectionPage extends ConsumerStatefulWidget {
  const CreateInspectionPage({super.key});

  @override
  ConsumerState<CreateInspectionPage> createState() =>
      _CreateInspectionPageState();
}

class _CreateInspectionPageState extends ConsumerState<CreateInspectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _vehicleVinController = TextEditingController();
  final _vehicleLicensePlateController = TextEditingController();
  final _vehicleMileageController = TextEditingController();
  final _vehicleTrimController = TextEditingController();
  final _customerComplaintController = TextEditingController();

  InspectionType _inspectionType = InspectionType.standard;
  String? _selectedVehicleMake;
  String? _selectedVehicleColor;
  DateTime? _scheduledDate;

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
    'Mazda',
    'Mitsubishi',
    'Suzuki',
  ];

  final List<String> _vehicleColors = [
    'أبيض',
    'أسود',
    'رمادي',
    'أزرق',
    'أحمر',
    'أخضر',
    'أصفر',
    'برتقالي',
    'بني',
  ];

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _vehicleVinController.dispose();
    _vehicleLicensePlateController.dispose();
    _vehicleMileageController.dispose();
    _vehicleTrimController.dispose();
    _customerComplaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء فحص جديد'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            TextButton(
              onPressed: _saveInspection,
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information Section
                _buildSectionHeader('معلومات العميل'),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _customerNameController,
                  labelText: 'اسم العميل',
                  hintText: 'أدخل اسم العميل الكامل',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'اسم العميل مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _customerPhoneController,
                  labelText: 'رقم الهاتف',
                  hintText: 'أدخل رقم هاتف العميل',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _customerEmailController,
                  labelText: 'البريد الإلكتروني',
                  hintText: 'أدخل البريد الإلكتروني للعميل',
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 24),

                // Vehicle Information Section
                _buildSectionHeader('معلومات المركبة'),
                const SizedBox(height: 16),

                // Inspection Type
                _buildSectionSubHeader('نوع الفحص'),
                Row(
                  children: [
                    Expanded(
                      child: _buildInspectionTypeRadio(
                        title: 'فحص قياسي',
                        subtitle: 'مرفق واحد فقط',
                        value: InspectionType.standard,
                      ),
                    ),
                    Expanded(
                      child: _buildInspectionTypeRadio(
                        title: 'فحص مخصص',
                        subtitle: 'مرفقات متعددة',
                        value: InspectionType.custom,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Vehicle Make and Model
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown<String>(
                        labelText: 'ماركة المركبة',
                        hintText: 'اختر الماركة',
                        value: _selectedVehicleMake,
                        items: _vehicleMakes,
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleMake = value;
                            _vehicleModelController
                                .clear(); // Reset model when make changes
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _vehicleModelController,
                        labelText: 'موديل المركبة',
                        hintText: 'أدخل موديل المركبة',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Vehicle Year and Color
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _vehicleYearController,
                        labelText: 'سنة الصنع',
                        hintText: 'مثال: 2020',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomDropdown<String>(
                        labelText: 'لون المركبة',
                        hintText: 'اختر اللون',
                        value: _selectedVehicleColor,
                        items: _vehicleColors,
                        onChanged: (value) =>
                            setState(() => _selectedVehicleColor = value),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // VIN and License Plate
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _vehicleVinController,
                        labelText: 'رقم الهيكل (VIN)',
                        hintText: 'أدخل رقم الهيكل',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _vehicleLicensePlateController,
                        labelText: 'رقم اللوحة',
                        hintText: 'أدخل رقم لوحة المركبة',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Mileage and Trim
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _vehicleMileageController,
                        labelText: 'عدد الكيلومترات',
                        hintText: 'أدخل عدد الكيلومترات',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _vehicleTrimController,
                        labelText: 'مستوى التجهيز',
                        hintText: 'مثال: LE, EX, Luxury',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Inspection Details Section
                _buildSectionHeader('تفاصيل الفحص'),
                const SizedBox(height: 16),

                // Scheduled Date
                InkWell(
                  onTap: _selectScheduledDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الفحص المجدول',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _scheduledDate != null
                          ? DateFormat('yyyy/MM/dd').format(_scheduledDate!)
                          : 'اختر التاريخ',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Customer Complaint
                CustomTextField(
                  controller: _customerComplaintController,
                  labelText: 'شكوى العميل',
                  hintText: 'اكتب شكوى العميل أو المشكلة المذكورة',
                  maxLines: 3,
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveInspection,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('حفظ الفحص'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 2),
        ),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSectionSubHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildInspectionTypeRadio({
    required String title,
    required String subtitle,
    required InspectionType value,
  }) {
    final isSelected = _inspectionType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _inspectionType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectScheduledDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _scheduledDate = pickedDate;
      });
    }
  }

  void _saveInspection() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Get current user from auth state
        final authState = ref.read(authProvider);
        final currentUserId =
            authState.user?.id ?? 1; // Default to 1 if not available

        // Parse vehicle year from controller
        final vehicleYear = _vehicleYearController.text.isNotEmpty
            ? int.tryParse(_vehicleYearController.text)
            : null;

        // Create inspection request from form data
        final inspectionRequest = CreateInspectionRequest(
          customerId: currentUserId, // Using current user ID as customer ID
          vehicleTypeId: null,
          vehicleMake: _selectedVehicleMake,
          vehicleModel: _vehicleModelController.text.isNotEmpty
              ? _vehicleModelController.text
              : null,
          vehicleYear: vehicleYear,
          vehicleVin: _vehicleVinController.text.isNotEmpty
              ? _vehicleVinController.text
              : null,
          vehicleLicensePlate: _vehicleLicensePlateController.text.isNotEmpty
              ? _vehicleLicensePlateController.text
              : null,
          vehicleMileage: int.tryParse(_vehicleMileageController.text),
          vehicleColor: _selectedVehicleColor,
          vehicleTrim: _vehicleTrimController.text.isNotEmpty
              ? _vehicleTrimController.text
              : null,
          inspectionType: _inspectionType == InspectionType.standard
              ? 'Standard'
              : 'Custom',
          customerComplaint: _customerComplaintController.text.isNotEmpty
              ? _customerComplaintController.text
              : null,
          scheduledDate: _scheduledDate,
          createdBy: currentUserId,
        );

        // Call repository to save inspection
        final inspectionsNotifier = ref.read(inspectionsProvider.notifier);
        await inspectionsNotifier.createInspection(inspectionRequest);

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ الفحص بنجاح')));

        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ الفحص: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
