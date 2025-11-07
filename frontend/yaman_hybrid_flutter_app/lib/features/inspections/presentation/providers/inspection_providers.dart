import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/models/inspection_model.dart' as data_models;
import '../../data/repositories/inspection_repository.dart' as data_repos;
import '../../domain/entities/inspection_entity.dart';
import '../../domain/usecases/get_inspections_usecase.dart';

// Repository Provider
final inspectionRepositoryProvider = Provider((ref) {
  return data_repos.InspectionRepositoryImpl(client: http.Client());
});

// Use Case Providers
final getInspectionsUseCaseProvider = Provider<GetInspectionsUseCase>((ref) {
  final repository = ref.watch(inspectionRepositoryProvider);
  return GetInspectionsUseCase(repository);
});

// State Notifier for Inspections
class InspectionsNotifier extends StateNotifier<AsyncValue<List<data_models.InspectionModel>>> {
  final GetInspectionsUseCase _getInspectionsUseCase;

  InspectionsNotifier(this._getInspectionsUseCase)
      : super(const AsyncValue.loading()) {
    loadInspections();
  }

  Future<void> loadInspections({
    int? customerId,
    InspectionStatus? status,
    int? inspectorId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final inspections = await _getInspectionsUseCase.execute(
        customerId: customerId,
        status: status,
        inspectorId: inspectorId,
      );
      // Convert entities to models for UI
      final models = inspections.map((entity) => data_models.InspectionModel(
        id: entity.id,
        uuid: entity.uuid,
        inspectionNumber: entity.inspectionNumber,
        customerId: entity.customerId,
        vehicleTypeId: entity.vehicleTypeId,
        vehicleMake: entity.vehicleMake,
        vehicleModel: entity.vehicleModel,
        vehicleYear: entity.vehicleYear,
        vehicleVin: entity.vehicleVin,
        vehicleLicensePlate: entity.vehicleLicensePlate,
        vehicleMileage: entity.vehicleMileage,
        vehicleColor: entity.vehicleColor,
        vehicleTrim: entity.vehicleTrim,
        inspectionType: data_models.InspectionType.values.firstWhere(
          (e) => e.name == entity.inspectionType.name,
          orElse: () => data_models.InspectionType.standard,
        ),
        status: data_models.InspectionStatus.values.firstWhere(
          (e) => e.name == entity.status.name,
          orElse: () => data_models.InspectionStatus.draft,
        ),
        inspectorId: entity.inspectorId,
        customerComplaint: entity.customerComplaint,
        observations: entity.observations,
        recommendations: entity.recommendations,
        attachments: entity.attachments,
        scheduledDate: entity.scheduledDate,
        startedAt: entity.startedAt,
        completedAt: entity.completedAt,
        convertedToWorkOrderId: entity.convertedToWorkOrderId,
        convertedBy: entity.convertedBy,
        convertedAt: entity.convertedAt,
        createdBy: entity.createdBy,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      )).toList();
      state = AsyncValue.data(models);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadInspections();
  }
}

// State Notifier Provider
final inspectionsProvider = StateNotifierProvider<InspectionsNotifier, AsyncValue<List<data_models.InspectionModel>>>((ref) {
  final getInspectionsUseCase = ref.watch(getInspectionsUseCaseProvider);
  return InspectionsNotifier(getInspectionsUseCase);
});

// Selected Inspection Provider
final selectedInspectionProvider = StateProvider<data_models.InspectionModel?>((ref) => null);