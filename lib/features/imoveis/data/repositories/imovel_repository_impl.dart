import '../../domain/entities/imovel.dart';
import '../../domain/repositories/imovel_repository.dart';
import '../datasources/imovel_mock_datasource.dart';

class ImovelRepositoryImpl implements ImovelRepository {
  final ImovelMockDatasource _datasource;

  ImovelRepositoryImpl(this._datasource);

  @override
  Future<List<Imovel>> getImoveis() async {
    return _datasource.getImoveis();
  }

  @override
  Future<Imovel> getImovelById(String id) async {
    return _datasource.getImovelById(id);
  }
}
