import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/api/repositories/work_order_repository.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class DeliveryPage extends ConsumerStatefulWidget {
  const DeliveryPage({super.key});

  @override
  ConsumerState<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends ConsumerState<DeliveryPage>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _customerNotesController = TextEditingController();
  final _feedbackController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  late TabController _tabController;
  String _selectedFilter = 'all';
  String _selectedSort = 'date';

  bool _acceptTerms = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDeliveries();
    });
  }

  void _fetchDeliveries() {
    final workOrdersNotifier = ref.read(workOrdersProvider.notifier);
    workOrdersNotifier.fetchWorkOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _customerNotesController.dispose();
    _feedbackController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final workOrdersState = ref.watch(workOrdersProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسليم المركبات'),
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
              Tab(text: 'جاهزة للتسليم'),
              Tab(text: 'مُسلمة'),
              Tab(text: 'مؤجلة'),
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
                hintText: 'البحث في أوامر التسليم...',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild for search filtering
                },
              ),
            ),

            // Work Orders List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDeliveryList(workOrdersState, 'ready_for_delivery'),
                  _buildDeliveryList(workOrdersState, 'delivered'),
                  _buildDeliveryList(workOrdersState, 'postponed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryList(WorkOrdersState state, String statusFilter) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withAlpha((0.5 * 255).toInt()),
            ),
            const SizedBox(height: 16),
            Text(
              'خطأ: ${state.error}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _fetchDeliveries,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة محاولة'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('العودة للرئيسية'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final filteredDeliveries = statusFilter == 'all'
        ? state.workOrders
        : state.workOrders.where((wo) => wo.status == statusFilter).toList();

    if (filteredDeliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد مركبات جاهزة للتسليم',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _fetchDeliveries();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredDeliveries.length,
        itemBuilder: (context, index) {
          final delivery = filteredDeliveries[index];
          return _DeliveryCard(
            workOrder: delivery,
            onTap: () => _showDeliveryDialog(delivery),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية عمليات التسليم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('الكل'),
              value: 'all',
              selected: _selectedFilter == 'all',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('جاهزة للتسليم'),
              value: 'ready',
              selected: _selectedFilter == 'ready',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('مُسلمة'),
              value: 'delivered',
              selected: _selectedFilter == 'delivered',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ترتيب عمليات التسليم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('التاريخ'),
              value: 'date',
              selected: _selectedSort == 'date',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSort = value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('اسم العميل'),
              value: 'customer',
              selected: _selectedSort == 'customer',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSort = value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('التكلفة'),
              value: 'cost',
              selected: _selectedSort == 'cost',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSort = value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryDialog(WorkOrderModel delivery) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('تسليم المركبة - ${delivery.workOrderNumber}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information
                Text(
                  'معلومات العميل',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('الاسم: ${delivery.customerName}'),
                Text('الهاتف: ${delivery.customerPhone ?? "غير محدد"}'),
                Text('العنوان: ${delivery.customerAddress ?? "غير محدد"}'),
                const SizedBox(height: 16),

                // Vehicle Information
                Text(
                  'معلومات المركبة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('المركبة: ${delivery.vehicleInfo}'),
                Text('إجمالي التكلفة: ${delivery.totalCost} ريال'),
                const SizedBox(height: 16),

                // Customer Notes
                CustomTextField(
                  controller: _customerNotesController,
                  labelText: 'ملاحظات العميل',
                  hintText: 'أي ملاحظات من العميل...',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Terms and Conditions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withAlpha(77)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الشروط والأحكام',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• أقر بأنني استلمت المركبة بحالة جيدة\n'
                        '• أقر بأن جميع الإصلاحات تمت بكفاءة\n'
                        '• أوافق على الضمان المقدم من الورشة\n'
                        '• أتعهد بدفع المبلغ المستحق',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'أوافق على جميع الشروط والأحكام',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _customerNotesController.clear();
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _acceptTerms && !_isSubmitting
                  ? () async {
                      setState(() => _isSubmitting = true);
                      try {
                        // Complete delivery API call here
                        await ref
                            .read(workOrderRepositoryProvider)
                            .completeWorkOrder(delivery.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إكمال التسليم بنجاح'),
                            ),
                          );
                          _fetchDeliveries();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                        }
                      }
                    }
                  : null,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('تأكيد التسليم'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final WorkOrderModel workOrder;
  final VoidCallback? onTap;

  const _DeliveryCard({required this.workOrder, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      workOrder.workOrderNumber,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        workOrder.status,
                      ).withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(workOrder.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(workOrder.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workOrder.customerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.directions_car_outlined, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workOrder.vehicleInfo,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التكلفة: ${workOrder.totalCost} ريال',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    DateFormat('yyyy/MM/dd').format(workOrder.scheduledDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.blue;
      case 'ready_for_delivery':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'postponed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'ready_for_delivery':
        return 'جاهزة للتسليم';
      case 'delivered':
        return 'مُسلمة';
      case 'postponed':
        return 'مؤجلة';
      default:
        return status;
    }
  }
}
