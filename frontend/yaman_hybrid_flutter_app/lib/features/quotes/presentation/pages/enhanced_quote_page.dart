import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class EnhancedQuotePage extends ConsumerStatefulWidget {
  final int inspectionId;

  const EnhancedQuotePage({
    required this.inspectionId,
    super.key,
  });

  @override
  ConsumerState<EnhancedQuotePage> createState() => _EnhancedQuotePageState();
}

class _EnhancedQuotePageState extends ConsumerState<EnhancedQuotePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _quoteItems = [];
  final _notesController = TextEditingController();
  final _serviceName = TextEditingController();
  final _serviceDescription = TextEditingController();
  final _unitPrice = TextEditingController();
  final _quantity = TextEditingController(text: '1');

  String _quoteCurrency = 'YER';
  int _validDays = 7;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _notesController.dispose();
    _serviceName.dispose();
    _serviceDescription.dispose();
    _unitPrice.dispose();
    _quantity.dispose();
    super.dispose();
  }

  void _addQuoteItem() {
    if (_serviceName.text.isEmpty || _unitPrice.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    setState(() {
      _quoteItems.add({
        'id': _quoteItems.length + 1,
        'service_name': _serviceName.text,
        'description': _serviceDescription.text,
        'quantity': int.tryParse(_quantity.text) ?? 1,
        'unit_price': double.tryParse(_unitPrice.text) ?? 0,
        'total': (int.tryParse(_quantity.text) ?? 1) *
            (double.tryParse(_unitPrice.text) ?? 0),
      });
    });

    _serviceName.clear();
    _serviceDescription.clear();
    _unitPrice.clear();
    _quantity.text = '1';
  }

  double _calculateTotal() {
    return _quoteItems.fold(0, (sum, item) => sum + (item['total'] ?? 0));
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('إضافة عناصر عرض السعر'),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _serviceName,
            labelText: 'اسم الخدمة',
            hintText: 'مثال: تغيير زيت المحرك',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _serviceDescription,
            labelText: 'وصف الخدمة',
            hintText: 'أدخل وصف تفصيلي للخدمة',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _unitPrice,
                  labelText: 'سعر الوحدة',
                  hintText: '0.00',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _quantity,
                  labelText: 'الكمية',
                  hintText: '1',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addQuoteItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              'إضافة عنصر',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          if (_quoteItems.isNotEmpty) ...[
            _buildSectionHeader('عناصر العرض'),
            const SizedBox(height: 12),
            ..._quoteItems.asMap().entries.map((entry) {
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    title: Text(item['service_name']),
                    subtitle: Text(
                        '${item['quantity']} × ${item['unit_price']} = ${item['total']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => _quoteItems.removeAt(entry.key));
                      },
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final total = _calculateTotal();
    final tax = total * 0.15;
    final grandTotal = total + tax;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('مراجعة وإنهاء العرض'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الإجمالي الفرعي',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${total.toStringAsFixed(2)} $_quoteCurrency',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الضريبة (15%)',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${tax.toStringAsFixed(2)} $_quoteCurrency',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الإجمالي النهائي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      Text(
                        '${grandTotal.toStringAsFixed(2)} $_quoteCurrency',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('معلومات إضافية'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'صلاحية العرض (أيام)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: _validDays,
                      isExpanded: true,
                      items: [3, 7, 14, 30].map((days) {
                        return DropdownMenuItem(
                          value: days,
                          child: Text('$days أيام'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _validDays = value ?? 7);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'العملة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _quoteCurrency,
                      isExpanded: true,
                      items: ['YER', 'USD', 'SAR', 'AED'].map((curr) {
                        return DropdownMenuItem(
                          value: curr,
                          child: Text(curr),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _quoteCurrency = value ?? 'YER');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ملاحظات إضافية',
              hintText: 'أضف أي ملاحظات أو شروط خاصة',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حفظ العرض كمسودة'),
                      ),
                    );
                  },
                  child: const Text('حفظ كمسودة'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
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
          _buildSectionHeader('إرسال العرض'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.successGreen,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'العرض جاهز للإرسال',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الإجمالي: ${_calculateTotal().toStringAsFixed(2)} $_quoteCurrency',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('اختر طريقة الإرسال'),
          const SizedBox(height: 16),
          _buildSendOption(
            icon: Icons.email,
            title: 'إرسال عبر البريد الإلكتروني',
            description: 'سيتم إرسال العرض إلى بريد العميل',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال العرض عبر البريد بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSendOption(
            icon: Icons.chat_bubble,
            title: 'إرسال عبر واتساب',
            description: 'سيتم إرسال رابط العرض عبر واتساب',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال العرض عبر واتساب بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSendOption(
            icon: Icons.print,
            title: 'طباعة العرض',
            description: 'اطبع العرض وسلمه للعميل مباشرة',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إعداد العرض للطباعة'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSendOption(
            icon: Icons.qr_code,
            title: 'إنشاء رابط قابل للمشاركة',
            description: 'شارك رابط العرض مع العميل',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ الرابط إلى الحافظة'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSendOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
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
          title: const Text('إنشاء عرض سعر'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(3, (index) {
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
                        if (index < 2)
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
