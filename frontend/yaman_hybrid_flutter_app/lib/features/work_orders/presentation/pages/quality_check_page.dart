import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';

class QualityCheckPage extends ConsumerStatefulWidget {
  final String workOrderNumber;

  const QualityCheckPage({
    required this.workOrderNumber,
    super.key,
  });

  @override
  ConsumerState<QualityCheckPage> createState() => _QualityCheckPageState();
}

class _QualityCheckPageState extends ConsumerState<QualityCheckPage> {
  final List<Map<String, dynamic>> _services = [
    {
      'id': 1,
      'serviceName': 'تغيير زيت المحرك',
      'engineer': 'أحمد محمد',
      'status': 'مكتمل',
      'quality': null,
      'notes': '',
    },
    {
      'id': 2,
      'serviceName': 'فحص الفرامل',
      'engineer': 'علي الحسن',
      'status': 'مكتمل',
      'quality': null,
      'notes': '',
    },
    {
      'id': 3,
      'serviceName': 'استبدال البطارية',
      'engineer': 'محمود عبده',
      'status': 'مكتمل',
      'quality': null,
      'notes': '',
    },
  ];

  final List<String> _generalChecks = [
    'تجربة تشغيل المحرك',
    'فحص أنظمة السلامة',
    'تنظيف السيارة',
    'فحص الإضاءة',
    'فحص المساحات',
  ];

  List<bool> _generalChecksDone = [];
  final _supervisorNotesController = TextEditingController();
  final _internalNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generalChecksDone = List<bool>.filled(_generalChecks.length, false);
  }

  @override
  void dispose() {
    _supervisorNotesController.dispose();
    _internalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الفحص النهائي والجودة'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.primaryWhite,
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
              _buildOrderHeader(),
              const SizedBox(height: 24),
              _buildSectionHeader('الفحوصات العامة'),
              const SizedBox(height: 12),
              _buildGeneralChecklist(),
              const SizedBox(height: 24),
              _buildSectionHeader('الخدمات المنفذة'),
              const SizedBox(height: 12),
              _buildServicesQualityCheck(),
              const SizedBox(height: 24),
              _buildSectionHeader('ملاحظات المشرف'),
              const SizedBox(height: 12),
              TextField(
                controller: _supervisorNotesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'أدخل ملاحظاتك هنا',
                  filled: true,
                  fillColor: AppTheme.lightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.mediumGray),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('ملاحظات داخلية'),
              const SizedBox(height: 12),
              TextField(
                controller: _internalNotesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'ملاحظات للاستخدام الداخلي فقط',
                  filled: true,
                  fillColor: AppTheme.lightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.mediumGray),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أمر العمل: ${widget.workOrderNumber}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'العميل',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.darkGray.withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'محمد علي',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السيارة',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.darkGray.withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تويوتا كامري',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ الإنجاز',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.darkGray.withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '2024-11-03',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildGeneralChecklist() {
    return Column(
      children: List.generate(_generalChecks.length, (index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: CheckboxListTile(
            value: _generalChecksDone[index],
            onChanged: (value) {
              setState(() {
                _generalChecksDone[index] = value ?? false;
              });
            },
            title: Text(
              _generalChecks[index],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            activeColor: AppTheme.successGreen,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        );
      }),
    );
  }

  Widget _buildServicesQualityCheck() {
    return Column(
      children: List.generate(_services.length, (index) {
        final service = _services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                            service['serviceName'],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'المهندس: ${service['engineer']}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      AppTheme.darkGray.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'مكتمل',
                        style: TextStyle(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label: const Text('جيد'),
                          onPressed: () {
                            setState(() {
                              service['quality'] = 'good';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: service['quality'] == 'good'
                                ? AppTheme.successGreen
                                : AppTheme.darkGray,
                            side: BorderSide(
                              color: service['quality'] == 'good'
                                  ? AppTheme.successGreen
                                  : AppTheme.mediumGray,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.warning_amber),
                          label: const Text('يحتاج مراجعة'),
                          onPressed: () {
                            setState(() {
                              service['quality'] = 'review';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: service['quality'] == 'review'
                                ? AppTheme.warningOrange
                                : AppTheme.darkGray,
                            side: BorderSide(
                              color: service['quality'] == 'review'
                                  ? AppTheme.warningOrange
                                  : AppTheme.mediumGray,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('إعادة للعمل'),
            onPressed: () {
              _showReturnToWorkDialog();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
              side: const BorderSide(color: AppTheme.errorRed),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('جاهزة للتسليم'),
            onPressed: () {
              _showApprovalDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: AppTheme.primaryWhite,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showReturnToWorkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة للعمل'),
        content: const Text('هل أنت متأكد من إعادة هذا الأمر للعمل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إعادة الأمر للعمل')),
              );
              await Future.delayed(const Duration(seconds: 1));
              if (mounted && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('إعادة',
                style: TextStyle(color: AppTheme.primaryWhite)),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الموافقة'),
        content: const Text('هل أنت متأكد من أن السيارة جاهزة للتسليم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('تم اعتماد السيارة للتسليم')),
              );
              await Future.delayed(const Duration(seconds: 1));
              if (mounted) {
                navigator.pop();
              }
            },
            child: const Text('موافقة',
                style: TextStyle(color: AppTheme.primaryWhite)),
          ),
        ],
      ),
    );
  }
}
