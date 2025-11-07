import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../generated/l10n.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class VehiclesPage extends ConsumerStatefulWidget {
  const VehiclesPage({super.key});

  @override
  ConsumerState<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends ConsumerState<VehiclesPage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _selectedSort = 'make';

  @override
  void dispose() {
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
          title: Text(S.of(context).vehicles),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
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
                hintText: 'البحث عن مركبة...',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  // Handle search
                },
              ),
            ),

            // Vehicles List
            Expanded(
              child: _buildVehiclesList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddVehicleDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildVehiclesList() {
    final vehicles = _getVehicles();

    if (vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد مركبات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return _VehicleCard(vehicle: vehicle);
        },
      ),
    );
  }

  List<Vehicle> _getVehicles() {
    return [
      Vehicle(
        id: 'V001',
        make: 'تويوتا',
        model: 'كامري',
        year: 2020,
        color: 'أبيض',
        plateNumber: 'أ ب ج 1234',
        vin: '1HGBH41JXMN109186',
        mileage: 45000,
        fuelType: 'gasoline',
        ownerName: 'أحمد علي محمد',
        ownerId: 'C001',
        lastServiceDate: DateTime(2024, 1, 15),
        nextServiceDue: DateTime(2024, 4, 15),
        totalWorkOrders: 8,
        isActive: true,
      ),
      Vehicle(
        id: 'V002',
        make: 'هوندا',
        model: 'أكورد',
        year: 2019,
        color: 'أسود',
        plateNumber: 'د هـ و 5678',
        vin: '1HGCV1F30JA123456',
        mileage: 62000,
        fuelType: 'gasoline',
        ownerName: 'فاطمة محمد سالم',
        ownerId: 'C002',
        lastServiceDate: DateTime(2024, 1, 10),
        nextServiceDue: DateTime(2024, 4, 10),
        totalWorkOrders: 12,
        isActive: true,
      ),
      Vehicle(
        id: 'V003',
        make: 'نيسان',
        model: 'التيما',
        year: 2021,
        color: 'فضي',
        plateNumber: 'ز ح ط 9012',
        vin: '1N4AL3AP5JC123456',
        mileage: 28000,
        fuelType: 'gasoline',
        ownerName: 'محمد سالم أحمد',
        ownerId: 'C003',
        lastServiceDate: DateTime(2024, 1, 8),
        nextServiceDue: DateTime(2024, 4, 8),
        totalWorkOrders: 5,
        isActive: true,
      ),
      Vehicle(
        id: 'V004',
        make: 'هيونداي',
        model: 'إلنترا',
        year: 2018,
        color: 'أحمر',
        plateNumber: 'ي ك ل 3456',
        vin: 'KMHD14JA5JA123456',
        mileage: 78000,
        fuelType: 'gasoline',
        ownerName: 'سارة عبدالله حسن',
        ownerId: 'C004',
        lastServiceDate: DateTime(2023, 12, 20),
        nextServiceDue: DateTime(2024, 3, 20),
        totalWorkOrders: 15,
        isActive: false,
      ),
    ];
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية المركبات'),
        content: RadioGroup<String>(
          groupValue: _selectedFilter,
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _selectedFilter = value;
            });
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RadioListTile<String>(
                title: Text('الكل'),
                value: 'all',
              ),
              RadioListTile<String>(
                title: Text(S.of(context).gasoline),
                value: 'gasoline',
              ),
              RadioListTile<String>(
                title: Text(S.of(context).diesel),
                value: 'diesel',
              ),
              RadioListTile<String>(
                title: Text(S.of(context).hybrid),
                value: 'hybrid',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ترتيب المركبات'),
        content: RadioGroup<String>(
          groupValue: _selectedSort,
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _selectedSort = value;
            });
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(S.of(context).make),
                value: 'make',
              ),
              RadioListTile<String>(
                title: Text(S.of(context).year),
                value: 'year',
              ),
              RadioListTile<String>(
                title: Text(S.of(context).mileage),
                value: 'mileage',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).newVehicle),
        content: const Text('سيتم إضافة نموذج إنشاء مركبة جديدة هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle create vehicle
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final isServiceDue = vehicle.nextServiceDue
        .isBefore(DateTime.now().add(const Duration(days: 30)));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to vehicle details
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getVehicleColor(vehicle.color)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: _getVehicleColor(vehicle.color),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.make} ${vehicle.model}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${vehicle.year} • ${vehicle.color}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (isServiceDue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(26, 255, 152, 0),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_outlined,
                            size: 14,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'صيانة مستحقة',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Vehicle Info
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vehicle.plateNumber,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.local_gas_station_outlined,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getFuelTypeText(context, vehicle.fuelType),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vehicle.ownerName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stats Row
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.speed,
                    label: '${vehicle.mileage.toStringAsFixed(0)} كم',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.build_outlined,
                    label: '${vehicle.totalWorkOrders} أوامر',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: vehicle.isActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Service Info
              Row(
                children: [
                  Icon(
                    Icons.build_circle_outlined,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'آخر صيانة: ${_formatDate(vehicle.lastServiceDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'الصيانة القادمة: ${_formatDate(vehicle.nextServiceDue)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isServiceDue
                              ? Colors.orange
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                          fontWeight: isServiceDue
                              ? FontWeight.w500
                              : FontWeight.normal,
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

  Color _getVehicleColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'أبيض':
      case 'white':
        return Colors.grey;
      case 'أسود':
      case 'black':
        return Colors.black87;
      case 'أحمر':
      case 'red':
        return Colors.red;
      case 'أزرق':
      case 'blue':
        return Colors.blue;
      case 'أخضر':
      case 'green':
        return Colors.green;
      case 'فضي':
      case 'silver':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  String _getFuelTypeText(BuildContext context, String fuelType) {
    switch (fuelType) {
      case 'gasoline':
        return S.of(context).gasoline;
      case 'diesel':
        return S.of(context).diesel;
      case 'electric':
        return S.of(context).electric;
      case 'hybrid':
        return S.of(context).hybrid;
      default:
        return fuelType;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String color;
  final String plateNumber;
  final String vin;
  final double mileage;
  final String fuelType;
  final String ownerName;
  final String ownerId;
  final DateTime lastServiceDate;
  final DateTime nextServiceDue;
  final int totalWorkOrders;
  final bool isActive;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
    required this.vin,
    required this.mileage,
    required this.fuelType,
    required this.ownerName,
    required this.ownerId,
    required this.lastServiceDate,
    required this.nextServiceDue,
    required this.totalWorkOrders,
    required this.isActive,
  });
}
