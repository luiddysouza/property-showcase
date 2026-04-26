import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final DateTime sentAt;

  const Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.sentAt,
  });

  bool get isFromMe => senderId == 'me';

  @override
  List<Object?> get props => [id];
}
