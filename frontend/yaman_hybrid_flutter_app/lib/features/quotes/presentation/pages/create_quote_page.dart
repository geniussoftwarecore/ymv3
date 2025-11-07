import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/api/repositories/quote_repository.dart' as qr;
import '../../../../shared/widgets/custom_text_field.dart';

class CreateQuotePage extends ConsumerStatefulWidget {
  final int inspectionId;
  final List<Map<String, dynamic>> inspectionServices;
  final Map<String, dynamic> customerInfo;
  final Map<String, dynamic> vehicleInfo;

  const CreateQuotePage({
    super.key,
    required this.inspectionId,
    required this.inspectionServices,
    required this.customerInfo,
    required this.vehicleInfo,
  });

  @override
  ConsumerState<CreateQuotePage> createState() => _CreateQuotePageState();
}

class _CreateQuotePageState extends ConsumerState<CreateQuotePage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _validityDaysController = TextEditingController(text: '7');

  late List<qr.QuoteItemModel> _quoteItems;
  double _totalAmount = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeQuoteItems();
  }

  void _initializeQuoteItems() {
    _quoteItems = widget.inspectionServices.map((service) {
      final unitPrice = (service['estimated_cost'] ?? 0.0).toDouble();
      const quantity = 1;
      final totalPrice = unitPrice * quantity;

      return qr.QuoteItemModel(
        quoteId: 0, // Will be set when creating quote
        serviceName: service['service_name'] ?? '',
        description: service['notes'] ?? '',
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        estimatedDuration: service['estimated_duration'],
        notes: service['notes'],
        createdAt: DateTime.now(),
      );
    }).toList();

    _calculateTotal();
  }

  void _calculateTotal() {
    _totalAmount = _quoteItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    setState(() {});
  }

  @override
  void dispose() {
    _notesController.dispose();
    _validityDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء عرض أسعار'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _submitQuote,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('إرسال العرض'),
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
                // Customer and Vehicle Info
                _buildCustomerVehicleInfo(),

                const SizedBox(height: 24),

                // Services List
                _buildServicesSection(),

                const SizedBox(height: 24),

                // Quote Settings
                _buildQuoteSettings(),

                const SizedBox(height: 24),

                // Total Amount
                _buildTotalSection(),

                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerVehicleInfo() {
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
              Icon(Icons.person, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'معلومات العميل والمركبة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'العميل: ${widget.customerInfo['name'] ?? 'غير محدد'}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الهاتف: ${widget.customerInfo['phone'] ?? 'غير محدد'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المركبة: ${widget.vehicleInfo['make'] ?? ''} ${widget.vehicleInfo['model'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اللوحة: ${widget.vehicleInfo['license_plate'] ?? 'غير محدد'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخدمات المطلوبة',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._quoteItems.map((item) => _buildServiceItem(item)),
      ],
    );
  }

  Widget _buildServiceItem(qr.QuoteItemModel item) {
    final index = _quoteItems.indexOf(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '${item.totalPrice.toStringAsFixed(0)} ريال',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          if (item.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(
              item.description!,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('الكمية: ', style: TextStyle(fontSize: 12)),
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 12),
                  onChanged: (value) {
                    final quantity = int.tryParse(value) ?? 1;
                    setState(() {
                      _quoteItems[index] = item.copyWith(
                        quantity: quantity,
                        totalPrice: item.unitPrice * quantity,
                      );
                      _calculateTotal();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'السعر الوحدي: ${item.unitPrice.toStringAsFixed(0)} ريال',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات العرض',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _validityDaysController,
                labelText: 'مدة الصلاحية (أيام)',
                hintText: '7',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'مطلوب';
                  }
                  final days = int.tryParse(value!);
                  if (days == null || days <= 0) {
                    return 'يجب أن تكون قيمة موجبة';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _notesController,
          labelText: 'ملاحظات إضافية',
          hintText: 'أي ملاحظات خاصة بالعرض...',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTotalSection() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إجمالي المبلغ:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_totalAmount.toStringAsFixed(0)} ريال يمني',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'الضريبة: 0 ريال (معفى)',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
            onPressed: _isSubmitting ? null : _submitQuote,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('إنشاء وإرسال العرض'),
          ),
        ),
      ],
    );
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_quoteItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إضافة خدمات على الأقل')),
      );
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

      // Prepare quote items for API
      final items = _quoteItems
          .map(
            (item) => {
              'service_name': item.serviceName,
              'description': item.description,
              'quantity': item.quantity,
              'unit_price': item.unitPrice,
              'total_price': item.totalPrice,
              'estimated_duration': item.estimatedDuration,
              'notes': item.notes,
            },
          )
          .toList();

      // Parse validity days
      final validityDays = int.tryParse(_validityDaysController.text) ?? 7;
      final validUntil = DateTime.now().add(Duration(days: validityDays));

      // Create quote request
      final quoteRequest = qr.CreateQuoteRequest(
        inspectionId: widget.inspectionId,
        customerId: widget.customerInfo['id'] ?? 0,
        items: items,
        totalAmount: _totalAmount,
        currency: 'YER',
        validUntil: validUntil,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdBy: currentUserId,
      );

      // Call API to create quote
      final createdQuote = await quoteRepository.createQuote(quoteRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء العرض ${createdQuote.quoteNumber} بنجاح!'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إنشاء العرض: ${e.toString()}')),
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
