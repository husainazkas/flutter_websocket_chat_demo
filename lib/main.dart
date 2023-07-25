import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_websocket_chat_demo/chat_room_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Demonstrate Chat Websocket',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _userIdTextController = TextEditingController();
  final TextEditingController _recipientIdTextController =
      TextEditingController();
  final TextEditingController _recipientNameTextController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _userIdTextController.dispose();
    _recipientIdTextController.dispose();
    _recipientNameTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userIdTextController,
                    decoration: const InputDecoration(
                      labelText: 'User Id',
                    ),
                    maxLines: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: _recipientIdTextController,
                    decoration: const InputDecoration(
                      labelText: 'Recipient Id',
                    ),
                    maxLines: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _recipientNameTextController,
              decoration: const InputDecoration(
                labelText: 'Recipient Name',
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final userId = int.tryParse(_userIdTextController.text);
                final recipientId =
                    int.tryParse(_recipientIdTextController.text);
                final recipientName = _recipientNameTextController.text.trim();

                if (userId == null ||
                    recipientId == null ||
                    recipientName.isEmpty) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => ChatRoomPage(
                      userId: userId,
                      recipientId: recipientId,
                      recipientName: recipientName,
                    ),
                  ),
                );
              },
              child: const Text('Go to Demo'),
            ),
          ],
        ),
      ),
    );
  }
}
