import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../generated/l10n.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../shared/widgets/language_toggle_button.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/quick_stats_widget.dart';
import '../widgets/recent_work_orders_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).dashboard),
          actions: [
            const LanguageToggleButton(showText: false),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Handle notifications
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle_outlined),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    // Navigate to profile
                    break;
                  case 'settings':
                    context.go('/settings');
                    break;
                  case 'logout':
                    context.go('/login');
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline),
                      const SizedBox(width: 8),
                      Text(S.of(context).profile),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings_outlined),
                      const SizedBox(width: 8),
                      Text(S.of(context).settings),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout_outlined),
                      const SizedBox(width: 8),
                      Text(S.of(context).logout),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            // Handle refresh
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${S.of(context).welcome}, أحمد محمد',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'مدير الورشة',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.wb_sunny_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Stats
                const QuickStatsWidget(),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                Text(
                  'الإجراءات السريعة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Main Workflow Actions
                Text(
                  'سير العمل الرئيسي',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    DashboardCard(
                      title: 'فحص جديد',
                      icon: Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => context.go('/inspections/new'),
                    ),
                    DashboardCard(
                      title: 'قائمة الفحوصات',
                      icon: Icons.list_alt,
                      color: Colors.teal,
                      onTap: () => context.go('/inspections'),
                    ),
                    DashboardCard(
                      title: 'مهامي',
                      icon: Icons.engineering,
                      color: Colors.orange,
                      onTap: () => context.go('/work-orders/tasks'),
                    ),
                    DashboardCard(
                      title: 'المشرف',
                      icon: Icons.supervisor_account,
                      color: Colors.indigo,
                      onTap: () => context.go('/work-orders/supervisor'),
                    ),
                    DashboardCard(
                      title: 'تسليم المركبات',
                      icon: Icons.delivery_dining,
                      color: Colors.green,
                      onTap: () => context.go('/work-orders/delivery'),
                    ),
                    DashboardCard(
                      title: S.of(context).reports,
                      icon: Icons.analytics,
                      color: Colors.purple,
                      onTap: () => context.go('/reports'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Additional Actions
                Text(
                  'إجراءات إضافية',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    DashboardCard(
                      title: S.of(context).newCustomer,
                      icon: Icons.person_add,
                      color: Colors.blue,
                      onTap: () => context.go('/customers'),
                    ),
                    DashboardCard(
                      title: S.of(context).newVehicle,
                      icon: Icons.directions_car,
                      color: Colors.orange,
                      onTap: () => context.go('/vehicles'),
                    ),
                    DashboardCard(
                      title: 'أوامر العمل',
                      icon: Icons.work,
                      color: Colors.amber,
                      onTap: () => context.go('/work-orders'),
                    ),
                    DashboardCard(
                      title: 'المحادثات',
                      icon: Icons.chat,
                      color: Colors.pink,
                      onTap: () => context.go('/chat'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Recent Work Orders
                const RecentWorkOrdersWidget(),
                
                const SizedBox(height: 24),
                
                // AI Assistant Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.smart_toy_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              S.of(context).aiAssistant,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'اسأل المساعد الذكي عن أي شيء متعلق بالورشة',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/chat'),
                            icon: const Icon(Icons.chat_outlined),
                            label: Text(S.of(context).askAI),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                // Already on dashboard
                break;
              case 1:
                context.go('/work-orders');
                break;
              case 2:
                context.go('/customers');
                break;
              case 3:
                context.go('/chat');
                break;
              case 4:
                context.go('/settings');
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: S.of(context).dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.work_outline),
              activeIcon: const Icon(Icons.work),
              label: S.of(context).workOrders,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outline),
              activeIcon: const Icon(Icons.people),
              label: S.of(context).customers,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_outlined),
              activeIcon: const Icon(Icons.chat),
              label: S.of(context).chat,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: S.of(context).settings,
            ),
          ],
        ),
      ),
    );
  }
}
