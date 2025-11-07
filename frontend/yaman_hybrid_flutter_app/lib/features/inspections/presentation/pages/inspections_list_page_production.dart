import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/api/repositories/inspection_repository.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class InspectionsListPageProduction extends ConsumerStatefulWidget {
  const InspectionsListPageProduction({super.key});

  @override
  ConsumerState<InspectionsListPageProduction> createState() =>
      _InspectionsListPageState();
}

class _InspectionsListPageState
    extends ConsumerState<InspectionsListPageProduction> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'all';
  String _selectedSort = 'date';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInspections();
    });
  }

  void _fetchInspections() {
    final inspectionsNotifier = ref.read(inspectionsProvider.notifier);
    inspectionsNotifier.fetchInspections();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final inspectionsState = ref.watch(inspectionsProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('فحوصات المركبات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showCreateInspectionDialog();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _searchController,
                    hintText: 'البحث في الفحوصات...',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {}); // Trigger rebuild for search filtering
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'الحالة',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('الكل')),
                            DropdownMenuItem(
                                value: 'Draft', child: Text('مسودة')),
                            DropdownMenuItem(
                                value: 'In_Progress',
                                child: Text('قيد التنفيذ')),
                            DropdownMenuItem(
                                value: 'Completed', child: Text('مكتملة')),
                            DropdownMenuItem(
                                value: 'Converted_to_Work_Order',
                                child: Text('محولة لأمر عمل')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedStatus = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedSort,
                          decoration: const InputDecoration(
                            labelText: 'الترتيب',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'date', child: Text('بالتاريخ')),
                            DropdownMenuItem(
                                value: 'vehicle', child: Text('بالمركبة')),
                            DropdownMenuItem(
                                value: 'status', child: Text('بالحالة')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedSort = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Inspections List
            Expanded(
              child: _buildInspectionsList(inspectionsState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionsList(InspectionsState state) {
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
              onPressed: _fetchInspections,
              child: const Text('إعادة محاولة'),
            ),
          ],
        ),
      );
    }

    var inspections = state.inspections;

    // Apply status filter
    if (_selectedStatus != 'all') {
      inspections =
          inspections.where((i) => i.status == _selectedStatus).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      inspections = inspections
          .where((i) =>
              i.inspectionNumber.toLowerCase().contains(query) ||
              (i.vehicleMake?.toLowerCase().contains(query) ?? false) ||
              (i.vehicleModel?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'date':
        inspections.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'vehicle':
        inspections.sort((a, b) => '${a.vehicleMake} ${a.vehicleModel}'
            .compareTo('${b.vehicleMake} ${b.vehicleModel}'));
        break;
      case 'status':
        inspections.sort((a, b) => a.status.compareTo(b.status));
        break;
    }

    if (inspections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.withAlpha((0.5 * 255).toInt()),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد فحوصات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة فحص جديد',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _fetchInspections();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: inspections.length,
        itemBuilder: (context, index) {
          final inspection = inspections[index];
          return _InspectionCard(inspection: inspection);
        },
      ),
    );
  }

  void _showCreateInspectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فحص جديد'),
        content: const Text('سيتم إضافة نموذج إنشاء فحص جديد'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }
}

class _InspectionCard extends StatelessWidget {
  final InspectionModel inspection;

  const _InspectionCard({required this.inspection});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to inspection details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('عرض تفاصيل الفحص ${inspection.inspectionNumber}'),
            ),
          );
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
                  CircleAvatar(
                    backgroundColor: _getStatusColor(inspection.status),
                    child: Icon(
                      _getStatusIcon(inspection.status),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فحص رقم ${inspection.inspectionNumber}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getStatusText(inspection.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(inspection.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showActionMenu(context, inspection);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Vehicle Info
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${inspection.vehicleMake ?? ''} ${inspection.vehicleModel ?? ''}'
                          .trim(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              if (inspection.vehicleVin != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.confirmation_number, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'VIN: ${inspection.vehicleVin}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DateFormat('yyyy/MM/dd HH:mm')
                          .format(inspection.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
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

  void _showActionMenu(BuildContext context, InspectionModel inspection) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('عرض التفاصيل'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('عرض: ${inspection.inspectionNumber}')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('تعديل'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('تعديل: ${inspection.inspectionNumber}')),
              );
            },
          ),
          if (inspection.status == 'Completed')
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('إنشاء عرض أسعار'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('إنشاء عرض لـ ${inspection.inspectionNumber}'),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('حذف', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, inspection);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, InspectionModel inspection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
            'هل أنت متأكد من رغبتك في حذف الفحص ${inspection.inspectionNumber}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('تم حذف ${inspection.inspectionNumber}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Draft':
        return Colors.grey;
      case 'In_Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Converted_to_Work_Order':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Draft':
        return Icons.edit;
      case 'In_Progress':
        return Icons.hourglass_bottom;
      case 'Completed':
        return Icons.check_circle;
      case 'Converted_to_Work_Order':
        return Icons.assignment;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Draft':
        return 'مسودة';
      case 'In_Progress':
        return 'قيد التنفيذ';
      case 'Completed':
        return 'مكتملة';
      case 'Converted_to_Work_Order':
        return 'محولة لأمر عمل';
      default:
        return status;
    }
  }
}
