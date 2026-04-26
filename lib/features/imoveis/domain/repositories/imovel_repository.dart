import '../entities/imovel.dart';

abstract class ImovelRepository {
  Future<List<Imovel>> getImoveis();
  Future<Imovel> getImovelById(String id);
}
