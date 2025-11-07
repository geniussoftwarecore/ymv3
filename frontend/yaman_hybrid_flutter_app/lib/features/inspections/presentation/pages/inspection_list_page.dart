import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/inspection_entity.dart';
import './create_inspection_page.dart';

class InspectionListPage extends StatefulWidget {
  const InspectionListPage({super.key});

  @override
  State<InspectionListPage> createState() => _InspectionListPageState();
}

class _InspectionListPageState extends State<InspectionListPage> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'all';
  String _selectedSort = 'date';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockInspections = _getMockInspections();

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('فحوصات المركبات'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateInspectionPage(),
                  ),
                );
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
                      // Implement search
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
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('الكل')),
                            DropdownMenuItem(
                                value: 'draft', child: Text('مسودة')),
                            DropdownMenuItem(
                                value: 'in_progress',
                                child: Text('قيد التنفيذ')),
                            DropdownMenuItem(
                                value: 'completed', child: Text('مكتملة')),
                            DropdownMenuItem(
                                value: 'converted',
                                child: Text('محولة لأمر عمل')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
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
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'date', child: Text('بالتاريخ')),
                            DropdownMenuItem(
                                value: 'customer', child: Text('بالعميل')),
                            DropdownMenuItem(
                                value: 'status', child: Text('بالحالة')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSort = value!;
                            });
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
              child: Builder(
                builder: (context) {
                  final inspections = mockInspections;
                  if (inspections.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'لا توجد فحوصات',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Builder(
                            builder: (ctx) => Text(
                              'ابدأ بإضافة فحص جديد',
                              style:
                                  Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: inspections.length,
                    itemBuilder: (context, index) {
                      final inspection = inspections[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(inspection.status),
                            child: Icon(
                              _getStatusIcon(inspection.status),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'فحص رقم ${inspection.inspectionNumber ?? inspection.id}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${inspection.vehicleMake ?? ''} ${inspection.vehicleModel ?? ''}'
                                    .trim(),
                              ),
                              Text(
                                'تاريخ الإنشاء: ${DateFormat('yyyy/MM/dd').format(inspection.createdAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'view':
                                  Navigator.pushNamed(
                                    context,
                                    '/inspections/${inspection.id}',
                                  );
                                  break;
                                case 'edit':
                                  Navigator.pushNamed(
                                    context,
                                    '/inspections/${inspection.id}/edit',
                                  );
                                  break;
                                case 'create_quote':
                                  _navigateToCreateQuote(context, inspection);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Text('عرض'),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('تعديل'),
                              ),
                              if (inspection.status ==
                                  InspectionStatus.completed)
                                const PopupMenuItem(
                                  value: 'create_quote',
                                  child: Text('إنشاء عرض أسعار'),
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/inspections/${inspection.id}',
                            );
                          },
                        ),
                      );
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

  List<InspectionEntity> _getMockInspections() {
    return [
      InspectionEntity(
        id: 1,
        customerId: 1,
        vehicleMake: 'Toyota',
        vehicleModel: 'Camry',
        status: InspectionStatus.completed,
        inspectionType: InspectionType.standard,
        createdBy: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      InspectionEntity(
        id: 2,
        customerId: 2,
        vehicleMake: 'Honda',
        vehicleModel: 'Accord',
        status: InspectionStatus.inProgress,
        inspectionType: InspectionType.standard,
        createdBy: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now(),
      ),
      InspectionEntity(
        id: 3,
        customerId: 3,
        vehicleMake: 'Ford',
        vehicleModel: 'Focus',
        status: InspectionStatus.draft,
        inspectionType: InspectionType.custom,
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Color _getStatusColor(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.draft:
        return Colors.grey;
      case InspectionStatus.inProgress:
        return Colors.blue;
      case InspectionStatus.completed:
        return Colors.green;
      case InspectionStatus.convertedToWorkOrder:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.draft:
        return Icons.description;
      case InspectionStatus.inProgress:
        return Icons.pending;
      case InspectionStatus.completed:
        return Icons.check_circle;
      case InspectionStatus.convertedToWorkOrder:
        return Icons.transform;
    }
  }

  void _navigateToCreateQuote(
      BuildContext context, InspectionEntity inspection) {
    // Mock data - in real app, this would come from API
    final inspectionServices = [
      {
        'service_name': 'تغيير زيت المحرك',
        'estimated_cost': 15000.0,
        'estimated_duration': 30,
        'notes': 'زيت محرك كامل مع فلتر',
      },
      {
        'service_name': 'فحص الفرامل',
        'estimated_cost': 8000.0,
        'estimated_duration': 45,
        'notes': 'فحص شامل لنظام الفرامل',
      },
    ];

    final customerInfo = {
      'id': inspection.customerId,
      'name': 'العميل ${inspection.customerId}',
      'phone': '+967-1-234567',
    };

    final vehicleInfo = {
      'make': inspection.vehicleMake ?? 'غير محدد',
      'model': inspection.vehicleModel ?? 'غير محدد',
      'license_plate': inspection.vehicleLicensePlate ?? 'غير محدد',
    };

    NavigationService.goToCreateQuote(
      inspectionId: inspection.id!,
      inspectionServices: inspectionServices,
      customerInfo: customerInfo,
      vehicleInfo: vehicleInfo,
    );
  }
}
