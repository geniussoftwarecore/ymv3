import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';

class WorkOrderExecutionPage extends ConsumerStatefulWidget {
  final int workOrderId;
  final String workOrderNumber;

  const WorkOrderExecutionPage({
    required this.workOrderId,
    required this.workOrderNumber,
    super.key,
  });

  @override
  ConsumerState<WorkOrderExecutionPage> createState() =>
      _WorkOrderExecutionPageState();
}

class _WorkOrderExecutionPageState
    extends ConsumerState<WorkOrderExecutionPage> {
  List<Map<String, dynamic>> _tasks = [];
  final _progressNotesController = TextEditingController();
  File? _beforeImage;
  File? _afterImage;
  int? _selectedTaskIndex;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = [
        {
          'id': 1,
          'service_name': 'تغيير زيت المحرك',
          'engineer_id': 101,
          'engineer_name': 'أحمد محمد',
          'status': 'pending',
          'estimated_duration': 30,
          'started_at': null,
          'completed_at': null,
          'before_image': null,
          'after_image': null,
          'notes': '',
        },
        {
          'id': 2,
          'service_name': 'فحص الفرامل',
          'engineer_id': 102,
          'engineer_name': 'علي الحسن',
          'status': 'pending',
          'estimated_duration': 45,
          'started_at': null,
          'completed_at': null,
          'before_image': null,
          'after_image': null,
          'notes': '',
        },
        {
          'id': 3,
          'service_name': 'استبدال البطارية',
          'engineer_id': 103,
          'engineer_name': 'محمود عبده',
          'status': 'pending',
          'estimated_duration': 20,
          'started_at': null,
          'completed_at': null,
          'before_image': null,
          'after_image': null,
          'notes': '',
        },
      ];
    });
  }

  @override
  void dispose() {
    _progressNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isBefore) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null && _selectedTaskIndex != null) {
      setState(() {
        if (isBefore) {
          _beforeImage = File(pickedFile.path);
          _tasks[_selectedTaskIndex!]['before_image'] = _beforeImage;
        } else {
          _afterImage = File(pickedFile.path);
          _tasks[_selectedTaskIndex!]['after_image'] = _afterImage;
        }
      });
    }
  }

  void _startTask(int taskIndex) {
    if (_selectedTaskIndex == null) {
      setState(() => _selectedTaskIndex = taskIndex);
    }

    setState(() {
      _tasks[taskIndex]['status'] = 'in_progress';
      _tasks[taskIndex]['started_at'] = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم بدء المهمة بنجاح'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _completeTask(int taskIndex) {
    if (_beforeImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب رفع صورة قبل الإصلاح'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_afterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب رفع صورة بعد الإصلاح'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _tasks[taskIndex]['status'] = 'completed';
      _tasks[taskIndex]['completed_at'] = DateTime.now();
      _tasks[taskIndex]['notes'] = _progressNotesController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إكمال المهمة بنجاح'),
        backgroundColor: Colors.green,
      ),
    );

    _progressNotesController.clear();
    _beforeImage = null;
    _afterImage = null;
    _selectedTaskIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text('أمر العمل: ${widget.workOrderNumber}'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ),
        body: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  final isSelected = _selectedTaskIndex == index;

                  return Column(
                    children: [
                      _buildTaskCard(task, index, isSelected),
                      if (isSelected) ...[
                        const SizedBox(height: 16),
                        _buildTaskDetailsPanel(task, index),
                      ],
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final completedCount =
        _tasks.where((t) => t['status'] == 'completed').length;
    final progress = completedCount / _tasks.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تقدم تنفيذ أمر العمل',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.lightGray,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedCount من ${_tasks.length} مهام مكتملة',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    Map<String, dynamic> task,
    int index,
    bool isSelected,
  ) {
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected ? AppTheme.lightGreen.withValues(alpha: 0.1) : null,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          setState(() {
            if (_selectedTaskIndex == index) {
              _selectedTaskIndex = null;
            } else {
              _selectedTaskIndex = index;
            }
          });
        },
        leading: _buildStatusIcon(task['status']),
        title: Text(
          task['service_name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('المهندس: ${task['engineer_name']}'),
            const SizedBox(height: 4),
            Text(
              _getStatusText(task['status']),
              style: TextStyle(
                color: _getStatusColor(task['status']),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Icon(
          isSelected ? Icons.expand_less : Icons.expand_more,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildTaskDetailsPanel(Map<String, dynamic> task, int index) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task['status'] == 'pending')
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _startTask(index),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('بدء المهمة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              )
            else if (task['status'] == 'in_progress') ...[
              const Text(
                'الصور التوثيقية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(true),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('قبل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(false),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('بعد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (task['before_image'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      task['before_image'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (task['after_image'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      task['after_image'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _progressNotesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ملاحظات التنفيذ',
                  hintText: 'أضف ملاحظات عن تنفيذ المهمة',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _completeTask(index),
                  icon: const Icon(Icons.check),
                  label: const Text('إكمال المهمة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                  ),
                ),
              ),
            ] else if (task['status'] == 'completed')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'تم إكمال المهمة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'الوقت: ${task['completed_at']?.toString().split('.')[0] ?? ''}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'pending':
        icon = Icons.schedule;
        color = Colors.grey;
        break;
      case 'in_progress':
        icon = Icons.loop;
        color = Colors.blue;
        break;
      case 'completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلقة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
