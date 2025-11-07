import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class EnhancedSignaturePage extends ConsumerStatefulWidget {
  final int quoteId;
  final String customerName;
  final double totalAmount;
  final String currency;

  const EnhancedSignaturePage({
    required this.quoteId,
    required this.customerName,
    required this.totalAmount,
    required this.currency,
    super.key,
  });

  @override
  ConsumerState<EnhancedSignaturePage> createState() =>
      _EnhancedSignaturePageState();
}

class _EnhancedSignaturePageState extends ConsumerState<EnhancedSignaturePage> {
  late SignatureController _signatureController;
  final _signerNameController = TextEditingController();
  final _signerEmailController = TextEditingController();
  final _signerPhoneController = TextEditingController();
  bool _agreeToTerms = false;
  bool _isApproved = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      onDrawStart: () {},
      onDrawEnd: () {},
    );
    _signerNameController.text = widget.customerName;
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _signerNameController.dispose();
    _signerEmailController.dispose();
    _signerPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_signerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إدخال اسم الموقّع'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب التوقيع في المربع المخصص'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _signatureController.toPngBytes();
      setState(() {
        _isApproved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التوقيع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearSignature() {
    _signatureController.clear();
    setState(() {
      _isApproved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التوقيع الإلكتروني'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuoteHeader(),
              const SizedBox(height: 24),
              _buildAgreementSection(),
              const SizedBox(height: 24),
              _buildSignerInfoSection(),
              const SizedBox(height: 24),
              _buildSignatureSection(),
              const SizedBox(height: 24),
              _buildTermsCheckbox(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ملخص العرض',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'عرض رقم: ${widget.quoteId}',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuoteRow(
              'اسم العميل',
              widget.customerName,
            ),
            const Divider(height: 12),
            _buildQuoteRow(
              'الإجمالي',
              '${widget.totalAmount.toStringAsFixed(2)} ${widget.currency}',
              isBold: true,
              color: AppTheme.primaryGreen,
            ),
            const Divider(height: 12),
            _buildQuoteRow(
              'تاريخ الإنشاء',
              _formatDate(DateTime.now()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementSection() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'بمجرد التوقيع، ستوافق على شروط العرض',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'شروط العرض:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTermItem('صلاحية العرض 7 أيام من تاريخ الإرسال'),
            _buildTermItem('الدفع مقدماً قبل بدء العمل'),
            _buildTermItem('توفير ضمان على الخدمات المقدمة'),
            _buildTermItem('تطبيق الضريبة المضافة حسب النسبة المقررة'),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignerInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات الموقّع',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _signerNameController,
          labelText: 'اسم الموقّع',
          hintText: 'أدخل الاسم الكامل',
          validator: (value) => (value?.isEmpty ?? true) ? 'الاسم مطلوب' : null,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _signerEmailController,
          labelText: 'البريد الإلكتروني',
          hintText: 'أدخل البريد الإلكتروني',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _signerPhoneController,
          labelText: 'رقم الجوال',
          hintText: 'أدخل رقم الجوال',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التوقيع الإلكتروني',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.mediumGray,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Signature(
            controller: _signatureController,
            height: 200,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearSignature,
                icon: const Icon(Icons.clear),
                label: const Text('مسح'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveSignature,
                icon: const Icon(Icons.check),
                label: const Text('حفظ التوقيع'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        if (_isApproved) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تم حفظ التوقيع بنجاح',
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Card(
      color: Colors.amber.shade50,
      child: CheckboxListTile(
        value: _agreeToTerms,
        onChanged: (value) {
          setState(() => _agreeToTerms = value ?? false);
        },
        title: const Text(
          'أوافق على الشروط والأحكام وأصرح بتوقيعي الإلكتروني',
          style: TextStyle(fontSize: 14),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _agreeToTerms && _isApproved
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم الموافقة على العرض بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              disabledBackgroundColor: Colors.grey,
            ),
            child: const Text(
              'الموافقة والتوقيع',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('رفض العرض'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
