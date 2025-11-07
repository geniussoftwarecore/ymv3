import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/inspection_model.dart' as model;
import '../../domain/repositories/inspection_repository.dart' as domain_repo;
import '../../domain/entities/inspection_entity.dart';

abstract class IInspectionDataRepository {
  Future<List<InspectionEntity>> getInspections({
    int? customerId,
    InspectionStatus? status,
    int? inspectorId,
    int skip = 0,
    int limit = 100,
  });

  Future<InspectionEntity> getInspection(int inspectionId);

  Future<InspectionEntity> createInspection(InspectionEntity inspection);

  Future<InspectionEntity> updateInspection(int inspectionId, Map<String, dynamic> updates);

  Future<void> addInspectionFault(int inspectionId, InspectionFaultEntity fault);

  Future<void> addInspectionService(int inspectionId, InspectionServiceEntity service);

  Future<Map<String, dynamic>> convertInspectionToWorkOrder(int inspectionId, int convertedBy);
}

class InspectionRepositoryImpl implements domain_repo.InspectionRepository {
  final http.Client client;
  final String baseUrl;

  InspectionRepositoryImpl({
    required this.client,
    this.baseUrl = AppConstants.workOrderManagementServiceUrl,
  });

  InspectionEntity _modelToEntity(model.InspectionModel model) {
    return InspectionEntity(
      id: model.id,
      uuid: model.uuid,
      inspectionNumber: model.inspectionNumber,
      customerId: model.customerId,
      vehicleTypeId: model.vehicleTypeId,
      vehicleMake: model.vehicleMake,
      vehicleModel: model.vehicleModel,
      vehicleYear: model.vehicleYear,
      vehicleVin: model.vehicleVin,
      vehicleLicensePlate: model.vehicleLicensePlate,
      vehicleMileage: model.vehicleMileage,
      vehicleColor: model.vehicleColor,
      vehicleTrim: model.vehicleTrim,
      inspectionType: InspectionType.values.firstWhere(
        (e) => e.name == model.inspectionType.name,
        orElse: () => InspectionType.standard,
      ),
      status: InspectionStatus.values.firstWhere(
        (e) => e.name == model.status.name,
        orElse: () => InspectionStatus.draft,
      ),
      inspectorId: model.inspectorId,
      customerComplaint: model.customerComplaint,
      observations: model.observations,
      recommendations: model.recommendations,
      attachments: model.attachments,
      scheduledDate: model.scheduledDate,
      startedAt: model.startedAt,
      completedAt: model.completedAt,
      convertedToWorkOrderId: model.convertedToWorkOrderId,
      convertedBy: model.convertedBy,
      convertedAt: model.convertedAt,
      createdBy: model.createdBy,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  Future<List<InspectionEntity>> getInspections({
    int? customerId,
    InspectionStatus? status,
    int? inspectorId,
    int skip = 0,
    int limit = 100,
  }) async {
    final queryParams = <String, String>{};
    if (customerId != null) queryParams['customer_id'] = customerId.toString();
    if (status != null) queryParams['status'] = status.name;
    if (inspectorId != null) queryParams['inspector_id'] = inspectorId.toString();
    queryParams['skip'] = skip.toString();
    queryParams['limit'] = limit.toString();

    final uri = Uri.parse('$baseUrl/inspections/').replace(queryParameters: queryParams);

    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => _modelToEntity(model.InspectionModel.fromJson(json))).toList();
    } else {
      throw Exception('Failed to load inspections: ${response.statusCode}');
    }
  }

  @override
  Future<InspectionEntity> getInspection(int inspectionId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/inspections/$inspectionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return _modelToEntity(model.InspectionModel.fromJson(json.decode(response.body)));
    } else {
      throw Exception('Failed to load inspection: ${response.statusCode}');
    }
  }

  @override
  Future<InspectionEntity> createInspection(InspectionEntity inspection) async {
    final response = await client.post(
      Uri.parse('$baseUrl/inspections/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'customer_id': inspection.customerId,
        'vehicle_type_id': inspection.vehicleTypeId,
        'vehicle_make': inspection.vehicleMake,
        'vehicle_model': inspection.vehicleModel,
        'vehicle_year': inspection.vehicleYear,
        'vehicle_vin': inspection.vehicleVin,
        'vehicle_license_plate': inspection.vehicleLicensePlate,
        'vehicle_mileage': inspection.vehicleMileage,
        'vehicle_color': inspection.vehicleColor,
        'vehicle_trim': inspection.vehicleTrim,
        'inspection_type': inspection.inspectionType.name,
        'customer_complaint': inspection.customerComplaint,
        'observations': inspection.observations,
        'recommendations': inspection.recommendations,
        'attachments': inspection.attachments,
        'scheduled_date': inspection.scheduledDate?.toIso8601String(),
        'created_by': inspection.createdBy,
      }),
    );

    if (response.statusCode == 200) {
      return _modelToEntity(model.InspectionModel.fromJson(json.decode(response.body)));
    } else {
      throw Exception('Failed to create inspection: ${response.statusCode}');
    }
  }

  @override
  Future<InspectionEntity> updateInspection(int inspectionId, Map<String, dynamic> updates) async {
    updates['updated_by'] = updates['updated_by'];

    final response = await client.put(
      Uri.parse('$baseUrl/inspections/$inspectionId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      return _modelToEntity(model.InspectionModel.fromJson(json.decode(response.body)));
    } else {
      throw Exception('Failed to update inspection: ${response.statusCode}');
    }
  }

  @override
  Future<void> addInspectionFault(int inspectionId, InspectionFaultEntity fault) async {
    final response = await client.post(
      Uri.parse('$baseUrl/inspections/$inspectionId/faults/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fault_category': fault.faultCategory,
        'fault_description': fault.faultDescription,
        'severity': fault.severity,
        'photos': fault.photos,
        'notes': fault.notes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add inspection fault: ${response.statusCode}');
    }
  }

  @override
  Future<void> addInspectionService(int inspectionId, InspectionServiceEntity service) async {
    final response = await client.post(
      Uri.parse('$baseUrl/inspections/$inspectionId/services/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'service_id': service.serviceId,
        'service_name': service.serviceName,
        'estimated_cost': service.estimatedCost,
        'estimated_duration': service.estimatedDuration,
        'assigned_engineer_id': service.assignedEngineerId,
        'priority': service.priority,
        'notes': service.notes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add inspection service: ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, dynamic>> convertInspectionToWorkOrder(int inspectionId, int convertedBy) async {
    final response = await client.post(
      Uri.parse('$baseUrl/inspections/$inspectionId/convert-to-work-order'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'converted_by': convertedBy}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to convert inspection to work order: ${response.statusCode}');
    }
  }
}