import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../../core/providers/locale_provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../providers/inspection_providers.dart';
import '../../domain/entities/inspection_entity.dart';

class AddFaultPage extends ConsumerStatefulWidget {
  final int inspectionId;

  const AddFaultPage({super.key, required this.inspectionId});

  @override
  ConsumerState<AddFaultPage> createState() => _AddFaultPageState();
}

class _AddFaultPageState extends ConsumerState<AddFaultPage> {
  final _formKey = GlobalKey<FormState>();
  final _faultDescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedFaultCategory;
  String _selectedSeverity = 'Medium';
  final List<File> _selectedPhotos = [];
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _faultCategories = [
    'ميكانيكي',
    'كهربائي',
    'هيكل',
    'إطارات',
    'محرك',
    'ناقل حركة',
    'فرامل',
    'تكييف',
    'إضاءة',
    'زجاج',
    'داخلية',
    'أخرى'
  ];

  final List<String> _severityLevels = ['منخفض', 'متوسط', 'عالي', 'حرج'];

  @override
  void dispose() {
    _faultDescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة عيب جديد'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            TextButton(
              onPressed: _saveFault,
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
                // Fault Category
                CustomDropdown<String>(
                  labelText: 'فئة العيب',
                  hintText: 'اختر فئة العيب',
                  value: _selectedFaultCategory,
                  items: _faultCategories,
                  onChanged: (value) =>
                      setState(() => _selectedFaultCategory = value),
                  isRequired: true,
                ),

                const SizedBox(height: 16),

                // Severity Level
                CustomDropdown<String>(
                  labelText: 'درجة الخطورة',
                  hintText: 'اختر درجة الخطورة',
                  value: _selectedSeverity,
                  items: _severityLevels,
                  onChanged: (value) => setState(
                      () => _selectedSeverity = value ?? _selectedSeverity),
                ),

                const SizedBox(height: 16),

                // Fault Description
                CustomTextField(
                  controller: _faultDescriptionController,
                  labelText: 'وصف العيب',
                  hintText: 'اكتب وصفاً مفصلاً للعيب المكتشف',
                  maxLines: 4,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'وصف العيب مطلوب';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Additional Notes
                CustomTextField(
                  controller: _notesController,
                  labelText: 'ملاحظات إضافية',
                  hintText: 'أي ملاحظات إضافية حول العيب',
                  maxLines: 3,
                ),

                const SizedBox(height: 24),

                // Photos Section
                _buildSectionHeader('الصور'),
                const SizedBox(height: 16),

                // Selected Photos Grid
                if (_selectedPhotos.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _selectedPhotos.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedPhotos[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              onPressed: () => _removePhoto(index),
                              icon: const Icon(Icons.close, color: Colors.red),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.all(4),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 16),

                // Add Photo Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('كاميرا'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('معرض الصور'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
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
                        onPressed: _saveFault,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('حفظ العيب'),
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (!mounted) return;

      if (pickedFile != null) {
        setState(() {
          _selectedPhotos.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _saveFault() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedFaultCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار فئة العيب')),
        );
        return;
      }

      try {
        final repository = ref.read(inspectionRepositoryProvider);

        List<Map<String, dynamic>>? encodedPhotos;
        if (_selectedPhotos.isNotEmpty) {
          encodedPhotos = [];
          for (final photoFile in _selectedPhotos) {
            final bytes = await photoFile.readAsBytes();
            final base64String = base64Encode(bytes);
            encodedPhotos.add({
              'filename': photoFile.path.split('/').last,
              'data': base64String,
            });
          }
        }

        final fault = InspectionFaultEntity(
          inspectionId: widget.inspectionId,
          faultCategory: _selectedFaultCategory!,
          faultDescription: _faultDescriptionController.text,
          severity: _selectedSeverity,
          photos: encodedPhotos,
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
          createdAt: DateTime.now(),
        );

        await repository.addInspectionFault(widget.inspectionId, fault);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ العيب بنجاح')),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ العيب: $e')),
        );
      }
    }
  }
}
