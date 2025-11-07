import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';

class FinalInspectionPage extends ConsumerStatefulWidget {
  final int workOrderId;
  final String workOrderNumber;

  const FinalInspectionPage({
    required this.workOrderId,
    required this.workOrderNumber,
    super.key,
  });

  @override
  ConsumerState<FinalInspectionPage> createState() =>
      _FinalInspectionPageState();
}

class _FinalInspectionPageState extends ConsumerState<FinalInspectionPage> {
  late List<Map<String, dynamic>> _checklistItems;
  final _assessmentController = TextEditingController();
  final _notesController = TextEditingController();
  int _completedTasksCount = 0;
  final int _totalTasksCount = 3;

  @override
  void initState() {
    super.initState();
    _loadChecklistItems();
  }

  void _loadChecklistItems() {
    setState(() {
      _checklistItems = [
        {
          'id': 1,
          'item_name': 'جودة الإصلاح - المحرك',
          'is_passed': false,
          'notes': '',
        },
        {
          'id': 2,
          'item_name': 'جودة الإصلاح - الفرامل',
          'is_passed': false,
          'notes': '',
        },
        {
          'id': 3,
          'item_name': 'جودة الإصلاح - الكهرباء',
          'is_passed': false,
          'notes': '',
        },
        {
          'id': 4,
          'item_name': 'نظافة السيارة',
          'is_passed': false,
          'notes': '',
        },
        {
          'id': 5,
          'item_name': 'اختبار التشغيل',
          'is_passed': false,
          'notes': '',
        },
        {
          'id': 6,
          'item_name': 'المظهر الخارجي',
          'is_passed': false,
          'notes': '',
        },
        {
          'id': 7,
          'item_name': 'الملفات والوثائق',
          'is_passed': false,
          'notes': '',
        },
      ];
      _completedTasksCount = 3;
    });
  }

  @override
  void dispose() {
    _assessmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _areAllItemsPassed() {
    return _checklistItems.every((item) => item['is_passed'] == true);
  }

  int _getPassedCount() {
    return _checklistItems.where((item) => item['is_passed'] == true).length;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الفحص النهائي: ${widget.workOrderNumber}'),
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
              _buildWorkOrderSummary(),
              const SizedBox(height: 24),
              _buildChecklistSection(),
              const SizedBox(height: 24),
              _buildAssessmentSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkOrderSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص أمر العمل',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('رقم أمر العمل', widget.workOrderNumber),
            const Divider(),
            _buildSummaryRow(
                'إجمالي المهام', '$_completedTasksCount من $_totalTasksCount'),
            const Divider(),
            _buildSummaryRow('حالة التنفيذ', 'مكتملة', color: Colors.green),
            const Divider(),
            _buildSummaryRow('تاريخ البدء', '2024-01-15'),
            const Divider(),
            _buildSummaryRow('تاريخ الإنجاز', '2024-01-18'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
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
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistSection() {
    final passedCount = _getPassedCount();
    final totalCount = _checklistItems.length;
    final allPassed = _areAllItemsPassed();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'قائمة التحقق من الجودة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: allPassed ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: allPassed ? Colors.green : Colors.orange,
            ),
          ),
          child: Row(
            children: [
              Icon(
                allPassed ? Icons.check_circle : Icons.warning,
                color: allPassed ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allPassed
                          ? 'جميع عناصر التحقق مُرضية'
                          : 'هناك عناصر تحتاج مراجعة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: allPassed ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      '$passedCount من $totalCount عنصر مُرضٍ',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _checklistItems.length,
          itemBuilder: (context, index) {
            final item = _checklistItems[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        value: item['is_passed'],
                        onChanged: (value) {
                          setState(() {
                            _checklistItems[index]['is_passed'] =
                                value ?? false;
                          });
                        },
                        title: Text(
                          item['item_name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (item['is_passed'])
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 32,
                            right: 0,
                            top: 8,
                          ),
                          child: TextFormField(
                            initialValue: item['notes'],
                            decoration: const InputDecoration(
                              hintText: 'أضف ملاحظة (اختيارية)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            maxLines: 2,
                            onChanged: (value) {
                              _checklistItems[index]['notes'] = value;
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssessmentSection() {
    final allPassed = _areAllItemsPassed();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التقييم العام',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _assessmentController,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'التقييم الشامل',
            hintText: 'أضف تقييمك الشامل للعمل المنجز',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'ملاحظات إضافية',
            hintText: 'ملاحظات أو توصيات إضافية',
          ),
        ),
        if (!allPassed) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'عناصر تحتاج إلى إعادة عمل',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'لا يمكن الموافقة للتسليم إلا بعد إكمال جميع البنود',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    final allPassed = _areAllItemsPassed();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: allPassed
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم الموافقة على التسليم',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                : null,
            icon: const Icon(Icons.check_circle),
            label: const Text(
              'الموافقة للتسليم',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              disabledBackgroundColor: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('إعادة للورشة'),
                  content: const Text(
                    'هل تريد إعادة أمر العمل للورشة لإجراء تعديلات؟',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تم إعادة أمر العمل للورشة',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      child: const Text('تأكيد'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text(
              'إعادة للورشة',
              style: TextStyle(
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
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context, false);
            },
            icon: const Icon(Icons.close),
            label: const Text(
              'إلغاء',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
