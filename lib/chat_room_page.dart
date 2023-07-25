import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_websocket_chat_demo/chat_item.dart';
import 'package:flutter_websocket_chat_demo/message.dart';
import 'package:web_socket_channel/io.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.userId,
    required this.recipientId,
    required this.recipientName,
  });

  final int userId;
  final int recipientId;
  final String recipientName;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = []; // Contains all messages
  IOWebSocketChannel? _socket; // Channel for websocket
  bool _isConnected = false; // Indicate socket is connect or not
  String _messageInfo = 'Connecting...'; // Information while messages are empty

  @override
  void initState() {
    super.initState();
    _connectToServer(); // Initialize websocket client
  }

  @override
  void dispose() {
    super.dispose();
    _socket?.sink.close(); // Need to close socket
  }

  Future<void> _connectToServer() async {
    try {
      // Connect to socket with passing current user id
      _socket = IOWebSocketChannel.connect(
        'ws://10.0.2.2:8009/${widget.userId}',
      );

      // Listen events from socket
      _socket!.stream.listen((rawEvent) {
        // Parse encoded json string to json object
        final event = jsonDecode(rawEvent);

        // Handle event per command (cmd)
        switch (event['cmd']) {
          case 'connection':
            if ((event['message'] as String).contains('success')) {
              _isConnected = true;
              _messageInfo = 'You are connected, send any message!';
            } else if ((event['message'] as String).contains('fail')) {
              _isConnected = false;
              _messageInfo = 'Failed to connect';
            }

            if (mounted) setState(() {});
            break;
          case 'send':
            if (event['data'] != null) {
              // Parse data to message data model
              final message = Message.fromJson(event['data']);
              if ((event['message'] as String).contains('sent')) {
                // Update status last sent message to success
                _messages[_messages.indexOf(message)] = message.copyWith(
                  status: MessageStatus.success,
                );
              } else if ((event['message'] as String).contains('fail')) {
                // Update status last sent message to failure
                final message = _messages[0];
                _messages[0] = message.copyWith(
                  status: MessageStatus.failure,
                );
              } else if (message.senderId == widget.recipientId) {
                // Add message data to messages list
                _messages.insert(0, message);
              }

              if (mounted) setState(() {});
            }
            break;
        }
      }, onDone: () {
        // If WebSocket is disconnected
        _isConnected = false;
        _socket = null;

        _messageInfo =
            'Server encountered problem or shut down, you are disconnected';

        if (mounted) setState(() {});
      }, onError: (error) {
        _messageInfo = error.toString();
        if (mounted) setState(() {});
      });
    } catch (e) {
      _messageInfo = 'Oopss.. Can\'t connect to server\n$e';
      if (mounted) setState(() {});
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _controller.text = '';

      final message = Message(
        text: text,
        receiverId: widget.recipientId,
        senderId: widget.userId,
        status: MessageStatus.sending,
        createdAt: DateTime.now(),
      );

      // Encode message then send message to socket
      _socket!.sink.add(jsonEncode({'cmd': 'send', 'data': message.toJson()}));
      _messages.insert(0, message);

      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          _messageInfo,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      reverse: true,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _messages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16.0),
                      itemBuilder: (context, index) => ChatItem(
                        text: _messages[index].text,
                        status: _messages[index].status,
                        createdAt: _messages[index].createdAt,
                        isMe: _messages[index].senderId == widget.userId,
                      ),
                    ),
            ),
            SizedBox(
              height: kToolbarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(60.0)),
                          boxShadow: kElevationToShadow[2],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: TextField(
                            enabled: _isConnected,
                            controller: _controller,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Type a message...',
                            ),
                            textInputAction: TextInputAction.newline,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                        boxShadow: kElevationToShadow[2],
                      ),
                      child: IconButton(
                        onPressed: !_isConnected ? null : _sendMessage,
                        icon: const Icon(Icons.send),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
