import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/locale_provider.dart';

class ServiceHistoryPage extends ConsumerStatefulWidget {
  final String vehicleId;

  const ServiceHistoryPage({
    required this.vehicleId,
    super.key,
  });

  @override
  ConsumerState<ServiceHistoryPage> createState() => _ServiceHistoryPageState();
}

class _ServiceHistoryPageState extends ConsumerState<ServiceHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Initialize when component is created
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📋 سجل الخدمات'),
          backgroundColor: Colors.cyan,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Vehicle Info Header
              Container(
                color: Colors.cyan.withAlpha(25),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المركبة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'تويوتا كامري 2020',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'رقم اللوحة',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                'ج ح م 2025',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'عدد الكيلومترات',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                '45,320 كم',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'عدد الزيارات',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                '12 زيارة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Statistics
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'إجمالي التكاليف',
                        value: '15,450',
                        unit: 'ريال',
                        icon: Icons.attach_money,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        label: 'الخدمة الأخيرة',
                        value: 'منذ 15 يوم',
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              // Service History Timeline
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سجل الخدمات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildServiceTimeline(),
                  ],
                ),
              ),

              // Download Report Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('جاري تحميل التقرير...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('تحميل التقرير الكامل'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTimeline() {
    final services = [
      {
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'type': 'الصيانة الدورية',
        'services': ['تغيير الزيت', 'فحص الفرامل'],
        'cost': '450',
        'status': 'مكتمل',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 45)),
        'type': 'إصلاح',
        'services': ['إصلاح الراديتير'],
        'cost': '1,200',
        'status': 'مكتمل',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 90)),
        'type': 'الصيانة الشاملة',
        'services': ['فحص شامل', 'تغيير الزيت', 'فحص البطارية', 'تنظيف المرشح'],
        'cost': '2,800',
        'status': 'مكتمل',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 180)),
        'type': 'التفتيش',
        'services': ['فحص شامل'],
        'cost': '300',
        'status': 'مكتمل',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 365)),
        'type': 'الصيانة السنوية',
        'services': ['صيانة شاملة', 'تغيير السوائل', 'فحص المحرك'],
        'cost': '3,500',
        'status': 'مكتمل',
      },
    ];

    return Column(
      children: List.generate(
        services.length,
        (index) {
          final service = services[index];
          final dateFormat =
              DateFormat('yyyy-MM-dd').format(service['date'] as DateTime);
          final isLast = index == services.length - 1;

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.done,
                          color: Colors.white,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 80,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    service['type'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withAlpha(51),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'مكتمل',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateFormat,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: (service['services'] as List)
                                    .map(
                                      (s) => Chip(
                                        label: Text(
                                          s,
                                          style: const TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                        backgroundColor:
                                            Colors.cyan.withAlpha(77),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'التكلفة: ${service['cost']} ريال',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(height: 2),
              Text(
                unit!,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
