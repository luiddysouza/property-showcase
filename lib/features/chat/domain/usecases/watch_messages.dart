import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class WatchMessages {
  final ChatRepository _repository;

  WatchMessages(this._repository);

  Stream<List<Message>> call(String conversationId) =>
      _repository.watchMessages(conversationId);
}
