import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();
  final Map<int, List<String>> _taskPhotos =
      {}; // Task ID -> list of photo paths

  String _selectedFilter = 'all';
  String _selectedSort = 'date';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          title: const Text('مهامي'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'معلقة'),
              Tab(text: 'قيد التنفيذ'),
              Tab(text: 'مكتملة'),
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
                hintText: 'البحث في المهام...',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  // Handle search
                },
              ),
            ),

            // Tasks List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTasksList('all'),
                  _buildTasksList('pending'),
                  _buildTasksList('in_progress'),
                  _buildTasksList('completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(String status) {
    // Mock data - in real app, this would come from provider
    final mockTasks = _getMockTasks(status);

    if (mockTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد مهام',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockTasks.length,
      itemBuilder: (context, index) {
        final task = mockTasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getTaskStatusColor(task['status']),
              child: Icon(
                _getTaskStatusIcon(task['status']),
                color: Colors.white,
              ),
            ),
            title: Text(task['service_name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أمر العمل: ${task['work_order_number']}'),
                Text(
                  'العميل: ${task['customer_name']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'الموعد: ${DateFormat('yyyy/MM/dd HH:mm').format(task['scheduled_date'])}',
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
                    // Task Details
                    _buildTaskDetails(task),

                    const SizedBox(height: 16),

                    // Action Buttons
                    _buildTaskActions(task),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskDetails(Map<String, dynamic> task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفاصيل المهمة',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'المدة المقدرة',
                '${task['estimated_duration']} دقيقة',
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'التكلفة',
                '${task['estimated_cost']} ريال',
              ),
            ),
          ],
        ),
        if (task['notes']?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          _buildDetailItem('ملاحظات', task['notes']),
        ],
        if (task['before_photos']?.isNotEmpty ?? false) ...[
          const SizedBox(height: 16),
          Text(
            'صور قبل الإصلاح',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: task['before_photos'].length,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
        ],
        if (task['after_photos']?.isNotEmpty ?? false) ...[
          const SizedBox(height: 16),
          Text(
            'صور بعد الإصلاح',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: task['after_photos'].length,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
        ],
      ],
    );
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

  Widget _buildTaskActions(Map<String, dynamic> task) {
    final status = task['status'];

    return Column(
      children: [
        if (status == 'pending')
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startTask(task),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('بدء المهمة'),
                ),
              ),
            ],
          )
        else if (status == 'in_progress')
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _addBeforePhoto(task),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('صورة قبل الإصلاح'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _addAfterPhoto(task),
                  icon: const Icon(Icons.camera),
                  label: const Text('صورة بعد الإصلاح'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _completeTask(task),
                  icon: const Icon(Icons.check),
                  label: const Text('إكمال'),
                ),
              ),
            ],
          )
        else if (status == 'completed')
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewTaskDetails(task),
                  icon: const Icon(Icons.visibility),
                  label: const Text('عرض التفاصيل'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _getMockTasks(String status) {
    final allTasks = [
      {
        'id': 1,
        'service_name': 'تغيير زيت المحرك',
        'work_order_number': 'WO-2024-001',
        'customer_name': 'أحمد محمد',
        'status': 'pending',
        'scheduled_date': DateTime.now().add(const Duration(hours: 2)),
        'estimated_duration': 30,
        'estimated_cost': 15000,
        'notes': 'زيت محرك كامل مع فلتر الزيت',
        'before_photos': [],
        'after_photos': [],
      },
      {
        'id': 2,
        'service_name': 'فحص الفرامل',
        'work_order_number': 'WO-2024-001',
        'customer_name': 'أحمد محمد',
        'status': 'in_progress',
        'scheduled_date': DateTime.now().add(const Duration(hours: 1)),
        'estimated_duration': 45,
        'estimated_cost': 8000,
        'notes': 'فحص شامل لنظام الفرامل الأمامي والخلفي',
        'before_photos': ['photo1.jpg'],
        'after_photos': [],
      },
      {
        'id': 3,
        'service_name': 'تغيير شمعات الإشعال',
        'work_order_number': 'WO-2024-002',
        'customer_name': 'فاطمة علي',
        'status': 'completed',
        'scheduled_date': DateTime.now().subtract(const Duration(hours: 3)),
        'estimated_duration': 20,
        'estimated_cost': 12000,
        'notes': 'استبدال 4 شمعات إشعال',
        'before_photos': ['photo1.jpg'],
        'after_photos': ['photo2.jpg', 'photo3.jpg'],
      },
    ];

    if (status == 'all') return allTasks;
    return allTasks.where((task) => task['status'] == status).toList();
  }

  Color _getTaskStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.engineering;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.task;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية المهام'),
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
                  value: 'high_priority',
                  child: Text('أولوية عالية'),
                ),
                DropdownMenuItem(value: 'my_services', child: Text('خدماتي')),
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
        title: const Text('ترتيب المهام'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedSort,
              decoration: const InputDecoration(labelText: 'طريقة الترتيب'),
              items: const [
                DropdownMenuItem(value: 'date', child: Text('بالتاريخ')),
                DropdownMenuItem(value: 'priority', child: Text('بالأولوية')),
                DropdownMenuItem(value: 'customer', child: Text('بالعميل')),
                DropdownMenuItem(value: 'service', child: Text('بالخدمة')),
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

  void _startTask(Map<String, dynamic> task) {
    // Implement start task API call
    _performTaskAction(
      task: task,
      action: 'start',
      onSuccess: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم بدء المهمة بنجاح')));
      },
    );
  }

  void _addBeforePhoto(Map<String, dynamic> task) {
    // Implement photo capture/upload
    _pickAndUploadPhoto(task, 'قبل');
  }

  void _addAfterPhoto(Map<String, dynamic> task) {
    // Implement photo capture/upload
    _pickAndUploadPhoto(task, 'بعد');
  }

  void _completeTask(Map<String, dynamic> task) {
    // Implement complete task API call
    _performTaskAction(
      task: task,
      action: 'complete',
      onSuccess: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إكمال المهمة بنجاح')));
      },
    );
  }

  void _viewTaskDetails(Map<String, dynamic> task) {
    // Navigate to task details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تفاصيل المهمة: ${task['name'] ?? 'بدون عنوان'}')),
    );
    // In a real app, you would navigate to a task details page:
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => TaskDetailsPage(taskId: task['id']),
    // ));
  }

  Future<void> _pickAndUploadPhoto(
    Map<String, dynamic> task,
    String photoType,
  ) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (image != null) {
        // In a real implementation, upload the photo to your backend
        final taskId = task['id'] ?? 0;

        _taskPhotos.update(
          taskId,
          (value) => [...value, image.path],
          ifAbsent: () => [image.path],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم إضافة صورة $photoType بنجاح')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الصورة: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _performTaskAction({
    required Map<String, dynamic> task,
    required String action,
    required VoidCallback onSuccess,
  }) async {
    try {
      final workOrderRepository = ref.read(workOrderRepositoryProvider);
      final taskId = task['id'] ?? 0;

      // Call the appropriate API based on action
      switch (action) {
        case 'start':
          await workOrderRepository.updateTaskStatus(taskId, 'in_progress');
          break;
        case 'complete':
          await workOrderRepository.updateTaskStatus(taskId, 'completed');
          break;
        default:
          break;
      }

      if (mounted) {
        onSuccess();
        // Refresh the task list
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
}
