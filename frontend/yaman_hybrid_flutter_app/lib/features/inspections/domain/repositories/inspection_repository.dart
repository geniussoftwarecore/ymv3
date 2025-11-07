import '../entities/inspection_entity.dart';

abstract class InspectionRepository {
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