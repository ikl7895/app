import 'package:flutter/material.dart';
import '../services/dialogflow_service.dart';
import '../providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final DialogflowService _dialogflowService = DialogflowService();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeDialogflow();
    _messages.add(const ChatMessage(
      text: 'Hello! I am your mental health assistant.\nI can chat with you, listen to your thoughts, or give you some suggestions.\nHow can I help you today?',
      isUser: false,
    ));
  }

  Future<void> _initializeDialogflow() async {
    try {
      await _dialogflowService.initialize();
    } catch (e) {
      print('Dialogflow initialization error: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _dialogflowService.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitted(String text) async {
    _messageController.clear();
    setState(() {
      _messages.insert(0, ChatMessage(
        text: text,
        isUser: true,
      ));
      _isTyping = true;
    });

    try {
      final response = await _dialogflowService.getResponse(text);
      setState(() {
        _messages.insert(0, ChatMessage(
          text: response,
          isUser: false,
        ));
      });
    } catch (e) {
      setState(() {
        _messages.insert(0, ChatMessage(
          text: 'Sorry, I am unable to respond at the moment. Please try again later.',
          isUser: false,
        ));
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Clear navigation stack and return to the home page
            Navigator.of(context).popUntil((route) => route.isFirst);
            // Set bottom navigation index to the home page
            context.read<NavigationProvider>().setIndex(0);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onSubmitted: _isTyping ? null : _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isTyping ? Icons.hourglass_empty : Icons.send,
                color: Colors.white,
              ),
              onPressed: _isTyping
                  ? null
                  : () {
                if (_messageController.text.isNotEmpty) {
                  _handleSubmitted(_messageController.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.support_agent, color: Colors.blue),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 20),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 12.0),
              child: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.person, color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}
