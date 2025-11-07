import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/locale_provider.dart';

class WarrantyManagementPage extends ConsumerStatefulWidget {
  const WarrantyManagementPage({super.key});

  @override
  ConsumerState<WarrantyManagementPage> createState() =>
      _WarrantyManagementPageState();
}

class _WarrantyManagementPageState extends ConsumerState<WarrantyManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
          title: const Text('🛡️ إدارة الضمانات'),
          backgroundColor: Colors.teal,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'نشطة'),
              Tab(text: 'منتهية'),
              Tab(text: 'قريبة'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () {
                // Add warranty dialog
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveWarrantiesTab(),
            _buildExpiredWarrantiesTab(),
            _buildExpiringWarrantiesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWarrantiesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        final expiryDate = DateTime.now().add(Duration(days: 90 - index * 15));
        final daysLeft = expiryDate.difference(DateTime.now()).inDays;

        return WarrantyCard(
          warrantyNumber: 'WR${index + 1001}',
          vehicleName: 'السيارة ${index + 1}',
          expiryDate: expiryDate,
          daysLeft: daysLeft,
          status: 'نشطة',
          statusColor: Colors.green,
          services: const ['الفرامل', 'المحرك', 'الإطارات'],
        );
      },
    );
  }

  Widget _buildExpiredWarrantiesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        final expiryDate =
            DateTime.now().subtract(Duration(days: 30 + index * 20));

        return WarrantyCard(
          warrantyNumber: 'WR${index + 2001}',
          vehicleName: 'السيارة ${index + 6}',
          expiryDate: expiryDate,
          daysLeft: -1,
          status: 'منتهية',
          statusColor: Colors.red,
          services: const ['الفرامل'],
        );
      },
    );
  }

  Widget _buildExpiringWarrantiesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        final expiryDate = DateTime.now().add(Duration(days: 7 - index * 2));

        return WarrantyCard(
          warrantyNumber: 'WR${index + 3001}',
          vehicleName: 'السيارة ${index + 11}',
          expiryDate: expiryDate,
          daysLeft: 7 - index * 2,
          status: 'قريبة الانتهاء',
          statusColor: Colors.orange,
          services: const ['المحرك', 'الإطارات'],
        );
      },
    );
  }
}

class WarrantyCard extends StatelessWidget {
  final String warrantyNumber;
  final String vehicleName;
  final DateTime expiryDate;
  final int daysLeft;
  final String status;
  final Color statusColor;
  final List<String> services;

  const WarrantyCard({super.key, 
    required this.warrantyNumber,
    required this.vehicleName,
    required this.expiryDate,
    required this.daysLeft,
    required this.status,
    required this.statusColor,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warrantyNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicleName,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'ينتهي في: ${dateFormat.format(expiryDate)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            if (daysLeft > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'متبقي: $daysLeft يوم',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'الخدمات المغطاة:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: services
                  .map(
                    (service) => Chip(
                      label: Text(
                        service,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: statusColor.withAlpha(77),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('تفاصيل'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('تجديد'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
