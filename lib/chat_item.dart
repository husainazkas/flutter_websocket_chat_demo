import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_websocket_chat_demo/message.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this.text,
    this.status,
    required this.createdAt,
    this.isMe = false,
  });

  final String text;
  final MessageStatus? status;
  final DateTime createdAt;
  final bool isMe;

  IconData get iconStatus {
    switch (status) {
      case MessageStatus.sending:
        return Icons.timelapse_outlined;
      case MessageStatus.failure:
        return Icons.error_outline;
      default:
        return Icons.check;
    }
  }

  Widget _buildItem(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
          color: isMe ? Theme.of(context).colorScheme.onPrimary : null),
      child: IconTheme.merge(
        data: IconThemeData(
            color: isMe ? Theme.of(context).colorScheme.onPrimary : null),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            color: isMe
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onPrimary,
            boxShadow: kElevationToShadow[1],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(createdAt),
                        textScaleFactor: .85,
                      ),
                      if (isMe && status != null) ...[
                        const SizedBox(width: 4.0),
                        Icon(iconStatus, size: 16.0),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          Flexible(
            flex: 2,
            child: _buildItem(context),
          ),
        const Spacer(),
        if (isMe)
          Flexible(
            flex: 2,
            child: _buildItem(context),
          ),
      ],
    );
  }
}
