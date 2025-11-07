import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';

class AdvancedWorkOrderPage extends ConsumerStatefulWidget {
  final String workOrderNumber;

  const AdvancedWorkOrderPage({
    required this.workOrderNumber,
    super.key,
  });

  @override
  ConsumerState<AdvancedWorkOrderPage> createState() =>
      _AdvancedWorkOrderPageState();
}

class _AdvancedWorkOrderPageState extends ConsumerState<AdvancedWorkOrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, dynamic> _orderData = {
    'customer': {
      'name': 'محمد علي',
      'phone': '967701234567',
      'email': 'customer@example.com',
    },
    'vehicle': {
      'make': 'تويوتا',
      'model': 'كامري',
      'year': 2020,
      'color': 'أبيض',
      'plateNumber': 'ب ع 123',
      'vin': 'JTDKARFP9J3072445',
      'mileage': '45000 كم',
    },
    'services': [
      {
        'id': 1,
        'name': 'تغيير زيت المحرك',
        'description': 'استبدال زيت المحرك بزيت أصلي',
        'engineer': 'أحمد محمد',
        'status': 'مكتمل',
        'estimatedTime': 30,
        'actualTime': 25,
        'cost': 50.00,
        'beforeImage': null,
        'afterImage': null,
      },
      {
        'id': 2,
        'name': 'فحص الفرامل',
        'description': 'فحص شامل لنظام الفرامل',
        'engineer': 'علي الحسن',
        'status': 'جاري',
        'estimatedTime': 45,
        'actualTime': 30,
        'cost': 75.00,
        'beforeImage': null,
        'afterImage': null,
      },
      {
        'id': 3,
        'name': 'استبدال البطارية',
        'description': 'تركيب بطارية جديدة',
        'engineer': 'محمود عبده',
        'status': 'معلق',
        'estimatedTime': 20,
        'actualTime': 0,
        'cost': 120.00,
        'beforeImage': null,
        'afterImage': null,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          title: Text('أمر العمل: ${widget.workOrderNumber}'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.primaryWhite,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'البيانات'),
              Tab(text: 'الخدمات'),
              Tab(text: 'المرفقات'),
              Tab(text: 'الملاحظات'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(),
            _buildServicesTab(),
            _buildAttachmentsTab(),
            _buildNotesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('بيانات العميل'),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.person,
            title: 'الاسم',
            value: _orderData['customer']['name'],
          ),
          _buildDetailCard(
            icon: Icons.phone,
            title: 'الهاتف',
            value: _orderData['customer']['phone'],
          ),
          _buildDetailCard(
            icon: Icons.email,
            title: 'البريد الإلكتروني',
            value: _orderData['customer']['email'],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('بيانات السيارة'),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.directions_car,
            title: 'الماركة والموديل',
            value:
                '${_orderData['vehicle']['make']} ${_orderData['vehicle']['model']}',
          ),
          _buildDetailCard(
            icon: Icons.calendar_today,
            title: 'سنة الصنع',
            value: _orderData['vehicle']['year'].toString(),
          ),
          _buildDetailCard(
            icon: Icons.palette,
            title: 'اللون',
            value: _orderData['vehicle']['color'],
          ),
          _buildDetailCard(
            icon: Icons.confirmation_number,
            title: 'رقم اللوحة',
            value: _orderData['vehicle']['plateNumber'],
          ),
          _buildDetailCard(
            icon: Icons.vpn_key,
            title: 'رقم الشاصي (VIN)',
            value: _orderData['vehicle']['vin'],
          ),
          _buildDetailCard(
            icon: Icons.speed,
            title: 'قراءة العداد',
            value: _orderData['vehicle']['mileage'],
          ),
          const SizedBox(height: 24),
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.darkGray.withValues(alpha: 0.7),
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
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

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen.withValues(alpha: 0.1),
              AppTheme.lightGreen.withValues(alpha: 0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص أمر العمل',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي المبلغ',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عدد الخدمات',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _orderData['services'].length.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة الأمر',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'جاري',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.warningOrange,
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

  Widget _buildServicesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orderData['services'].length,
      itemBuilder: (context, index) {
        final service = _orderData['services'][index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    Color statusColor = service['status'] == 'مكتمل'
        ? AppTheme.successGreen
        : service['status'] == 'جاري'
            ? AppTheme.warningOrange
            : AppTheme.mediumGray;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: statusColor, width: 4),
          ),
        ),
        child: ExpansionTile(
          title: Text(
            service['name'],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Text(
            service['engineer'],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.darkGray.withValues(alpha: 0.7),
                ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              service['status'],
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceDetailRow('الوصف', service['description']),
                  const SizedBox(height: 12),
                  _buildServiceDetailRow('المهندس', service['engineer']),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildServiceDetailRow(
                          'الوقت المتوقع',
                          '${service['estimatedTime']} دقيقة',
                        ),
                      ),
                      Expanded(
                        child: _buildServiceDetailRow(
                          'الوقت الفعلي',
                          '${service['actualTime']} دقيقة',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildServiceDetailRow(
                    'التكلفة',
                    '\$${service['cost'].toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('قبل'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('عرض صورة قبل الإصلاح')),
                          );
                        },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('بعد'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('عرض صورة بعد الإصلاح')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.darkGray.withValues(alpha: 0.7),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported,
            size: 64,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد مرفقات حتى الآن',
            style: TextStyle(
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('إضافة صور'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('فتح معرج الصور')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ملاحظات المبيعات'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'العميل وافق على جميع الخدمات المقترحة. طلب إضافة فحص شامل للعطالات الكهربائية.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('ملاحظات المشرف'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'جودة العمل جيدة جداً. المهندسون يعملون بكفاءة عالية.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('ملاحظات المهندسين'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'لاحظنا بعض المشاكل الإضافية في نظام التوجيه. تم الإبلاغ عن ذلك للعميل.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('إضافة ملاحظة جديدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('فتح نافذة إضافة ملاحظة')),
              );
            },
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var service in _orderData['services']) {
      total += service['cost'] ?? 0;
    }
    return total;
  }
}
