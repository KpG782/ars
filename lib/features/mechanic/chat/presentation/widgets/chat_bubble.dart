import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import '../../domain/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        mainAxisAlignment: message.isFromMechanic
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isFromMechanic) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.grey,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: message.type == MessageType.image
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isFromMechanic
                    ? AppTheme.primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isFromMechanic ? 18 : 4),
                  bottomRight: Radius.circular(message.isFromMechanic ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.image)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: message.mediaUrl != null
                          ? Image.network(
                              message.mediaUrl!,
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 220,
                                      height: 220,
                                      color: AppTheme.grey300,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 220,
                                  height: 220,
                                  color: AppTheme.grey300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 220,
                              height: 220,
                              color: AppTheme.grey300,
                              child: const Center(
                                child: Icon(Icons.image, size: 50),
                              ),
                            ),
                    )
                  else
                    Text(
                      message.content,
                      style: TextStyle(
                        color: message.isFromMechanic
                            ? Colors.white
                            : Colors.black87,
                        fontSize: AppTheme.fontSize15_5,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        letterSpacing: 0.1,
                      ),
                    ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: message.type == MessageType.image
                        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                        : EdgeInsets.zero,
                    child: Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: message.isFromMechanic
                            ? Colors.white.withValues(alpha: 0.75)
                            : AppTheme.grey600,
                        fontSize: AppTheme.fontSize11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromMechanic) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.build, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
