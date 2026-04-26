import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_showcase/features/chat/domain/repositories/chat_repository.dart';
import 'package:property_showcase/features/chat/domain/usecases/send_message.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late SendMessage sut;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    sut = SendMessage(mockRepository);
  });

  group('SendMessage', () {
    const mockConversationId = 'conv_1';
    const mockText = 'Hello, I am interested in this property';

    test('deve enviar mensagem quando o repositório conseguir', () async {
      when(() => mockRepository.sendMessage(mockConversationId, mockText))
          .thenAnswer((_) async => Future.value());

      await sut(mockConversationId, mockText);

      verify(() => mockRepository.sendMessage(mockConversationId, mockText))
          .called(1);
    });

    test('deve lançar exceção quando o repositório falhar', () async {
      when(() => mockRepository.sendMessage(mockConversationId, mockText))
          .thenThrow(Exception('Erro ao enviar mensagem'));

      expect(
        () => sut(mockConversationId, mockText),
        throwsException,
      );
      verify(() => mockRepository.sendMessage(mockConversationId, mockText))
          .called(1);
    });

    test('deve passar os parâmetros corretos ao repositório', () async {
      const conversationId = 'custom_conv';
      const text = 'Custom message';

      when(() => mockRepository.sendMessage(conversationId, text))
          .thenAnswer((_) async => Future.value());

      await sut(conversationId, text);

      verify(() => mockRepository.sendMessage(conversationId, text)).called(1);
    });
  });
}
