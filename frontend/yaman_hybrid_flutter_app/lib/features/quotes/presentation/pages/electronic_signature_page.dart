import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class ElectronicSignaturePage extends ConsumerStatefulWidget {
  final int quoteId;
  final String quoteNumber;
  final double totalAmount;
  final List<Map<String, dynamic>> items;

  const ElectronicSignaturePage({
    super.key,
    required this.quoteId,
    required this.quoteNumber,
    required this.totalAmount,
    required this.items,
  });

  @override
  ConsumerState<ElectronicSignaturePage> createState() =>
      _ElectronicSignaturePageState();
}

class _ElectronicSignaturePageState
    extends ConsumerState<ElectronicSignaturePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _acceptTerms = false;
  bool _isSubmitting = false;
  File? _pickedSignatureImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('توقيع إلكتروني'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote Summary
                _buildQuoteSummary(),

                const SizedBox(height: 24),

                // Personal Information
                _buildSectionHeader('المعلومات الشخصية'),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _nameController,
                  labelText: 'الاسم الكامل',
                  hintText: 'أدخل اسمك الكامل كما هو مسجل',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'الاسم الكامل مطلوب';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                CustomTextField(
                  controller: _emailController,
                  labelText: 'البريد الإلكتروني',
                  hintText: 'أدخل بريدك الإلكتروني',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'البريد الإلكتروني مطلوب';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value!)) {
                      return 'يرجى إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                CustomTextField(
                  controller: _phoneController,
                  labelText: 'رقم الهاتف',
                  hintText: 'أدخل رقم هاتفك',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'رقم الهاتف مطلوب';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Terms and Conditions
                _buildTermsAndConditions(),

                const SizedBox(height: 24),

                // Signature Section
                _buildSectionHeader('التوقيع الإلكتروني'),
                const SizedBox(height: 16),

                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Signature(
                      controller: _signatureController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearSignature,
                        child: const Text('مسح التوقيع'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickSignature,
                        icon: const Icon(Icons.image),
                        label: const Text('رفع توقيع'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitSignature,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _acceptTerms ? null : Colors.grey,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('تأكيد التوقيع وإرسال العرض'),
                  ),
                ),

                const SizedBox(height: 16),

                // Legal Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'هذا التوقيع الإلكتروني له نفس القوة القانونية للتوقيع التقليدي وفقاً لقوانين الجمهورية اليمنية.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'ملخص العرض',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('رقم العرض: ${widget.quoteNumber}'),
          const SizedBox(height: 8),
          Text(
            'إجمالي المبلغ: ${widget.totalAmount.toStringAsFixed(0)} ريال يمني',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'الخدمات المشمولة:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ...widget.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Text('• '),
                  Expanded(child: Text(item['service_name'] ?? '')),
                  Text('${item['total_price']?.toStringAsFixed(0) ?? 0} ريال'),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الشروط والأحكام',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            '• أوافق على أن هذا التوقيع الإلكتروني ملزم قانونياً\n'
            '• أوافق على تنفيذ الخدمات المذكورة في العرض\n'
            '• أوافق على دفع المبلغ المحدد عند اكتمال العمل\n'
            '• أفهم أن الأسعار قد تتغير في حال اكتشاف أعطال إضافية\n'
            '• أوافق على سياسة الضمان والإرجاع للمركز',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'أقر بأنني قرأت ووافقت على جميع الشروط والأحكام',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearSignature() {
    _signatureController.clear();
  }

  Future<void> _pickSignature() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedSignatureImage = File(pickedFile.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحميل صورة التوقيع بنجاح')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الصورة: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitSignature() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى الموافقة على الشروط والأحكام')),
      );
      return;
    }

    final signatureData = await _signatureController.toPngBytes();
    if (signatureData == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('يرجى التوقيع أولاً')));
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user and quote repository
      final authState = ref.read(authProvider);
      final quoteRepository = ref.read(quoteRepositoryProvider);
      final currentUserId = authState.user?.id ?? 0;

      // Prepare signature data (either from drawn signature or picked image)
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final Uint8List? finalSignatureData = _pickedSignatureImage != null
          ? await _pickedSignatureImage!.readAsBytes()
          : signatureData;

      if (finalSignatureData == null || finalSignatureData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('بيانات التوقيع غير صحيحة')),
          );
        }
        return;
      }

      // Approve the quote using the API
      await quoteRepository.approveQuote(widget.quoteId, currentUserId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال التوقيع والموافقة على العرض بنجاح!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إرسال التوقيع: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
