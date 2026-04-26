import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_mock_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatMockDatasource _datasource;

  ChatRepositoryImpl(this._datasource);

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    return _datasource.watchMessages(conversationId);
  }

  @override
  Future<void> sendMessage(String conversationId, String text) async {
    return _datasource.sendMessage(conversationId, text);
  }

  @override
  void dispose() {
    _datasource.dispose();
  }
}
