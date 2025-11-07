import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';

class SalesDashboardPage extends ConsumerStatefulWidget {
  const SalesDashboardPage({super.key});

  @override
  ConsumerState<SalesDashboardPage> createState() => _SalesDashboardPageState();
}

class _SalesDashboardPageState extends ConsumerState<SalesDashboardPage> {
  final List<Map<String, dynamic>> _newInspections = [
    {
      'id': 1,
      'inspectionNumber': '#INS001',
      'customerName': 'محمد علي',
      'vehicle': 'تويوتا كامري',
      'plateNumber': 'ب ع 123',
      'date': '2024-11-03',
      'status': 'جديد',
    },
    {
      'id': 2,
      'inspectionNumber': '#INS002',
      'customerName': 'فاطمة أحمد',
      'vehicle': 'هونداي أكورد',
      'plateNumber': 'ب ع 456',
      'date': '2024-11-03',
      'status': 'قيد المراجعة',
    },
  ];

  final List<Map<String, dynamic>> _sentQuotes = [
    {
      'id': 1,
      'quoteNumber': '#QUO001',
      'customerName': 'علي سالم',
      'amount': 850.00,
      'sentDate': '2024-11-01',
      'status': 'معلق',
    },
    {
      'id': 2,
      'quoteNumber': '#QUO002',
      'customerName': 'نور محمد',
      'amount': 1200.00,
      'sentDate': '2024-10-30',
      'status': 'موافق عليه',
    },
  ];

  final List<Map<String, dynamic>> _workInProgress = [
    {
      'id': 1,
      'workOrderNumber': '#WO001',
      'customerName': 'حسن علي',
      'vehicle': 'بي ام دبليو',
      'progress': '3/5',
      'engineers': 'أحمد، علي',
      'estimatedCompletion': '2024-11-05',
    },
    {
      'id': 2,
      'workOrderNumber': '#WO002',
      'customerName': 'ليلى إبراهيم',
      'vehicle': 'مرسيدس بنز',
      'progress': '2/4',
      'engineers': 'محمود',
      'estimatedCompletion': '2024-11-06',
    },
  ];

  final List<Map<String, dynamic>> _readyForDelivery = [
    {
      'id': 1,
      'workOrderNumber': '#WO099',
      'customerName': 'خالد أحمد',
      'vehicle': 'نيسان ألتيما',
      'completionDate': '2024-11-02',
      'totalCost': 650.00,
    },
    {
      'id': 2,
      'workOrderNumber': '#WO098',
      'customerName': 'سارة محمد',
      'vehicle': 'كيا سبورتاج',
      'completionDate': '2024-11-02',
      'totalCost': 500.00,
    },
  ];

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة المبيعات'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.primaryWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Column(
          children: [
            // KPI Cards
            Container(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildKPICard('فحوصات جديدة',
                      _newInspections.length.toString(), AppTheme.infoBlue),
                  _buildKPICard('عروض معلقة', _sentQuotes.length.toString(),
                      AppTheme.warningOrange),
                  _buildKPICard('أوامر جارية',
                      _workInProgress.length.toString(), AppTheme.primaryGreen),
                  _buildKPICard(
                      'جاهزة للتسليم',
                      _readyForDelivery.length.toString(),
                      AppTheme.successGreen),
                ],
              ),
            ),
            // Tab Navigation
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton('الفحوصات الجديدة', 0),
                  _buildTabButton('العروض المرسلة', 1),
                  _buildTabButton('أوامر جارية', 2),
                  _buildTabButton('جاهزة للتسليم', 3),
                ],
              ),
            ),
            // Content
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildNewInspectionsTab(),
                  _buildSentQuotesTab(),
                  _buildWorkInProgressTab(),
                  _buildReadyForDeliveryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int tabIndex) {
    bool isSelected = _selectedTab == tabIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => setState(() => _selectedTab = tabIndex),
        style: TextButton.styleFrom(
          backgroundColor:
              isSelected ? AppTheme.primaryGreen : Colors.transparent,
          foregroundColor:
              isSelected ? AppTheme.primaryWhite : AppTheme.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryGreen : AppTheme.mediumGray,
            ),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildNewInspectionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _newInspections.length,
      itemBuilder: (context, index) {
        final inspection = _newInspections[index];
        return _buildInspectionCard(inspection);
      },
    );
  }

  Widget _buildInspectionCard(Map<String, dynamic> inspection) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.infoBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              const Icon(Icons.assignment_outlined, color: AppTheme.infoBlue),
        ),
        title: Text(inspection['customerName']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${inspection['vehicle']} - ${inspection['plateNumber']}'),
            const SizedBox(height: 4),
            Text(
              inspection['inspectionNumber'],
              style: const TextStyle(fontSize: 12, color: AppTheme.darkGray),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              inspection['status'],
              style: const TextStyle(
                color: AppTheme.warningOrange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              inspection['date'],
              style: const TextStyle(fontSize: 11, color: AppTheme.darkGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentQuotesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sentQuotes.length,
      itemBuilder: (context, index) {
        final quote = _sentQuotes[index];
        return _buildQuoteCard(quote);
      },
    );
  }

  Widget _buildQuoteCard(Map<String, dynamic> quote) {
    Color statusColor = quote['status'] == 'معلق'
        ? AppTheme.warningOrange
        : AppTheme.successGreen;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        quote['customerName'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          quote['status'],
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المبلغ: \$${quote['amount'].toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'تاريخ الإرسال: ${quote['sentDate']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.darkGray.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.email, color: AppTheme.infoBlue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('إرسال بريد إلكتروني')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble,
                      color: AppTheme.primaryGreen),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('فتح محادثة')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkInProgressTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _workInProgress.length,
      itemBuilder: (context, index) {
        final work = _workInProgress[index];
        return _buildWorkProgressCard(work);
      },
    );
  }

  Widget _buildWorkProgressCard(Map<String, dynamic> work) {
    final progressParts = work['progress'].split('/');
    final completed = int.tryParse(progressParts[0]) ?? 0;
    final total = int.tryParse(progressParts[1]) ?? 1;
    final progress = completed / total;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        work['customerName'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        work['vehicle'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.darkGray.withValues(alpha: 0.7),
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
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    work['progress'],
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppTheme.lightGray,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المهندسون: ${work['engineers']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'تسليم متوقع: ${work['estimatedCompletion']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyForDeliveryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _readyForDelivery.length,
      itemBuilder: (context, index) {
        final delivery = _readyForDelivery[index];
        return _buildDeliveryCard(delivery);
      },
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.check_circle, color: AppTheme.successGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery['customerName'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    delivery['vehicle'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.darkGray.withValues(alpha: 0.7),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'المبلغ: \$${delivery['totalCost'].toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notification_important,
                  color: AppTheme.warningOrange),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('إرسال إخطار للعميل')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
