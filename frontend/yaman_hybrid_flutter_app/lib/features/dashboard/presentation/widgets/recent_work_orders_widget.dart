import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../generated/l10n.dart';

class RecentWorkOrdersWidget extends StatelessWidget {
  const RecentWorkOrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'أوامر العمل الحديثة',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/work-orders'),
              child: Text(S.of(context).viewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _WorkOrderItem(
                id: 'WO-001',
                customerName: 'أحمد علي',
                vehicleInfo: 'تويوتا كامري 2020',
                serviceType: 'صيانة دورية',
                status: S.of(context).inProgress,
                statusColor: Colors.orange,
                date: '2024-01-15',
              ),
              const Divider(height: 1),
              _WorkOrderItem(
                id: 'WO-002',
                customerName: 'فاطمة محمد',
                vehicleInfo: 'هوندا أكورد 2019',
                serviceType: 'إصلاح فرامل',
                status: S.of(context).pending,
                statusColor: Colors.blue,
                date: '2024-01-14',
              ),
              const Divider(height: 1),
              _WorkOrderItem(
                id: 'WO-003',
                customerName: 'محمد سالم',
                vehicleInfo: 'نيسان التيما 2021',
                serviceType: 'تغيير زيت',
                status: S.of(context).completed,
                statusColor: Colors.green,
                date: '2024-01-13',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkOrderItem extends StatelessWidget {
  final String id;
  final String customerName;
  final String vehicleInfo;
  final String serviceType;
  final String status;
  final Color statusColor;
  final String date;

  const _WorkOrderItem({
    required this.id,
    required this.customerName,
    required this.vehicleInfo,
    required this.serviceType,
    required this.status,
    required this.statusColor,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.build_circle_outlined,
          color: statusColor,
        ),
      ),
      title: Row(
        children: [
          Text(
            id,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            customerName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            vehicleInfo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.build_outlined,
                size: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                serviceType,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        // Navigate to work order details
        context.go('/work-orders');
      },
    );
  }
}
