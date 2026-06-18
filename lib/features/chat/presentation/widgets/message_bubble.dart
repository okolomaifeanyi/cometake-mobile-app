import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/chat.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.72,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppDimensions.radiusMd),
                    topRight: const Radius.circular(AppDimensions.radiusMd),
                    bottomLeft: Radius.circular(
                        isMe ? AppDimensions.radiusMd : AppDimensions.radiusXs),
                    bottomRight: Radius.circular(
                        isMe ? AppDimensions.radiusXs : AppDimensions.radiusMd),
                  ),
                ),
                child: Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isMe
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (showTime)
                Padding(
                  padding: const EdgeInsets.only(
                      top: 2,
                      left: AppDimensions.spacingXs,
                      right: AppDimensions.spacingXs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Formatters.time(message.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 2),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message.isRead
                              ? AppColors.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
