import '../entities/imovel.dart';
import '../repositories/imovel_repository.dart';

class GetImovelById {
  final ImovelRepository _repository;

  GetImovelById(this._repository);

  Future<Imovel> call(String id) => _repository.getImovelById(id);
}
