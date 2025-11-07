import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/locale_provider.dart';

class NotificationsCenterPage extends ConsumerStatefulWidget {
  const NotificationsCenterPage({super.key});

  @override
  ConsumerState<NotificationsCenterPage> createState() =>
      _NotificationsCenterPageState();
}

class _NotificationsCenterPageState
    extends ConsumerState<NotificationsCenterPage> {
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final notifications = _getNotifications();
    final filteredNotifications = _showUnreadOnly
        ? notifications.where((n) => !n['read']).toList()
        : notifications;

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🔔 مركز التنبيهات'),
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            if (notifications.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.done_all),
                onPressed: () {
                  setState(() {
                    for (var n in notifications) {
                      n['read'] = true;
                    }
                  });
                },
                tooltip: 'تحديد الكل كمقروء',
              ),
            if (notifications.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('حذف التنبيهات'),
                      content: const Text('هل تريد حذف جميع التنبيهات؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            setState(() => notifications.clear());
                            Navigator.pop(context);
                          },
                          child: const Text('حذف'),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'حذف الكل',
              ),
          ],
        ),
        body: Column(
          children: [
            if (notifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'عدد التنبيهات غير المقروءة: ${notifications.where((n) => !n['read']).length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FilterChip(
                      label: const Text('غير مقروء فقط'),
                      selected: _showUnreadOnly,
                      onSelected: (value) {
                        setState(() => _showUnreadOnly = value);
                      },
                    ),
                  ],
                ),
              ),
            if (filteredNotifications.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد تنبيهات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'أنت محدّث بكل شيء',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = filteredNotifications[index];
                    return NotificationItem(
                      notification: notification,
                      onMarkRead: () {
                        setState(() {
                          notification['read'] = true;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          notifications.remove(notification);
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getNotifications() {
    return [
      {
        'id': '1',
        'type': 'work-order',
        'title': 'ترتيب عمل جديد',
        'message': 'تم تلقي أمر عمل جديد #WO1234',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'read': false,
        'icon': Icons.assignment,
        'color': Colors.blue,
      },
      {
        'id': '2',
        'type': 'delivery',
        'title': 'تسليم جاهز',
        'message': 'المركبة جاهزة للتسليم #WO1233',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'read': false,
        'icon': Icons.local_shipping,
        'color': Colors.green,
      },
      {
        'id': '3',
        'type': 'warranty',
        'title': 'ضمان قريب الانتهاء',
        'message': 'ضمان المركبة سينتهي في 7 أيام',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'read': true,
        'icon': Icons.shield,
        'color': Colors.orange,
      },
      {
        'id': '4',
        'type': 'inventory',
        'title': 'قطعة منخفضة المخزون',
        'message': 'الكمية المتبقية من القطعة X تقل عن الحد الأدنى',
        'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
        'read': true,
        'icon': Icons.inventory_2,
        'color': Colors.red,
      },
      {
        'id': '5',
        'type': 'maintenance',
        'title': 'صيانة دورية',
        'message': 'موعد الصيانة الدورية للسيارة غداً',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'read': true,
        'icon': Icons.build,
        'color': Colors.purple,
      },
    ];
  }
}

class NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const NotificationItem({super.key, 
    required this.notification,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification['read'] ?? false;
    final time = DateFormat('HH:mm').format(notification['timestamp']);

    return Card(
      color: isRead ? Colors.white : Colors.blue.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onMarkRead,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (notification['color'] as Color).withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification['icon'],
                  color: notification['color'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  isRead ? Colors.grey.shade700 : Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton(
                itemBuilder: (context) => [
                  if (!isRead)
                    PopupMenuItem(
                      onTap: onMarkRead,
                      child: const Text('تحديد كمقروء'),
                    ),
                  PopupMenuItem(
                    onTap: onDelete,
                    child: const Text('حذف'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
