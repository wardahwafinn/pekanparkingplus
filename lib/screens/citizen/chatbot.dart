import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Initialize with a late list to access context after build
  late final List<ChatMessage> _messages;

  final List<String> quickReplies = [
    'How to pay parking?',
    'How to pay fines?',
    'Add new vehicle',
    'Check parking history',
    'Report illegal parking',
    'Contact support',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize messages list in initState where we can't access context yet
    // We'll add the initial message after the first build
    _messages = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add initial message only if list is empty
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          message:
              'Hello! I\'m your PekanParking Plus assistant. How can I help you today?',
          isUser: false,
          time: TimeOfDay.now().format(
            context,
          ), // Fixed: using context instead of ContextMenuButtonItem
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? predefinedMessage]) {
    final message = predefinedMessage ?? _messageController.text.trim();

    if (message.isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            message: message,
            isUser: true,
            time: TimeOfDay.now().format(context), // Fixed: using context
          ),
        );
        if (predefinedMessage == null) {
          _messageController.clear();
        }
      });

      _scrollToBottom();

      // Simulate bot response
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          // Check if widget is still mounted
          setState(() {
            _messages.add(
              ChatMessage(
                message: _getBotResponse(message),
                isUser: false,
                time: TimeOfDay.now().format(context), // Fixed: using context
              ),
            );
          });
          _scrollToBottom();
        }
      });
    }
  }

  String _getBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('parking') && message.contains('pay')) {
      return 'To pay for parking:\n1. Go to the ParkingPay section\n2. Select your vehicle\n3. Choose duration (hourly/monthly)\n4. Complete payment\n\nNeed more help?';
    } else if (message.contains('fine') || message.contains('saman')) {
      return 'To pay fines:\n1. Go to Home > SamanPay\n2. Select the fine you want to pay\n3. Click Pay \n4.\nYour fine will be marked as paid immediately.';
    } else if (message.contains('vehicle') && message.contains('add')) {
      return 'To add a new vehicle:\n1. Go to Home > Vehicle\n2. Tap "Add New Vehicle"\n3. Enter license plate number\n4. Enter vehicle owner/name\n5. Save\n\nYour vehicle will be available for parking payments.';
    } else if (message.contains('history')) {
      return 'To check parking history:\n1. Go to the History tab\n2. View all your past transactions\n3. See parking payments and fine payments\n\nHistory shows date, amount, and vehicle details.';
    } else if (message.contains('report')) {
      return 'To report illegal parking:\n1. Go to Home > Report\n2. Take photos of the violation\n3. Enter location details\n4. Add license plate (if visible)\n5. Describe the violation\n6. Submit report\n\nThank you for helping maintain parking order!';
    } else if (message.contains('support') || message.contains('help')) {
      return 'For additional support:\n📧 Email: support@pekanparkingplus.com\n📞 Phone: 1-300-PARKING\n🕒 Operating hours: 8 AM - 6 PM\n\nYou can also check our FAQ section in Profile > FAQ.';
    } else if (message.contains('hello') || message.contains('hi')) {
      return 'Hello! I\'m here to help you with PekanParking Plus. What would you like to know about?';
    } else if (message.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help you with today?';
    } else {
      return 'I understand you\'re asking about "${userMessage}". Let me help you with that.\n\nFor specific issues, you can:\n• Check our FAQ section\n• Contact human support\n• Use the quick replies below\n\nWhat would you like to know more about?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chat Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Colors.white],
            stops: [0.0, 0.1],
          ),
        ),
        child: Column(
          children: [
            // Quick replies section
            if (_messages.length <= 1)
              _buildQuickReplies(), // Changed from <= 2 to <= 1
            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildChatBubble(_messages[index]);
                },
              ),
            ),

            // Message input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Help:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                quickReplies.map((reply) {
                  return GestureDetector(
                    onTap: () => _sendMessage(reply),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        reply,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF4A90E2) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(message.isUser ? 12 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                fontSize: 14,
                color: message.isUser ? Colors.white : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                message.time,
                style: TextStyle(
                  fontSize: 11,
                  color: message.isUser ? Colors.white70 : Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _sendMessage(),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A90E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final String time;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.time,
  });
}
