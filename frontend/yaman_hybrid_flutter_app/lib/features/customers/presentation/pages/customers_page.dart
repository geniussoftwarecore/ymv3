import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../generated/l10n.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final _searchController = TextEditingController();
  String _selectedSort = 'name';

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
          title: Text(S.of(context).customers),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
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
                hintText: 'البحث عن عميل...',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  // Handle search
                },
              ),
            ),

            // Customers List
            Expanded(
              child: _buildCustomersList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCustomerDialog,
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  Widget _buildCustomersList() {
    final customers = _getCustomers();

    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد عملاء',
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
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return _CustomerCard(customer: customer);
        },
      ),
    );
  }

  List<Customer> _getCustomers() {
    return [
      Customer(
        id: 'C001',
        firstName: 'أحمد',
        lastName: 'علي محمد',
        email: 'ahmed.ali@email.com',
        phone: '+966501234567',
        address: 'الرياض، حي النخيل، شارع الملك فهد',
        city: 'الرياض',
        country: 'السعودية',
        company: 'شركة النور للتجارة',
        totalWorkOrders: 15,
        totalSpent: 12500.0,
        lastVisit: DateTime(2024, 1, 15),
        isActive: true,
      ),
      Customer(
        id: 'C002',
        firstName: 'فاطمة',
        lastName: 'محمد سالم',
        email: 'fatima.mohammed@email.com',
        phone: '+966502345678',
        address: 'جدة، حي الصفا، شارع التحلية',
        city: 'جدة',
        country: 'السعودية',
        totalWorkOrders: 8,
        totalSpent: 6800.0,
        lastVisit: DateTime(2024, 1, 12),
        isActive: true,
      ),
      Customer(
        id: 'C003',
        firstName: 'محمد',
        lastName: 'سالم أحمد',
        email: 'mohammed.salem@email.com',
        phone: '+966503456789',
        address: 'الدمام، حي الفيصلية، شارع الأمير محمد',
        city: 'الدمام',
        country: 'السعودية',
        company: 'مؤسسة البحر الأزرق',
        totalWorkOrders: 22,
        totalSpent: 18900.0,
        lastVisit: DateTime(2024, 1, 10),
        isActive: true,
      ),
      Customer(
        id: 'C004',
        firstName: 'سارة',
        lastName: 'عبدالله حسن',
        email: 'sara.abdullah@email.com',
        phone: '+966504567890',
        address: 'مكة المكرمة، حي العزيزية، شارع إبراهيم الخليل',
        city: 'مكة المكرمة',
        country: 'السعودية',
        totalWorkOrders: 5,
        totalSpent: 3200.0,
        lastVisit: DateTime(2024, 1, 8),
        isActive: false,
      ),
    ];
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ترتيب العملاء'),
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
                title: Text(S.of(context).name),
                value: 'name',
              ),
              const RadioListTile<String>(
                title: Text('آخر زيارة'),
                value: 'last_visit',
              ),
              const RadioListTile<String>(
                title: Text('إجمالي الإنفاق'),
                value: 'total_spent',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).newCustomer),
        content: const Text('سيتم إضافة نموذج إنشاء عميل جديد هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle create customer
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;

  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to customer details
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
                    radius: 24,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    child: Text(
                      '${customer.firstName[0]}${customer.lastName[0]}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${customer.firstName} ${customer.lastName}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (customer.company != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            customer.company!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: customer.isActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Contact Info
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    customer.phone,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      customer.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${customer.city}, ${customer.country}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stats
              Row(
                children: [
                  _StatChip(
                    icon: Icons.work_outline,
                    label: 'أوامر العمل',
                    value: customer.totalWorkOrders.toString(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.attach_money,
                    label: 'إجمالي الإنفاق',
                    value: '${customer.totalSpent.toStringAsFixed(0)} ر.س',
                    color: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Last Visit
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'آخر زيارة: ${_formatDate(customer.lastVisit)}',
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
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
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
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String? company;
  final int totalWorkOrders;
  final double totalSpent;
  final DateTime lastVisit;
  final bool isActive;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    this.company,
    required this.totalWorkOrders,
    required this.totalSpent,
    required this.lastVisit,
    required this.isActive,
  });
}
