import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/api/repositories/customer_repository.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class CustomersListPageProduction extends ConsumerStatefulWidget {
  const CustomersListPageProduction({super.key});

  @override
  ConsumerState<CustomersListPageProduction> createState() =>
      _CustomersListPageState();
}

class _CustomersListPageState
    extends ConsumerState<CustomersListPageProduction> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'active';
  String _selectedSort = 'name';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCustomers();
    });
  }

  void _fetchCustomers() {
    final customersNotifier = ref.read(customersProvider.notifier);
    customersNotifier.fetchCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final customersState = ref.watch(customersProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('العملاء'),
          elevation: 0,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateCustomerDialog(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _searchController,
                    hintText: 'البحث عن عميل...',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {});
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
                            DropdownMenuItem(
                                value: 'active', child: Text('نشط')),
                            DropdownMenuItem(
                                value: 'inactive', child: Text('غير نشط')),
                            DropdownMenuItem(value: 'all', child: Text('الكل')),
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
                                value: 'name', child: Text('الاسم')),
                            DropdownMenuItem(
                                value: 'date', child: Text('التاريخ')),
                            DropdownMenuItem(
                                value: 'phone', child: Text('الهاتف')),
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

            // Customers List
            Expanded(
              child: _buildCustomersList(customersState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomersList(CustomersState state) {
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
                  onPressed: _fetchCustomers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة محاولة'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('رجوع'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    var customers = state.customers;

    // Apply status filter
    if (_selectedStatus != 'all') {
      customers = customers.where((c) => c.status == _selectedStatus).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      customers = customers
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.email.toLowerCase().contains(query) ||
              c.phone.toLowerCase().contains(query))
          .toList();
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'name':
        customers.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'phone':
        customers.sort((a, b) => a.phone.compareTo(b.phone));
        break;
    }

    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.withAlpha((0.5 * 255).toInt()),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد عملاء',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف عميل جديد للبدء',
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
        _fetchCustomers();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return _CustomerCard(customer: customer);
        },
      ),
    );
  }

  void _showCreateCustomerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('عميل جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Display
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(26),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                CustomTextField(
                  controller: nameController,
                  labelText: 'الاسم',
                  hintText: 'اسم العميل',
                  enabled: errorMessage == null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: emailController,
                  labelText: 'البريد الإلكتروني',
                  hintText: 'example@email.com',
                  enabled: errorMessage == null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: phoneController,
                  labelText: 'رقم الهاتف',
                  hintText: '+966500000000',
                  enabled: errorMessage == null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: addressController,
                  labelText: 'العنوان',
                  hintText: 'عنوان العميل',
                  maxLines: 2,
                  enabled: errorMessage == null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق', style: TextStyle(color: Colors.red)),
            ),
            if (errorMessage != null)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    errorMessage = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة محاولة'),
              )
            else ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validation
                  if (nameController.text.isEmpty) {
                    setState(() {
                      errorMessage = 'يرجى إدخال اسم العميل';
                    });
                    return;
                  }
                  if (emailController.text.isEmpty) {
                    setState(() {
                      errorMessage = 'يرجى إدخال البريد الإلكتروني';
                    });
                    return;
                  }
                  if (phoneController.text.isEmpty) {
                    setState(() {
                      errorMessage = 'يرجى إدخال رقم الهاتف';
                    });
                    return;
                  }

                  try {
                    final request = CreateCustomerRequest(
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                    );

                    await ref
                        .read(customersProvider.notifier)
                        .createCustomer(request);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة العميل بنجاح')),
                      );
                      _fetchCustomers();
                    }
                  } catch (e) {
                    setState(() {
                      errorMessage = 'فشل في إضافة العميل: ${e.toString()}';
                    });
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showCustomerDetails(context, customer);
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
                    backgroundColor: Colors.blue.withAlpha((0.1 * 255).toInt()),
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(customer.status)
                                .withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            customer.status == 'active' ? 'نشط' : 'غير نشط',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(customer.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showActionMenu(context, customer),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Contact Info
              Row(
                children: [
                  const Icon(Icons.email, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      customer.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      customer.phone,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (customer.address != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customer.address!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'انضم في: ${DateFormat('yyyy/MM/dd').format(customer.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, CustomerModel customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل العميل',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _DetailRow('الاسم:', customer.name),
            _DetailRow('البريد الإلكتروني:', customer.email),
            _DetailRow('الهاتف:', customer.phone),
            if (customer.address != null)
              _DetailRow('العنوان:', customer.address!),
            if (customer.city != null) _DetailRow('المدينة:', customer.city!),
            if (customer.country != null)
              _DetailRow('الدولة:', customer.country!),
            if (customer.idNumber != null)
              _DetailRow('رقم الهوية:', customer.idNumber!),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('تعديل'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تعديل: ${customer.name}')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_box),
                    label: const Text('أمر عمل جديد'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('أمر جديد ل ${customer.name}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context, CustomerModel customer) {
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
              _showCustomerDetails(context, customer);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('تعديل'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تعديل: ${customer.name}')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('أمر عمل جديد'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('أمر جديد ل ${customer.name}')),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return status == 'active' ? Colors.green : Colors.grey;
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
