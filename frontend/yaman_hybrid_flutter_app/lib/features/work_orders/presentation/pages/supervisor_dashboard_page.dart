import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class SupervisorDashboardPage extends ConsumerStatefulWidget {
  const SupervisorDashboardPage({super.key});

  @override
  ConsumerState<SupervisorDashboardPage> createState() =>
      _SupervisorDashboardPageState();
}

class _SupervisorDashboardPageState
    extends ConsumerState<SupervisorDashboardPage>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  String _selectedFilter = 'all';
  String _selectedSort = 'date';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة المشرف'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'فحص نهائي'),
              Tab(text: 'معتمدة'),
              Tab(text: 'مرفوضة'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _showSortDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: _searchController,
                hintText: 'البحث في أوامر العمل...',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  // Handle search
                },
              ),
            ),

            // Work Orders List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWorkOrdersList('pending_inspection'),
                  _buildWorkOrdersList('approved'),
                  _buildWorkOrdersList('rejected'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkOrdersList(String status) {
    // Mock data - in real app, this would come from provider
    final mockWorkOrders = _getMockWorkOrders(status);

    if (mockWorkOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد أوامر عمل',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockWorkOrders.length,
      itemBuilder: (context, index) {
        final workOrder = mockWorkOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getWorkOrderStatusColor(workOrder['status']),
              child: Icon(
                _getWorkOrderStatusIcon(workOrder['status']),
                color: Colors.white,
              ),
            ),
            title: Text('أمر العمل: ${workOrder['work_order_number']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('العميل: ${workOrder['customer_name']}'),
                Text(
                  'المركبة: ${workOrder['vehicle_info']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'تاريخ الانتهاء: ${DateFormat('yyyy/MM/dd HH:mm').format(workOrder['completion_date'])}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Work Order Details
                    _buildWorkOrderDetails(workOrder),

                    const SizedBox(height: 16),

                    // Services Summary
                    _buildServicesSummary(workOrder),

                    const SizedBox(height: 16),

                    // Action Buttons
                    _buildSupervisorActions(workOrder),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkOrderDetails(Map<String, dynamic> workOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفاصيل أمر العمل',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'إجمالي التكلفة',
                '${workOrder['total_cost']} ريال',
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'عدد الخدمات',
                '${workOrder['services_count']}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'المهندس المسؤول',
                workOrder['assigned_engineer'],
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'وقت التنفيذ',
                '${workOrder['total_duration']} دقيقة',
              ),
            ),
          ],
        ),
        if (workOrder['notes']?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          _buildDetailItem('ملاحظات', workOrder['notes']),
        ],
      ],
    );
  }

  Widget _buildServicesSummary(Map<String, dynamic> workOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخدمات المنجزة',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...workOrder['services'].map<Widget>((service) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  service['status'] == 'completed'
                      ? Icons.check_circle
                      : Icons.pending,
                  color: service['status'] == 'completed'
                      ? Colors.green
                      : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'المهندس: ${service['engineer']}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${service['cost']} ريال'),
                    Text(
                      '${service['duration']} دقيقة',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSupervisorActions(Map<String, dynamic> workOrder) {
    final status = workOrder['status'];

    if (status == 'pending_inspection') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewPhotosAndDetails(workOrder),
              icon: const Icon(Icons.visibility),
              label: const Text('عرض الصور والتفاصيل'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _rejectWorkOrder(workOrder),
              icon: const Icon(Icons.close),
              label: const Text('رفض'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _approveWorkOrder(workOrder),
              icon: const Icon(Icons.check),
              label: const Text('اعتماد'),
            ),
          ),
        ],
      );
    } else if (status == 'approved') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewWorkOrderDetails(workOrder),
              icon: const Icon(Icons.visibility),
              label: const Text('عرض التفاصيل'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _markAsDelivered(workOrder),
              icon: const Icon(Icons.delivery_dining),
              label: const Text('جاهز للتسليم'),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewRejectionDetails(workOrder),
              icon: const Icon(Icons.info),
              label: const Text('سبب الرفض'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _sendBackForRework(workOrder),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة للإصلاح'),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockWorkOrders(String status) {
    final allWorkOrders = [
      {
        'id': 1,
        'work_order_number': 'WO-2024-001',
        'customer_name': 'أحمد محمد',
        'vehicle_info': 'تويوتا كامري 2020',
        'status': 'pending_inspection',
        'completion_date': DateTime.now().subtract(const Duration(hours: 2)),
        'total_cost': 23000,
        'services_count': 2,
        'assigned_engineer': 'محمد أحمد',
        'total_duration': 75,
        'notes': 'تم الانتهاء من جميع الخدمات المطلوبة',
        'services': [
          {
            'name': 'تغيير زيت المحرك',
            'engineer': 'محمد أحمد',
            'cost': 15000,
            'duration': 30,
            'status': 'completed',
          },
          {
            'name': 'فحص الفرامل',
            'engineer': 'علي حسن',
            'cost': 8000,
            'duration': 45,
            'status': 'completed',
          },
        ],
      },
      {
        'id': 2,
        'work_order_number': 'WO-2024-002',
        'customer_name': 'فاطمة علي',
        'vehicle_info': 'هوندا سيفيك 2019',
        'status': 'approved',
        'completion_date': DateTime.now().subtract(const Duration(hours: 5)),
        'total_cost': 12000,
        'services_count': 1,
        'assigned_engineer': 'أحمد سالم',
        'total_duration': 20,
        'notes': 'عمل ممتاز في استبدال الشمعات',
        'services': [
          {
            'name': 'تغيير شمعات الإشعال',
            'engineer': 'أحمد سالم',
            'cost': 12000,
            'duration': 20,
            'status': 'completed',
          },
        ],
      },
      {
        'id': 3,
        'work_order_number': 'WO-2024-003',
        'customer_name': 'خالد يوسف',
        'vehicle_info': 'نيسان التيما 2018',
        'status': 'rejected',
        'completion_date': DateTime.now().subtract(const Duration(hours: 1)),
        'total_cost': 35000,
        'services_count': 3,
        'assigned_engineer': 'سعد محمد',
        'total_duration': 120,
        'notes': 'تم رفض العمل بسبب عدم اكتمال إصلاح نظام التكييف',
        'services': [
          {
            'name': 'إصلاح نظام التكييف',
            'engineer': 'سعد محمد',
            'cost': 25000,
            'duration': 90,
            'status': 'incomplete',
          },
          {
            'name': 'تغيير فلتر الهواء',
            'engineer': 'سعد محمد',
            'cost': 5000,
            'duration': 15,
            'status': 'completed',
          },
          {
            'name': 'فحص البطارية',
            'engineer': 'سعد محمد',
            'cost': 5000,
            'duration': 15,
            'status': 'completed',
          },
        ],
      },
    ];

    if (status == 'all') return allWorkOrders;
    return allWorkOrders.where((wo) => wo['status'] == status).toList();
  }

  Color _getWorkOrderStatusColor(String status) {
    switch (status) {
      case 'pending_inspection':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getWorkOrderStatusIcon(String status) {
    switch (status) {
      case 'pending_inspection':
        return Icons.search;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.assignment;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية أوامر العمل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedFilter,
              decoration: const InputDecoration(labelText: 'نوع التصفية'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('الكل')),
                DropdownMenuItem(value: 'urgent', child: Text('عاجلة')),
                DropdownMenuItem(
                  value: 'high_value',
                  child: Text('قيمة عالية'),
                ),
                DropdownMenuItem(value: 'complex', child: Text('معقدة')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ترتيب أوامر العمل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedSort,
              decoration: const InputDecoration(labelText: 'طريقة الترتيب'),
              items: const [
                DropdownMenuItem(value: 'date', child: Text('بالتاريخ')),
                DropdownMenuItem(value: 'priority', child: Text('بالأولوية')),
                DropdownMenuItem(value: 'value', child: Text('بالقيمة')),
                DropdownMenuItem(value: 'customer', child: Text('بالعميل')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  void _viewPhotosAndDetails(Map<String, dynamic> workOrder) {
    // Navigate to work order details page to view photos
    try {
      Navigator.of(context).pushNamed(
        '/work-order-details',
        arguments: {
          'workOrderId': workOrder['id'] ?? workOrder['work_order_id'],
          'workOrderNumber': workOrder['work_order_number'],
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في فتح التفاصيل: ${e.toString()}')),
      );
    }
  }

  void _approveWorkOrder(Map<String, dynamic> workOrder) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اعتماد أمر العمل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'هل أنت متأكد من اعتماد أمر العمل ${workOrder['work_order_number']}؟',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات الاعتماد (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performApproveWorkOrder(workOrder, notesController.text);
              notesController.dispose();
            },
            child: const Text('اعتماد'),
          ),
        ],
      ),
    );
  }

  void _rejectWorkOrder(Map<String, dynamic> workOrder) {
    final rejectionReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض أمر العمل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('لماذا تريد رفض أمر العمل ${workOrder['work_order_number']}؟'),
            const SizedBox(height: 16),
            TextFormField(
              controller: rejectionReasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض *',
                hintText: 'يرجى توضيح سبب الرفض...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'سبب الرفض مطلوب';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (rejectionReasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سبب الرفض مطلوب')),
                );
                return;
              }
              Navigator.pop(context);
              await _performRejectWorkOrder(
                workOrder,
                rejectionReasonController.text,
              );
              rejectionReasonController.dispose();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }

  void _viewWorkOrderDetails(Map<String, dynamic> workOrder) {
    // Navigate to work order details page
    try {
      Navigator.of(context).pushNamed(
        '/work-order-details',
        arguments: {
          'workOrderId': workOrder['id'] ?? workOrder['work_order_id'],
          'workOrderNumber': workOrder['work_order_number'],
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في فتح التفاصيل: ${e.toString()}')),
      );
    }
  }

  void _markAsDelivered(Map<String, dynamic> workOrder) async {
    try {
      final workOrderRepository = ref.read(workOrderRepositoryProvider);
      final workOrderId = workOrder['id'] ?? workOrder['work_order_id'];

      // Update work order status to 'completed'
      await workOrderRepository.updateWorkOrderStatus(workOrderId, 'completed');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديد أمر العمل كمنجز بنجاح')),
        );
        // Refresh the work orders list
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
      }
    }
  }

  void _viewRejectionDetails(Map<String, dynamic> workOrder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سبب الرفض'),
        content: Text(workOrder['notes'] ?? 'لا توجد تفاصيل'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _sendBackForRework(Map<String, dynamic> workOrder) async {
    try {
      final workOrderRepository = ref.read(workOrderRepositoryProvider);
      final workOrderId = workOrder['id'] ?? workOrder['work_order_id'];

      // Update work order status to 'in_progress' for rework
      await workOrderRepository.updateWorkOrderStatus(
        workOrderId,
        'in_progress',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال أمر العمل لإعادة الإصلاح بنجاح'),
          ),
        );
        // Refresh the work orders list
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
      }
    }
  }

  // Helper method to perform work order approval
  Future<void> _performApproveWorkOrder(
    Map<String, dynamic> workOrder,
    String notes,
  ) async {
    try {
      final workOrderRepository = ref.read(workOrderRepositoryProvider);
      final workOrderId = workOrder['id'] ?? workOrder['work_order_id'];

      // Update work order status to 'approved'
      await workOrderRepository.updateWorkOrderStatus(workOrderId, 'approved');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم اعتماد أمر العمل بنجاح')),
        );
        // Refresh the work orders list
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاعتماد: ${e.toString()}')),
        );
      }
    }
  }

  // Helper method to perform work order rejection
  Future<void> _performRejectWorkOrder(
    Map<String, dynamic> workOrder,
    String rejectionReason,
  ) async {
    try {
      final workOrderRepository = ref.read(workOrderRepositoryProvider);
      final workOrderId = workOrder['id'] ?? workOrder['work_order_id'];

      // Update work order status to 'rejected'
      await workOrderRepository.updateWorkOrderStatus(workOrderId, 'rejected');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم رفض أمر العمل')));
        // Refresh the work orders list
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الرفض: ${e.toString()}')),
        );
      }
    }
  }
}
