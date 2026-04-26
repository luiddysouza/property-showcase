import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/chat_mock_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/watch_messages.dart';

// Datasource como singleton para manter estado entre navegações
final chatDatasourceProvider = Provider<ChatMockDatasource>((ref) {
  final ds = ChatMockDatasource();
  ref.onDispose(ds.dispose);
  return ds;
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.read(chatDatasourceProvider));
});

final watchMessagesProvider = Provider<WatchMessages>((ref) {
  return WatchMessages(ref.read(chatRepositoryProvider));
});

final sendMessageProvider = Provider<SendMessage>((ref) {
  return SendMessage(ref.read(chatRepositoryProvider));
});

// Stream de mensagens por conversationId
final messagesStreamProvider =
    StreamProvider.family<List<Message>, String>((ref, conversationId) {
  return ref.read(watchMessagesProvider).call(conversationId);
});
