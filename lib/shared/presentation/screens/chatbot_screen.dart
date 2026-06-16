import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/shared/infrastructure/chatbot_di.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';
import 'package:uuid/uuid.dart';

class ChatbotAssistantScreen extends StatefulWidget {
  const ChatbotAssistantScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotAssistantScreen> createState() => _ChatbotAssistantScreenState();
}

class _ChatbotAssistantScreenState extends State<ChatbotAssistantScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final Uuid _uuid = const Uuid();

  final List<Map<String, dynamic>> messages = [
    {'text': 'Hola, soy Finio. ¿Cómo puedo ayudarte hoy?', 'isUser': false},
  ];

  User? _currentUser;
  String _sessionId = '';
  bool _loadingUser = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await AuthDI.userRepository.getCurrentUser();
    if (!mounted) return;

    if (user == null) {
      context.go('/login');
      return;
    }

    setState(() {
      _currentUser = user;
      _sessionId = _uuid.v4();
      _loadingUser = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || _currentUser == null || _sessionId.isEmpty) return;

    setState(() {
      messages.add({'text': text, 'isUser': true});
      messageController.clear();
      _sending = true;
    });

    _scrollToBottom();

    try {
      final reply = await ChatbotDI.repository.sendMessage(
        message: text,
        userId: _currentUser!.id,
        sessionId: _sessionId,
      );

      if (!mounted) return;

      setState(() {
        messages.add({'text': reply, 'isUser': false});
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        messages.add({
          'text': 'No pude responder en este momento. Intenta otra vez.',
          'isUser': false,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar mensaje: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToBottom();
      }
    }
  }

  void _newChat() {
    setState(() {
      _sessionId = _uuid.v4();
      messages
        ..clear()
        ..add({
          'text': 'Hola, soy Finio. ¿Cómo puedo ayudarte hoy?',
          'isUser': false,
        });
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        title: Text(
          'Asistente Finio',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _sending ? null : _newChat,
            icon: const Icon(Icons.refresh),
            tooltip: 'Nuevo chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[i];
                final isUser = msg['isUser'] == true;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primaryGreen : AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['text']?.toString() ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.black : AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            left: false,
            right: false,
            bottom:
                true, // Esto crea el colchón de aire por encima de los botones de Android
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                8,
              ), // Ajustamos márgenes limpios
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sending ? null : _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        hintStyle: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppTheme.cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _sending ? null : _sendMessage,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors
                                    .black, // Color oscuro para que contraste
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
