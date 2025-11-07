import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';

class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() =>
      _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends ConsumerState<AnalyticsDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'monthly';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          title: const Text('📊 لوحة التحليلات'),
          backgroundColor: Colors.indigo,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'المبيعات'),
              Tab(text: 'الأداء'),
              Tab(text: 'العملاء'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'weekly',
                          label: Text('أسبوعي'),
                        ),
                        ButtonSegment<String>(
                          value: 'monthly',
                          label: Text('شهري'),
                        ),
                        ButtonSegment<String>(
                          value: 'yearly',
                          label: Text('سنوي'),
                        ),
                      ],
                      selected: <String>{_selectedPeriod},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedPeriod = newSelection.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSalesTab(),
                  _buildPerformanceTab(),
                  _buildCustomersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص المبيعات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'إجمالي المبيعات',
                  value: '150,500',
                  unit: 'ريال',
                  icon: Icons.attach_money,
                  color: Colors.green,
                  growth: '+12.5%',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'عدد الطلبيات',
                  value: '234',
                  unit: 'طلبية',
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                  growth: '+8.2%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'متوسط الفاتورة',
                  value: '643',
                  unit: 'ريال',
                  icon: Icons.receipt,
                  color: Colors.orange,
                  growth: '+3.1%',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'الخدمات الأكثر',
                  value: 'الفرامل',
                  unit: '45 طلب',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'أعلى الخدمات طلباً',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildServicesList(),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أداء الورشة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'الطاقة الإنتاجية',
                  value: '85',
                  unit: '%',
                  icon: Icons.speed,
                  color: Colors.teal,
                  growth: '+5.3%',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'رضا العملاء',
                  value: '4.7',
                  unit: 'من 5',
                  icon: Icons.sentiment_satisfied,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'وقت الإنجاز',
                  value: '2.5',
                  unit: 'يوم',
                  icon: Icons.access_time,
                  color: Colors.pink,
                  growth: '-8.1%',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'معدل الأخطاء',
                  value: '2.1',
                  unit: '%',
                  icon: Icons.bug_report,
                  color: Colors.red,
                  growth: '-1.2%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'أداء الفنيين',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTechniciansList(),
        ],
      ),
    );
  }

  Widget _buildCustomersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تحليل العملاء',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'إجمالي العملاء',
                  value: '458',
                  unit: 'عميل',
                  icon: Icons.people,
                  color: Colors.blue,
                  growth: '+12.5%',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'عملاء جدد',
                  value: '45',
                  unit: 'هذا الشهر',
                  icon: Icons.person_add,
                  color: Colors.green,
                  growth: '+25.3%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'معدل التكرار',
                  value: '68',
                  unit: '%',
                  icon: Icons.repeat,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'القيمة المتوسطة',
                  value: '2,450',
                  unit: 'ريال',
                  icon: Icons.trending_up,
                  color: Colors.orange,
                  growth: '+18.5%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'توزيع العملاء',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildChartRow('أفراد', 65),
                  const SizedBox(height: 12),
                  _buildChartRow('شركات', 28),
                  const SizedBox(height: 12),
                  _buildChartRow('مؤسسات', 7),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          final services = [
            'الفرامل',
            'المحرك',
            'الإطارات',
            'البطارية',
            'الزيت'
          ];
          final counts = [45, 38, 32, 28, 25];

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(services[index]),
                    Text(
                      '${counts[index]} طلب',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: counts[index] / 45,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTechniciansList() {
    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          final technicians = [
            'أحمد محمد',
            'سارة علي',
            'محمود سالم',
            'فاطمة حسن'
          ];
          final performance = [92, 88, 85, 80];

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      technicians[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${performance[index]}%'),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: performance[index] / 100,
                    minHeight: 8,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartRow(String label, double value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '${value.toStringAsFixed(0)}%',
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String? growth;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.growth,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                if (growth != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: growth!.startsWith('+')
                          ? Colors.green.withAlpha(51)
                          : Colors.red.withAlpha(51),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      growth!,
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            growth!.startsWith('+') ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
