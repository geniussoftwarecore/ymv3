import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';

class EnhancedReportsPage extends ConsumerStatefulWidget {
  const EnhancedReportsPage({super.key});

  @override
  ConsumerState<EnhancedReportsPage> createState() =>
      _EnhancedReportsPageState();
}

class _EnhancedReportsPageState extends ConsumerState<EnhancedReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير والإحصائيات'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'السيارات'),
              Tab(text: 'المهندسون'),
              Tab(text: 'العودة'),
              Tab(text: 'الإيرادات'),
              Tab(text: 'الصحة'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildDateRangeSelector(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVehiclesReport(),
                  _buildEngineerPerformanceReport(),
                  _buildReturnRateReport(),
                  _buildRevenueReport(),
                  _buildSystemHealthReport(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'من',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${_startDate.year}-${_startDate.month}-${_startDate.day}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                }
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'إلى',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${_endDate.year}-${_endDate.month}-${_endDate.day}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricCard(
            title: 'إجمالي السيارات',
            value: '145',
            icon: Icons.directions_car,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            title: 'السيارات المصلحة',
            value: '98',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            title: 'السيارات قيد الصيانة',
            value: '47',
            icon: Icons.build,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          _buildChartPlaceholder('توزيع السيارات حسب النوع'),
          const SizedBox(height: 24),
          _buildTablePlaceholder('أكثر الأعطال شيوعاً', [
            {'fault': 'تغيير الزيت', 'count': '45'},
            {'fault': 'استبدال الإطارات', 'count': '32'},
            {'fault': 'إصلاح الفرامل', 'count': '28'},
            {'fault': 'فحص البطارية', 'count': '24'},
          ]),
        ],
      ),
    );
  }

  Widget _buildEngineerPerformanceReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTablePlaceholder('أداء المهندسين', [
            {
              'name': 'أحمد محمد',
              'tasks': '45',
              'avg_time': '2.5 ساعة',
            },
            {
              'name': 'علي الحسن',
              'tasks': '38',
              'avg_time': '3 ساعات',
            },
            {
              'name': 'محمود عبده',
              'tasks': '42',
              'avg_time': '2.8 ساعة',
            },
          ]),
          const SizedBox(height: 24),
          _buildChartPlaceholder('توزيع المهام حسب المهندس'),
          const SizedBox(height: 24),
          _buildMetricCard(
            title: 'متوسط الإنتاجية',
            value: '3.1',
            subtitle: 'مهام/يوم',
            icon: Icons.trending_up,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildReturnRateReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricCard(
            title: 'معدل العودة',
            value: '3.2%',
            subtitle: 'أقل من الهدف (5%)',
            icon: Icons.trending_down,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            title: 'السيارات العائدة',
            value: '4',
            subtitle: 'من 125 سيارة',
            icon: Icons.history,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          _buildChartPlaceholder('معدل العودة على مدار الشهر'),
          const SizedBox(height: 24),
          _buildTablePlaceholder('الأعطال المتكررة', [
            {'issue': 'مشكلة كهربائية', 'count': '2'},
            {'issue': 'فرامل غير فعالة', 'count': '1'},
            {'issue': 'تسريب زيت', 'count': '1'},
          ]),
        ],
      ),
    );
  }

  Widget _buildRevenueReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricCard(
            title: 'إجمالي الإيرادات',
            value: '450,000',
            subtitle: 'ريال يمني',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            title: 'متوسط الطلبية',
            value: '3,600',
            subtitle: 'ريال يمني',
            icon: Icons.shopping_cart,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          _buildChartPlaceholder('الإيرادات على مدار الشهر'),
          const SizedBox(height: 24),
          _buildTablePlaceholder('أعلى الخدمات إيراداً', [
            {'service': 'إصلاح محرك', 'revenue': '125,000'},
            {'service': 'إصلاح جسم السيارة', 'revenue': '95,000'},
            {'service': 'كهرباء السيارة', 'revenue': '85,000'},
          ]),
        ],
      ),
    );
  }

  Widget _buildSystemHealthReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricCard(
            title: 'معدل الإنجاز',
            value: '95%',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            title: 'متوسط وقت المعالجة',
            value: '3.2',
            subtitle: 'أيام',
            icon: Icons.schedule,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            title: 'رضا العملاء',
            value: '4.7',
            subtitle: 'من 5',
            icon: Icons.star,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حالة النظام',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHealthItem('التطبيق الأمامي', 'طبيعي', Colors.green),
                  const SizedBox(height: 8),
                  _buildHealthItem('الخدمات الخلفية', 'طبيعي', Colors.green),
                  const SizedBox(height: 8),
                  _buildHealthItem('قاعدة البيانات', 'طبيعي', Colors.green),
                  const SizedBox(height: 8),
                  _buildHealthItem(
                      'التكاملات الخارجية', 'تنبيه بسيط', Colors.orange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(String title) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              color: Colors.grey.shade100,
              child: const Center(
                child: Text('رسم بياني تفاعلي'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablePlaceholder(
    String title,
    List<Map<String, String>> data,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ...data.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        row.values.first,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      row.values.last,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthItem(String name, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
