import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  final Map<String, dynamic> _kpiData = {
    'vehiclesThisMonth': 45,
    'satisfactionRate': 92.5,
    'returnRate': 3.2,
    'monthlyRevenue': 12500.00,
    'pendingTasks': 7,
    'activeEngineers': 8,
    'completionRate': 94.5,
    'averageTimePerTask': 2.3,
  };

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'icon': Icons.check_circle,
      'title': 'أمر عمل مكتمل',
      'description': 'تم إكمال أمر العمل #WO099 بنجاح',
      'time': 'منذ ساعة',
      'color': AppTheme.successGreen,
    },
    {
      'icon': Icons.warning,
      'title': 'تنبيه جودة',
      'description': 'أمر عمل #WO098 يحتاج إعادة فحص',
      'time': 'منذ ساعتين',
      'color': AppTheme.warningOrange,
    },
    {
      'icon': Icons.person_add,
      'title': 'مهندس جديد',
      'description': 'تم إضافة مهندس جديد في قسم الميكانيكا',
      'time': 'منذ يوم',
      'color': AppTheme.infoBlue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة التحكم الإدارية'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.primaryWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلاً، مدير النظام',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إدارة مركز الصيانة الشامل',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkGray.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
              // KPI Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المؤشرات الرئيسية',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildKPIGrid(),
                    const SizedBox(height: 24),
                    // Management Buttons
                    Text(
                      'إدارة النظام',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildManagementButtons(),
                    const SizedBox(height: 24),
                    // Recent Activities
                    Text(
                      'النشاطات الأخيرة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildRecentActivities(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildKPICard(
          'السيارات هذا الشهر',
          _kpiData['vehiclesThisMonth'].toString(),
          Icons.directions_car,
          AppTheme.infoBlue,
        ),
        _buildKPICard(
          'رضا العملاء',
          '${_kpiData['satisfactionRate']}%',
          Icons.sentiment_satisfied,
          AppTheme.successGreen,
        ),
        _buildKPICard(
          'معدل العودة',
          '${_kpiData['returnRate']}%',
          Icons.repeat,
          AppTheme.warningOrange,
        ),
        _buildKPICard(
          'الإيرادات الشهرية',
          '\$${_kpiData['monthlyRevenue'].toStringAsFixed(0)}',
          Icons.attach_money,
          AppTheme.primaryGreen,
        ),
        _buildKPICard(
          'مهام معلقة',
          _kpiData['pendingTasks'].toString(),
          Icons.pending_actions,
          AppTheme.errorRed,
        ),
        _buildKPICard(
          'المهندسون النشطون',
          _kpiData['activeEngineers'].toString(),
          Icons.engineering,
          const Color(0xFF7C4DFF),
        ),
      ],
    );
  }

  Widget _buildKPICard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.darkGray.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'الخدمات',
                Icons.miscellaneous_services,
                AppTheme.primaryGreen,
                () {
                  context.push('/services');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'المهندسين',
                Icons.engineering,
                AppTheme.infoBlue,
                () {
                  context.push('/engineers');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'المستخدمين',
                Icons.people,
                const Color(0xFF7C4DFF),
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('إدارة المستخدمين')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'الإعدادات',
                Icons.settings,
                AppTheme.warningOrange,
                () {
                  context.push('/settings');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      children: List.generate(_recentActivities.length, (index) {
        final activity = _recentActivities[index];
        return _buildActivityCard(activity);
      }),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: activity['color'].withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            activity['icon'],
            color: activity['color'],
          ),
        ),
        title: Text(
          activity['title'],
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              activity['description'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              activity['time'],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.darkGray.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
