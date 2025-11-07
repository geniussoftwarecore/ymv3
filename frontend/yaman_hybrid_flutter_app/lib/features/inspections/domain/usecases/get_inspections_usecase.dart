import '../entities/inspection_entity.dart';
import '../repositories/inspection_repository.dart';

class GetInspectionsUseCase {
  final InspectionRepository repository;

  GetInspectionsUseCase(this.repository);

  Future<List<InspectionEntity>> execute({
    int? customerId,
    InspectionStatus? status,
    int? inspectorId,
    int skip = 0,
    int limit = 100,
  }) async {
    return await repository.getInspections(
      customerId: customerId,
      status: status,
      inspectorId: inspectorId,
      skip: skip,
      limit: limit,
    );
  }
}