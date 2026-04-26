import 'package:flutter/material.dart';
import '../../../../../core/design/app_colors.dart';
import '../../../../../core/design/app_spacing.dart';

class ChatInput extends StatefulWidget {
  final void Function(String text) onSend;

  const ChatInput({
    super.key,
    required this.onSend,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isEmpty = _controller.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Escreva uma mensagem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => !_isEmpty ? _sendMessage() : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: _isEmpty ? null : _sendMessage,
            child: Container(
              decoration: BoxDecoration(
                color: _isEmpty ? AppColors.inactive : AppColors.primary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.send,
                color: _isEmpty ? Colors.grey : AppColors.textOnPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
