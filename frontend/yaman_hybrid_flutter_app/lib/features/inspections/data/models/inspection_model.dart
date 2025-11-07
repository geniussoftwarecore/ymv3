import 'package:equatable/equatable.dart';

enum InspectionType { standard, custom }
enum InspectionStatus { draft, inProgress, completed, convertedToWorkOrder }

class InspectionModel extends Equatable {
  final int? id;
  final String? uuid;
  final String? inspectionNumber;
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
  final InspectionType inspectionType;
  final InspectionStatus status;
  final int? inspectorId;
  final String? customerComplaint;
  final String? observations;
  final String? recommendations;
  final List<Map<String, dynamic>>? attachments;
  final DateTime? scheduledDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? convertedToWorkOrderId;
  final int? convertedBy;
  final DateTime? convertedAt;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InspectionModel({
    this.id,
    this.uuid,
    this.inspectionNumber,
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
    this.inspectionType = InspectionType.standard,
    this.status = InspectionStatus.draft,
    this.inspectorId,
    this.customerComplaint,
    this.observations,
    this.recommendations,
    this.attachments,
    this.scheduledDate,
    this.startedAt,
    this.completedAt,
    this.convertedToWorkOrderId,
    this.convertedBy,
    this.convertedAt,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      id: json['id'],
      uuid: json['uuid'],
      inspectionNumber: json['inspection_number'],
      customerId: json['customer_id'],
      vehicleTypeId: json['vehicle_type_id'],
      vehicleMake: json['vehicle_make'],
      vehicleModel: json['vehicle_model'],
      vehicleYear: json['vehicle_year'],
      vehicleVin: json['vehicle_vin'],
      vehicleLicensePlate: json['vehicle_license_plate'],
      vehicleMileage: json['vehicle_mileage'],
      vehicleColor: json['vehicle_color'],
      vehicleTrim: json['vehicle_trim'],
      inspectionType: InspectionType.values.firstWhere(
        (e) => e.name == json['inspection_type'],
        orElse: () => InspectionType.standard,
      ),
      status: InspectionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InspectionStatus.draft,
      ),
      inspectorId: json['inspector_id'],
      customerComplaint: json['customer_complaint'],
      observations: json['observations'],
      recommendations: json['recommendations'],
      attachments: json['attachments'] != null
          ? List<Map<String, dynamic>>.from(json['attachments'])
          : null,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'])
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      convertedToWorkOrderId: json['converted_to_work_order_id'],
      convertedBy: json['converted_by'],
      convertedAt: json['converted_at'] != null
          ? DateTime.parse(json['converted_at'])
          : null,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'inspection_number': inspectionNumber,
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
      'inspection_type': inspectionType.name,
      'status': status.name,
      'inspector_id': inspectorId,
      'customer_complaint': customerComplaint,
      'observations': observations,
      'recommendations': recommendations,
      'attachments': attachments,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'converted_to_work_order_id': convertedToWorkOrderId,
      'converted_by': convertedBy,
      'converted_at': convertedAt?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  InspectionModel copyWith({
    int? id,
    String? uuid,
    String? inspectionNumber,
    int? customerId,
    int? vehicleTypeId,
    String? vehicleMake,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleVin,
    String? vehicleLicensePlate,
    int? vehicleMileage,
    String? vehicleColor,
    String? vehicleTrim,
    InspectionType? inspectionType,
    InspectionStatus? status,
    int? inspectorId,
    String? customerComplaint,
    String? observations,
    String? recommendations,
    List<Map<String, dynamic>>? attachments,
    DateTime? scheduledDate,
    DateTime? startedAt,
    DateTime? completedAt,
    int? convertedToWorkOrderId,
    int? convertedBy,
    DateTime? convertedAt,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InspectionModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      inspectionNumber: inspectionNumber ?? this.inspectionNumber,
      customerId: customerId ?? this.customerId,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleVin: vehicleVin ?? this.vehicleVin,
      vehicleLicensePlate: vehicleLicensePlate ?? this.vehicleLicensePlate,
      vehicleMileage: vehicleMileage ?? this.vehicleMileage,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehicleTrim: vehicleTrim ?? this.vehicleTrim,
      inspectionType: inspectionType ?? this.inspectionType,
      status: status ?? this.status,
      inspectorId: inspectorId ?? this.inspectorId,
      customerComplaint: customerComplaint ?? this.customerComplaint,
      observations: observations ?? this.observations,
      recommendations: recommendations ?? this.recommendations,
      attachments: attachments ?? this.attachments,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      convertedToWorkOrderId: convertedToWorkOrderId ?? this.convertedToWorkOrderId,
      convertedBy: convertedBy ?? this.convertedBy,
      convertedAt: convertedAt ?? this.convertedAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        inspectionNumber,
        customerId,
        vehicleTypeId,
        vehicleMake,
        vehicleModel,
        vehicleYear,
        vehicleVin,
        vehicleLicensePlate,
        vehicleMileage,
        vehicleColor,
        vehicleTrim,
        inspectionType,
        status,
        inspectorId,
        customerComplaint,
        observations,
        recommendations,
        attachments,
        scheduledDate,
        startedAt,
        completedAt,
        convertedToWorkOrderId,
        convertedBy,
        convertedAt,
        createdBy,
        createdAt,
        updatedAt,
      ];
}

class InspectionFault extends Equatable {
  final int? id;
  final int inspectionId;
  final String faultCategory;
  final String faultDescription;
  final String severity;
  final List<Map<String, dynamic>>? photos;
  final String? notes;
  final DateTime createdAt;

  const InspectionFault({
    this.id,
    required this.inspectionId,
    required this.faultCategory,
    required this.faultDescription,
    this.severity = 'Medium',
    this.photos,
    this.notes,
    required this.createdAt,
  });

  factory InspectionFault.fromJson(Map<String, dynamic> json) {
    return InspectionFault(
      id: json['id'],
      inspectionId: json['inspection_id'],
      faultCategory: json['fault_category'],
      faultDescription: json['fault_description'],
      severity: json['severity'] ?? 'Medium',
      photos: json['photos'] != null
          ? List<Map<String, dynamic>>.from(json['photos'])
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inspection_id': inspectionId,
      'fault_category': faultCategory,
      'fault_description': faultDescription,
      'severity': severity,
      'photos': photos,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        inspectionId,
        faultCategory,
        faultDescription,
        severity,
        photos,
        notes,
        createdAt,
      ];
}

class InspectionService extends Equatable {
  final int? id;
  final int inspectionId;
  final int? serviceId;
  final String serviceName;
  final double? estimatedCost;
  final int? estimatedDuration;
  final int? assignedEngineerId;
  final String priority;
  final String? notes;
  final DateTime createdAt;

  const InspectionService({
    this.id,
    required this.inspectionId,
    this.serviceId,
    required this.serviceName,
    this.estimatedCost,
    this.estimatedDuration,
    this.assignedEngineerId,
    this.priority = 'Medium',
    this.notes,
    required this.createdAt,
  });

  factory InspectionService.fromJson(Map<String, dynamic> json) {
    return InspectionService(
      id: json['id'],
      inspectionId: json['inspection_id'],
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      estimatedCost: json['estimated_cost']?.toDouble(),
      estimatedDuration: json['estimated_duration'],
      assignedEngineerId: json['assigned_engineer_id'],
      priority: json['priority'] ?? 'Medium',
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inspection_id': inspectionId,
      'service_id': serviceId,
      'service_name': serviceName,
      'estimated_cost': estimatedCost,
      'estimated_duration': estimatedDuration,
      'assigned_engineer_id': assignedEngineerId,
      'priority': priority,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        inspectionId,
        serviceId,
        serviceName,
        estimatedCost,
        estimatedDuration,
        assignedEngineerId,
        priority,
        notes,
        createdAt,
      ];
}