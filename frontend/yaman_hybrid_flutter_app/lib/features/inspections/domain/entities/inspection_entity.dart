// Domain entities for inspections - same as data models but without JSON serialization
enum InspectionType { standard, custom }
enum InspectionStatus { draft, inProgress, completed, convertedToWorkOrder }

class InspectionEntity {
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

  const InspectionEntity({
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

  InspectionEntity copyWith({
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
    return InspectionEntity(
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
}

class InspectionFaultEntity {
  final int? id;
  final int inspectionId;
  final String faultCategory;
  final String faultDescription;
  final String severity;
  final List<Map<String, dynamic>>? photos;
  final String? notes;
  final DateTime createdAt;

  const InspectionFaultEntity({
    this.id,
    required this.inspectionId,
    required this.faultCategory,
    required this.faultDescription,
    this.severity = 'Medium',
    this.photos,
    this.notes,
    required this.createdAt,
  });
}

class InspectionServiceEntity {
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

  const InspectionServiceEntity({
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
}