import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/api/repositories/work_order_repository.dart';

class WorkOrdersPage extends ConsumerStatefulWidget {
  const WorkOrdersPage({super.key});

  @override
  ConsumerState<WorkOrdersPage> createState() => _WorkOrdersPageState();
}

class _WorkOrdersPageState extends ConsumerState<WorkOrdersPage>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  String _selectedFilter = 'all';
  String _selectedSort = 'date';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Fetch work orders when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWorkOrders();
    });
  }

  void _fetchWorkOrders() {
    final workOrdersNotifier = ref.read(workOrdersProvider.notifier);
    workOrdersNotifier.fetchWorkOrders();
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
    final workOrdersState = ref.watch(workOrdersProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).workOrders),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              const Tab(text: 'الكل'),
              Tab(text: S.of(context).pending),
              Tab(text: S.of(context).inProgress),
              Tab(text: S.of(context).completed),
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
                hintText: S.of(context).search,
                prefixIcon: Icons.search,
                onChanged: (value) {
                  // Handle search - could filter local list
                },
              ),
            ),

            // Work Orders List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWorkOrdersList(workOrdersState, 'all'),
                  _buildWorkOrdersList(workOrdersState, 'pending'),
                  _buildWorkOrdersList(workOrdersState, 'in_progress'),
                  _buildWorkOrdersList(workOrdersState, 'completed'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddWorkOrderDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildWorkOrdersList(WorkOrdersState state, String statusFilter) {
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWorkOrders,
              child: const Text('إعادة محاولة'),
            ),
          ],
        ),
      );
    }

    final filteredOrders = statusFilter == 'all'
        ? state.workOrders
        : state.workOrders.where((wo) => wo.status == statusFilter).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlpha((0.3 * 255).toInt()),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).noData,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _fetchWorkOrders();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final workOrder = filteredOrders[index];
          return _WorkOrderCard(workOrder: workOrder);
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية أوامر العمل'),
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
              title: Text(S.of(context).high),
              value: 'high',
              selected: _selectedFilter == 'high',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(S.of(context).medium),
              value: 'medium',
              selected: _selectedFilter == 'medium',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(S.of(context).low),
              value: 'low',
              selected: _selectedFilter == 'low',
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
        title: const Text('ترتيب أوامر العمل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(S.of(context).date),
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
              title: Text(S.of(context).priority),
              value: 'priority',
              selected: _selectedSort == 'priority',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSort = value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(S.of(context).customerName),
              value: 'customer',
              selected: _selectedSort == 'customer',
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

  void _showAddWorkOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).newWorkOrder),
        content: const Text('سيتم إضافة نموذج إنشاء أمر عمل جديد هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle create work order
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }
}

class _WorkOrderCard extends ConsumerWidget {
  final WorkOrderModel workOrder;

  const _WorkOrderCard({required this.workOrder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to work order details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                      _getStatusText(context, workOrder.status),
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

              // Customer and Vehicle Info
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                  ),
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
                  Icon(
                    Icons.directions_car_outlined,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workOrder.vehicleInfo,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DateFormat('yyyy/MM/dd').format(workOrder.scheduledDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${workOrder.services.length} خدمات',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${workOrder.totalCost.toStringAsFixed(0)} ر.س',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return S.of(context).pending;
      case 'in_progress':
        return S.of(context).inProgress;
      case 'completed':
        return S.of(context).completed;
      case 'cancelled':
        return S.of(context).cancelled;
      default:
        return status;
    }
  }
}
