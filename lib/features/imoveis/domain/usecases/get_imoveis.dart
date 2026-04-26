import '../entities/imovel.dart';
import '../repositories/imovel_repository.dart';

class GetImoveis {
  final ImovelRepository _repository;

  GetImoveis(this._repository);

  Future<List<Imovel>> call() => _repository.getImoveis();
}
