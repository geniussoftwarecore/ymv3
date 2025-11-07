import 'package:dio/dio.dart';
import '../api_constants.dart';

class WorkOrderModel {
  final int id;
  final String uuid;
  final String workOrderNumber;
  final int customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerAddress;
  final int vehicleId;
  final String vehicleInfo;
  final String status;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final double totalCost;
  final String? specialInstructions;
  final List<String> services;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkOrderModel({
    required this.id,
    required this.uuid,
    required this.workOrderNumber,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.vehicleId,
    required this.vehicleInfo,
    required this.status,
    required this.scheduledDate,
    this.completedDate,
    required this.totalCost,
    this.specialInstructions,
    required this.services,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      workOrderNumber: json['work_order_number'] as String,
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String?,
      customerAddress: json['customer_address'] as String?,
      vehicleId: json['vehicle_id'] as int,
      vehicleInfo: json['vehicle_info'] as String,
      status: json['status'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      totalCost: (json['total_cost'] as num).toDouble(),
      specialInstructions: json['special_instructions'] as String?,
      services: List<String>.from(json['services'] as List? ?? []),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'work_order_number': workOrderNumber,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_address': customerAddress,
        'vehicle_id': vehicleId,
        'vehicle_info': vehicleInfo,
        'status': status,
        'scheduled_date': scheduledDate.toIso8601String(),
        'completed_date': completedDate?.toIso8601String(),
        'total_cost': totalCost,
        'special_instructions': specialInstructions,
        'services': services,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreateWorkOrderRequest {
  final int customerId;
  final int vehicleId;
  final DateTime scheduledDate;
  final List<int> serviceIds;
  final String? specialInstructions;
  final String? notes;

  CreateWorkOrderRequest({
    required this.customerId,
    required this.vehicleId,
    required this.scheduledDate,
    required this.serviceIds,
    this.specialInstructions,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'vehicle_id': vehicleId,
        'scheduled_date': scheduledDate.toIso8601String(),
        'service_ids': serviceIds,
        'special_instructions': specialInstructions,
        'notes': notes,
      };
}

class WorkOrderRepository {
  final Dio _dio;

  WorkOrderRepository(this._dio);

  Future<List<WorkOrderModel>> getWorkOrders({
    String? status,
    int? customerId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final params = {
        'skip': skip,
        'limit': limit,
        if (status != null) 'status': status,
        if (customerId != null) 'customer_id': customerId,
      };

      final response = await _dio.get(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.workOrders}',
        queryParameters: params,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => WorkOrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<WorkOrderModel> getWorkOrderDetail(int id) async {
    try {
      final response = await _dio.get(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.workOrders}/$id',
      );

      return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<WorkOrderModel> createWorkOrder(CreateWorkOrderRequest request) async {
    try {
      final response = await _dio.post(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.workOrderCreate}',
        data: request.toJson(),
      );

      return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<WorkOrderModel> updateWorkOrderStatus(int id, String newStatus) async {
    try {
      final response = await _dio.put(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.workOrderStatus.replaceFirst('{id}', id.toString())}',
        data: {'status': newStatus},
      );

      return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> completeWorkOrder(int id) async {
    try {
      await _dio.post(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.deliveryComplete.replaceFirst('{id}', id.toString())}',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateTaskStatus(int taskId, String status) async {
    try {
      await _dio.put(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.taskUpdate.replaceFirst('{id}', taskId.toString())}',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return 'أمر العمل غير موجود';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'انتهت مهلة الاتصال';
    }
    return e.message ?? 'خطأ غير معروف';
  }
}
