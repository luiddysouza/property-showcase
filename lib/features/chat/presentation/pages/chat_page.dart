import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/design/app_colors.dart';
import '../../../../../core/design/app_typography.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatPage({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesStreamProvider(widget.conversationId));
    final sendMessage = ref.read(sendMessageProvider);

    // Auto-scroll ao receber nova mensagem
    ref.listen(
      messagesStreamProvider(widget.conversationId),
      (previous, next) {
        next.whenData((_) => _scrollToBottom());
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: AppTypography.heading2,
        ),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma mensagem ainda',
                      style: AppTypography.body,
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(message: messages[index]);
                  },
                );
              },
              loading: () => Center(
                child: Text(
                  'Carregando chat...',
                  style: AppTypography.body,
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar chat',
                      style: AppTypography.bodyBold,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Input de mensagem
          ChatInput(
            onSend: (text) async {
              await sendMessage.call(widget.conversationId, text);
            },
          ),
        ],
      ),
    );
  }
}
