import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_showcase/features/imoveis/domain/entities/imovel.dart';
import 'package:property_showcase/features/imoveis/domain/repositories/imovel_repository.dart';
import 'package:property_showcase/features/imoveis/domain/usecases/get_imovel_by_id.dart';

class MockImovelRepository extends Mock implements ImovelRepository {}

void main() {
  late GetImovelById sut;
  late MockImovelRepository mockRepository;

  setUp(() {
    mockRepository = MockImovelRepository();
    sut = GetImovelById(mockRepository);
  });

  group('GetImovelById', () {
    const mockImovelId = '1';

    test('deve retornar um imóvel quando o repositório conseguir', () async {
      const mockImovel = Imovel(
        id: mockImovelId,
        titulo: 'Test Property',
        endereco: 'Test Address',
        preco: 100000,
        midias: [],
        quartos: 2,
        banheiros: 1,
        areaM2: 50,
        descricao: 'Test Description',
      );

      when(() => mockRepository.getImovelById(mockImovelId))
          .thenAnswer((_) async => mockImovel);

      final result = await sut(mockImovelId);

      expect(result, mockImovel);
      verify(() => mockRepository.getImovelById(mockImovelId)).called(1);
    });

    test('deve lançar exceção quando o repositório falhar', () async {
      when(() => mockRepository.getImovelById(mockImovelId))
          .thenThrow(Exception('Imóvel não encontrado'));

      expect(() => sut(mockImovelId), throwsException);
      verify(() => mockRepository.getImovelById(mockImovelId)).called(1);
    });

    test('deve passar o ID correto ao repositório', () async {
      const testId = '123';
      const mockImovel = Imovel(
        id: testId,
        titulo: 'Test',
        endereco: 'Address',
        preco: 1000,
        midias: [],
        quartos: 1,
        banheiros: 1,
        areaM2: 30,
        descricao: 'Description',
      );

      when(() => mockRepository.getImovelById(testId))
          .thenAnswer((_) async => mockImovel);

      await sut(testId);

      verify(() => mockRepository.getImovelById(testId)).called(1);
    });
  });
}
