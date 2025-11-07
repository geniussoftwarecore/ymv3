import '../entities/inspection_entity.dart';
import '../repositories/inspection_repository.dart';

class CreateInspectionUseCase {
  final InspectionRepository repository;

  CreateInspectionUseCase(this.repository);

  Future<InspectionEntity> execute(InspectionEntity inspection) async {
    return await repository.createInspection(inspection);
  }
}