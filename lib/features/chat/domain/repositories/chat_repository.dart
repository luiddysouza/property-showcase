import '../entities/message.dart';

abstract class ChatRepository {
  Stream<List<Message>> watchMessages(String conversationId);
  Future<void> sendMessage(String conversationId, String text);
  void dispose();
}
