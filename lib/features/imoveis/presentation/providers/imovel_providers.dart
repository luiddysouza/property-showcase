import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/imovel_mock_datasource.dart';
import '../../data/repositories/imovel_repository_impl.dart';
import '../../domain/entities/imovel.dart';
import '../../domain/repositories/imovel_repository.dart';
import '../../domain/usecases/get_imovel_by_id.dart';
import '../../domain/usecases/get_imoveis.dart';

// DI — repositório e usecases
final imovelRepositoryProvider = Provider<ImovelRepository>((ref) {
  return ImovelRepositoryImpl(ImovelMockDatasource());
});

final getImoveisProvider = Provider<GetImoveis>((ref) {
  return GetImoveis(ref.read(imovelRepositoryProvider));
});

final getImovelByIdProvider = Provider<GetImovelById>((ref) {
  return GetImovelById(ref.read(imovelRepositoryProvider));
});

// Estado da listagem
final imoveisProvider = AsyncNotifierProvider<ImoveisNotifier, List<Imovel>>(
  ImoveisNotifier.new,
);

class ImoveisNotifier extends AsyncNotifier<List<Imovel>> {
  @override
  Future<List<Imovel>> build() async {
    return ref.read(getImoveisProvider).call();
  }
}

// Estado do detalhe (carregado por ID)
final imovelDetalheProvider =
    FutureProvider.family<Imovel, String>((ref, id) async {
  return ref.read(getImovelByIdProvider).call(id);
});
