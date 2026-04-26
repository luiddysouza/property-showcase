import 'dart:async';
import '../models/message_model.dart';

/// Mock que simula comunicação em tempo real via StreamController.
/// A arquitetura é idêntica ao que seria com WebSocket real —
/// só o datasource muda, nada acima precisa saber.
class ChatMockDatasource {
  final Map<String, List<MessageModel>> _mensagens = {
    'imovel-1': [
      MessageModel(
        id: '1',
        text: 'Olá! Tenho interesse nesse apartamento. Ainda está disponível?',
        senderId: 'me',
        sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      MessageModel(
        id: '2',
        text: 'Sim, está disponível! Posso agendar uma visita para você?',
        senderId: 'proprietario',
        sentAt: DateTime.now().subtract(const Duration(minutes: 9)),
      ),
      MessageModel(
        id: '3',
        text: 'Com certeza! Qual seria o melhor horário?',
        senderId: 'me',
        sentAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      MessageModel(
        id: '4',
        text: 'Temos disponibilidade amanhã às 10h ou depois de amanhã às 14h.',
        senderId: 'proprietario',
        sentAt: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
    ],
  };
  final Map<String, StreamController<List<MessageModel>>> _streamControllers =
      {};

  Stream<List<MessageModel>> watchMessages(String conversationId) {
    // Inicializar conversa se não existir
    if (!_mensagens.containsKey(conversationId)) {
      _mensagens[conversationId] = [];
    }

    // Criar stream controller se não existir
    if (!_streamControllers.containsKey(conversationId)) {
      final controller = StreamController<List<MessageModel>>.broadcast();
      _streamControllers[conversationId] = controller;

      // Emitir após o subscriber se conectar
      Future.microtask(
        () => controller.add(List.from(_mensagens[conversationId]!)),
      );
    }

    return _streamControllers[conversationId]!.stream;
  }

  Future<void> sendMessage(String conversationId, String text) async {
    if (!_mensagens.containsKey(conversationId)) {
      _mensagens[conversationId] = [];
    }

    // Criar mensagem do usuário
    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: 'me',
      sentAt: DateTime.now(),
    );

    _mensagens[conversationId]!.add(userMessage);
    _emitMessages(conversationId);

    // Simular resposta do proprietário após 1.5 segundos
    await Future.delayed(const Duration(milliseconds: 1500));

    final botResponse = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _generateBotResponse(text),
      senderId: 'proprietario',
      sentAt: DateTime.now(),
    );

    _mensagens[conversationId]!.add(botResponse);
    _emitMessages(conversationId);
  }

  void _emitMessages(String conversationId) {
    if (_streamControllers.containsKey(conversationId)) {
      _streamControllers[conversationId]!.add(
        List.from(_mensagens[conversationId]!),
      );
    }
  }

  String _generateBotResponse(String userMessage) {
    final responses = [
      'Ótimo! Posso agendar uma visita para você?',
      'Temos desconto especial para pagamento à vista! Quer saber mais?',
      'Este imóvel é muito procurado. Quer agendar uma visita logo?',
      'Que bom! Tem alguma dúvida sobre o imóvel?',
      'Posso enviar mais fotos por e-mail?',
      'A documentação está em ordem. Quando você gostaria de visitar?',
      'Excelente escolha! Quando você teria disponibilidade?',
    ];

    return responses[userMessage.length % responses.length];
  }

  void dispose() {
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }
}
