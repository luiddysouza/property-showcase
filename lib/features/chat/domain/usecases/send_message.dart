import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository _repository;

  SendMessage(this._repository);

  Future<void> call(String conversationId, String text) =>
      _repository.sendMessage(conversationId, text);
}
