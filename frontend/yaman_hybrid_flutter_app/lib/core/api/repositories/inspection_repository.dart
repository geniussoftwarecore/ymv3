import 'package:dio/dio.dart';
import '../api_constants.dart';

class InspectionModel {
  final int id;
  final String uuid;
  final String inspectionNumber;
  final int customerId;
  final int? vehicleTypeId;
  final String? vehicleMake;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? vehicleVin;
  final String? vehicleLicensePlate;
  final int? vehicleMileage;
  final String? vehicleColor;
  final String? vehicleTrim;
  final String inspectionType;
  final String status;
  final int? inspectorId;
  final String? customerComplaint;
  final String? observations;
  final String? recommendations;
  final List<dynamic>? attachments;
  final DateTime? scheduledDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? convertedToWorkOrderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  InspectionModel({
    required this.id,
    required this.uuid,
    required this.inspectionNumber,
    required this.customerId,
    this.vehicleTypeId,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleVin,
    this.vehicleLicensePlate,
    this.vehicleMileage,
    this.vehicleColor,
    this.vehicleTrim,
    required this.inspectionType,
    required this.status,
    this.inspectorId,
    this.customerComplaint,
    this.observations,
    this.recommendations,
    this.attachments,
    this.scheduledDate,
    this.startedAt,
    this.completedAt,
    this.convertedToWorkOrderId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      inspectionNumber: json['inspection_number'] as String,
      customerId: json['customer_id'] as int,
      vehicleTypeId: json['vehicle_type_id'] as int?,
      vehicleMake: json['vehicle_make'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      vehicleYear: json['vehicle_year'] as int?,
      vehicleVin: json['vehicle_vin'] as String?,
      vehicleLicensePlate: json['vehicle_license_plate'] as String?,
      vehicleMileage: json['vehicle_mileage'] as int?,
      vehicleColor: json['vehicle_color'] as String?,
      vehicleTrim: json['vehicle_trim'] as String?,
      inspectionType: json['inspection_type'] as String? ?? 'Standard',
      status: json['status'] as String,
      inspectorId: json['inspector_id'] as int?,
      customerComplaint: json['customer_complaint'] as String?,
      observations: json['observations'] as String?,
      recommendations: json['recommendations'] as String?,
      attachments: json['attachments'] as List<dynamic>?,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      convertedToWorkOrderId: json['converted_to_work_order_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class CreateInspectionRequest {
  final int customerId;
  final int? vehicleTypeId;
  final String? vehicleMake;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? vehicleVin;
  final String? vehicleLicensePlate;
  final int? vehicleMileage;
  final String? vehicleColor;
  final String? vehicleTrim;
  final String inspectionType;
  final String? customerComplaint;
  final DateTime? scheduledDate;
  final int createdBy;

  CreateInspectionRequest({
    required this.customerId,
    this.vehicleTypeId,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleVin,
    this.vehicleLicensePlate,
    this.vehicleMileage,
    this.vehicleColor,
    this.vehicleTrim,
    this.inspectionType = 'Standard',
    this.customerComplaint,
    this.scheduledDate,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'vehicle_type_id': vehicleTypeId,
        'vehicle_make': vehicleMake,
        'vehicle_model': vehicleModel,
        'vehicle_year': vehicleYear,
        'vehicle_vin': vehicleVin,
        'vehicle_license_plate': vehicleLicensePlate,
        'vehicle_mileage': vehicleMileage,
        'vehicle_color': vehicleColor,
        'vehicle_trim': vehicleTrim,
        'inspection_type': inspectionType,
        'customer_complaint': customerComplaint,
        'scheduled_date': scheduledDate?.toIso8601String(),
        'created_by': createdBy,
      };
}

class InspectionRepository {
  final Dio _dio;

  InspectionRepository(this._dio);

  Future<List<InspectionModel>> getInspections({
    int? customerId,
    String? status,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final params = {
        'skip': skip,
        'limit': limit,
        if (customerId != null) 'customer_id': customerId,
        if (status != null) 'status': status,
      };

      final response = await _dio.get(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.inspections}',
        queryParameters: params,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => InspectionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<InspectionModel> getInspection(int id) async {
    try {
      final response = await _dio.get(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.inspections}/$id',
      );

      return InspectionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<InspectionModel> createInspection(
      CreateInspectionRequest request) async {
    try {
      final response = await _dio.post(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.inspections}',
        data: request.toJson(),
      );

      return InspectionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<InspectionModel> updateInspection(
    int id,
    Map<String, dynamic> data,
    int updatedBy,
  ) async {
    try {
      final updateData = {
        ...data,
        'updated_by': updatedBy,
      };

      final response = await _dio.put(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.inspections}/$id',
        data: updateData,
      );

      return InspectionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return 'الفحص غير موجود';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'انتهت مهلة الاتصال';
    }
    return e.message ?? 'خطأ غير معروف';
  }
}
