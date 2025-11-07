import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_client.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_dropdown.dart';

class AssignServicesPage extends ConsumerStatefulWidget {
  final int inspectionId;

  const AssignServicesPage({super.key, required this.inspectionId});

  @override
  ConsumerState<AssignServicesPage> createState() => _AssignServicesPageState();
}

class _AssignServicesPageState extends ConsumerState<AssignServicesPage> {
  final List<ServiceAssignment> _services = [];
  bool _isLoading = false;

  // Mock data - in real app, this would come from API
  final List<Map<String, dynamic>> _availableServices = [
    {
      'id': 1,
      'name': 'تغيير زيت المحرك',
      'estimatedDuration': 30,
      'basePrice': 15000,
    },
    {
      'id': 2,
      'name': 'فحص الفرامل',
      'estimatedDuration': 45,
      'basePrice': 10000,
    },
    {
      'id': 3,
      'name': 'تغيير البطارية',
      'estimatedDuration': 20,
      'basePrice': 35000,
    },
    {
      'id': 4,
      'name': 'إصلاح نظام الكهرباء',
      'estimatedDuration': 60,
      'basePrice': 25000,
    },
    {
      'id': 5,
      'name': 'صيانة التكييف',
      'estimatedDuration': 90,
      'basePrice': 30000,
    },
  ];

  final List<Map<String, dynamic>> _availableEngineers = [
    {'id': 1, 'name': 'أحمد محمد - ميكانيكي'},
    {'id': 2, 'name': 'محمد علي - كهربائي'},
    {'id': 3, 'name': 'فاطمة سالم - فني تكييف'},
    {'id': 4, 'name': 'علي حسن - فني فرامل'},
    {'id': 5, 'name': 'خالد أحمد - فني عام'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableServices();
  }

  Future<void> _loadAvailableServices() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get(
        APIConstants.serviceCatalogServiceUrl,
        APIEndpoints.services,
      );

      // Handle paginated response formats
      List<dynamic> servicesList = [];

      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is List<dynamic>) {
          servicesList = data;
        }
      } else if (response.containsKey('services')) {
        final services = response['services'];
        if (services is List<dynamic>) {
          servicesList = services;
        }
      } else {
        throw Exception(
          'Unexpected API response format: no data or services key',
        );
      }

      if (servicesList.isEmpty) {
        throw Exception('No services found in API response');
      }

      // Parse services into the format expected by the UI
      final parsedServices = servicesList.map((service) {
        return {
          'id': service['id'] ?? service['serviceId'],
          'name': service['name'] ?? service['serviceName'] ?? '',
          'estimatedDuration':
              service['estimatedDuration'] ?? service['duration'] ?? 0,
          'basePrice': service['basePrice'] ?? service['price'] ?? 0,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _availableServices.clear();
          _availableServices.addAll(parsedServices);
          _isLoading = false;
        });
      }
    } catch (e) {
      // If API fails, show error but keep mock data as fallback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الخدمات: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تعيين الخدمات'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            TextButton(
              onPressed: _saveAssignments,
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        Icon(
                          Icons.build,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'فحص رقم ${widget.inspectionId}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'تعيين الخدمات المطلوبة والمهندسين المختصين',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Services List
                  Expanded(
                    child: _services.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _services.length,
                            itemBuilder: (context, index) {
                              return _buildServiceCard(_services[index], index);
                            },
                          ),
                  ),

                  // Add Service Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _addService,
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة خدمة'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_circle, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات محددة',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على "إضافة خدمة" لبدء تعيين الخدمات المطلوبة',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addService,
            icon: const Icon(Icons.add),
            label: const Text('إضافة خدمة أولى'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceAssignment service, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.serviceName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeService(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'حذف الخدمة',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Service Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'المدة المقدرة',
                    '${service.estimatedDuration} دقيقة',
                    Icons.access_time,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'التكلفة المقدرة',
                    '${service.estimatedCost?.toStringAsFixed(0) ?? 'غير محدد'} ريال',
                    Icons.attach_money,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Engineer Assignment
            CustomDropdown<Map<String, dynamic>>(
              labelText: 'المهندس المكلف',
              hintText: 'اختر المهندس المختص',
              value: service.assignedEngineer,
              items: _availableEngineers,
              onChanged: (engineer) {
                setState(() {
                  _services[index] = service.copyWith(
                    assignedEngineer: engineer,
                  );
                });
              },
              displayText: (engineer) => engineer?['name'] ?? '',
            ),

            const SizedBox(height: 12),

            // Priority
            CustomDropdown<String>(
              labelText: 'الأولوية',
              hintText: 'اختر الأولوية',
              value: service.priority,
              items: const ['منخفض', 'متوسط', 'عالي', 'حرج'],
              onChanged: (priority) {
                setState(() {
                  _services[index] = service.copyWith(priority: priority);
                });
              },
            ),

            const SizedBox(height: 12),

            // Notes
            CustomTextField(
              controller: TextEditingController(text: service.notes),
              labelText: 'ملاحظات',
              hintText: 'ملاحظات إضافية حول الخدمة',
              maxLines: 2,
              onChanged: (notes) {
                setState(() {
                  _services[index] = service.copyWith(notes: notes);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختيار خدمة'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableServices.length,
            itemBuilder: (context, index) {
              final service = _availableServices[index];
              return ListTile(
                title: Text(service['name']),
                subtitle: Text(
                  '${service['estimatedDuration']} دقيقة - ${service['basePrice']} ريال',
                ),
                onTap: () {
                  setState(() {
                    _services.add(
                      ServiceAssignment(
                        serviceId: service['id'],
                        serviceName: service['name'],
                        estimatedDuration: service['estimatedDuration'],
                        estimatedCost: service['basePrice'].toDouble(),
                        priority: 'متوسط',
                      ),
                    );
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  Future<void> _saveAssignments() async {
    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة خدمة واحدة على الأقل')),
      );
      return;
    }

    // Check if all services have assigned engineers
    final unassignedServices = _services
        .where((s) => s.assignedEngineer == null)
        .toList();
    if (unassignedServices.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعيين مهندس لكل خدمة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();

      // Prepare the payload
      final payload = {
        'inspectionId': widget.inspectionId,
        'services': _services.map((service) {
          return {
            'serviceId': service.serviceId,
            'engineerId': service.assignedEngineer?['id'],
            'priority': service.priority,
            'estimatedDuration': service.estimatedDuration,
            'estimatedCost': service.estimatedCost,
            'notes': service.notes,
          };
        }).toList(),
      };

      // Save assignments to backend
      await apiClient.post(
        APIConstants.workOrderManagementServiceUrl,
        '${APIEndpoints.inspections}/${widget.inspectionId}/assign-services',
        payload,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ تعيينات الخدمات بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ التعيينات: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

class ServiceAssignment {
  final int? serviceId;
  final String serviceName;
  final int? estimatedDuration;
  final double? estimatedCost;
  final Map<String, dynamic>? assignedEngineer;
  final String priority;
  final String? notes;

  const ServiceAssignment({
    this.serviceId,
    required this.serviceName,
    this.estimatedDuration,
    this.estimatedCost,
    this.assignedEngineer,
    this.priority = 'متوسط',
    this.notes,
  });

  ServiceAssignment copyWith({
    int? serviceId,
    String? serviceName,
    int? estimatedDuration,
    double? estimatedCost,
    Map<String, dynamic>? assignedEngineer,
    String? priority,
    String? notes,
  }) {
    return ServiceAssignment(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      assignedEngineer: assignedEngineer ?? this.assignedEngineer,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
    );
  }
}
