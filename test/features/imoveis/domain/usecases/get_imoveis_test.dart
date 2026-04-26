import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_showcase/features/imoveis/domain/entities/imovel.dart';
import 'package:property_showcase/features/imoveis/domain/repositories/imovel_repository.dart';
import 'package:property_showcase/features/imoveis/domain/usecases/get_imoveis.dart';

class MockImovelRepository extends Mock implements ImovelRepository {}

void main() {
  late GetImoveis sut;
  late MockImovelRepository mockRepository;

  setUp(() {
    mockRepository = MockImovelRepository();
    sut = GetImoveis(mockRepository);
  });

  group('GetImoveis', () {
    const mockImoveis = <Imovel>[];

    test('deve retornar lista de imóveis quando o repositório conseguir', () async {
      when(() => mockRepository.getImoveis()).thenAnswer((_) async => mockImoveis);

      final result = await sut();

      expect(result, mockImoveis);
      verify(() => mockRepository.getImoveis()).called(1);
    });

    test('deve lançar exceção quando o repositório falhar', () async {
      when(() => mockRepository.getImoveis())
          .thenThrow(Exception('Erro na requisição'));

      expect(() => sut(), throwsException);
      verify(() => mockRepository.getImoveis()).called(1);
    });

    test('deve retornar lista vazia quando não houver imóveis', () async {
      when(() => mockRepository.getImoveis()).thenAnswer((_) async => []);

      final result = await sut();

      expect(result, isEmpty);
      verify(() => mockRepository.getImoveis()).called(1);
    });
  });
}
