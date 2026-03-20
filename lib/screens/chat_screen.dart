import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName; // Nombre del otro participante para el AppBar

  const ChatScreen({
    super.key,
    required this.chatId,
    this.otherUserName = 'Chat',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _chatService = ChatService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  Map<String, dynamic>? _replyingTo;
  Map<String, dynamic>? _editingMsg;
  Timer? _typingTimer;
  bool _isAppFocused = true;

  // IDs ya procesados para no repetir lógica de mark-as-read
  final Set<String> _processedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _isAppFocused = state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    // Apagar indicador de escritura al salir
    _chatService.setTyping(widget.chatId, false);
    super.dispose();
  }

  // --------------------------------------------------------
  // Scroll al fondo
  // --------------------------------------------------------
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // --------------------------------------------------------
  // Marcar mensajes como leídos (los del otro)
  // --------------------------------------------------------
  void _markIncomingAsRead(List<Map<String, dynamic>> msgs) {
    final myId = _chatService.currentUserId;
    for (final msg in msgs) {
      final senderId = msg['sender_id'] as String?;
      if (senderId == myId) continue; // Son míos, no los marco
      final msgId = msg['id'] as String;
      if (_processedIds.contains(msgId)) continue;
      _processedIds.add(msgId);

      // Marcar como entregado inmediatamente
      if (msg['is_delivered'] != true) {
        _chatService.markAsDelivered(msgId);
      }
      // Marcar como leído con delay según foco
      if (msg['is_read'] != true) {
        final delay = _isAppFocused ? 800 : 5000;
        Future.delayed(Duration(milliseconds: delay), () {
          if (mounted) _chatService.markAsRead(msgId);
        });
      }
    }
  }

  // --------------------------------------------------------
  // Indicador de escritura
  // --------------------------------------------------------
  void _onTyping() {
    _chatService.setTyping(widget.chatId, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _chatService.setTyping(widget.chatId, false);
    });
  }

  // --------------------------------------------------------
  // Enviar / Editar mensaje
  // --------------------------------------------------------
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    try {
      if (_editingMsg != null) {
        await _chatService.editMessage(
          messageId: _editingMsg!['id'] as String,
          newContent: text,
        );
        setState(() => _editingMsg = null);
      } else {
        await _chatService.sendMessage(
          chatId: widget.chatId,
          content: text,
          replyToId: _replyingTo?['id'] as String?,
          replyToContent: _replyingTo?['content'] as String?,
        );
        setState(() => _replyingTo = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --------------------------------------------------------
  // Helpers de UI
  // --------------------------------------------------------
  String _formatTime(String timestamp) {
    final dt = DateTime.parse(timestamp).toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildCheckmarks(Map<String, dynamic> msg) {
    final isRead = msg['is_read'] == true;
    final isDelivered = msg['is_delivered'] == true;
    if (isRead) {
      return const Icon(Icons.done_all, size: 14, color: Colors.cyanAccent);
    }
    if (isDelivered) {
      return const Icon(Icons.done_all, size: 14, color: Colors.white54);
    }
    return const Icon(Icons.check, size: 14, color: Colors.white38);
  }

  Widget _buildTypingDot({Duration delay = Duration.zero}) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[500],
        shape: BoxShape.circle,
      ),
    )
        .animate(delay: delay, onPlay: (c) => c.repeat())
        .fade(begin: 0.3, end: 1, duration: 400.ms)
        .then()
        .fade(begin: 1, end: 0.3, duration: 400.ms);
  }

  // --------------------------------------------------------
  // BUILD
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Indicador "escribiendo..." en el AppBar
            StreamBuilder<Map<String, dynamic>?>(
              stream: _chatService.chatStream(widget.chatId),
              builder: (context, snap) {
                final chat = snap.data;
                if (chat == null) return const SizedBox.shrink();

                final myId = _chatService.currentUserId;
                final buyerId = chat['buyer_id'] as String?;
                final isBuyer = myId == buyerId;

                // Si soy buyer, el otro es seller y viceversa
                final otherIsTyping = isBuyer
                    ? chat['is_typing_seller'] == true
                    : chat['is_typing_buyer'] == true;

                if (!otherIsTyping) return const SizedBox.shrink();

                return const Text(
                  'escribiendo...',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ],
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white10),
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.messagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                }

                final msgs = snapshot.data!;

                // Marcar mensajes entrantes como leídos
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _markIncomingAsRead(msgs);
                  _scrollToBottom();
                });

                if (msgs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: Colors.grey[800],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Inicia la conversación',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final msg = msgs[i];
                    final isMe = _chatService.isCurrentUserSender(
                      msg['sender_id'] as String,
                    );
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),

          // Input
          _buildInput(),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // Burbuja de mensaje
  // --------------------------------------------------------
  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final time = _formatTime(msg['created_at'] as String);
    final isEdited = msg['is_edited'] == true;
    final replyContent = msg['reply_to_content'] as String?;

    return Dismissible(
      key: Key('dismiss_${msg['id']}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        setState(() => _replyingTo = msg);
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.transparent,
        child: const Icon(Icons.reply, color: Colors.cyanAccent),
      ),
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showMessageMenu(context, msg, isMe);
        },
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFFD32F2F) // Rojo para mis mensajes
                      : const Color(0xFF1E1E1E), // Oscuro para los del otro
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight:
                        isMe ? const Radius.circular(2) : null,
                    bottomLeft:
                        !isMe ? const Radius.circular(2) : null,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Reply preview
                    if (replyContent != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(
                              color: Colors.cyanAccent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          replyContent,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],

                    // Contenido
                    Text(
                      msg['content'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Metadata: hora + editado + checks
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isEdited)
                          Text(
                            'editado · ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          _buildCheckmarks(msg),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fade(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  // --------------------------------------------------------
  // Menú contextual (long press)
  // --------------------------------------------------------
  void _showMessageMenu(
    BuildContext context,
    Map<String, dynamic> msg,
    bool isMe,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Preview del mensaje
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  '"${(msg['content'] as String).length > 60 ? (msg['content'] as String).substring(0, 60) + '...' : msg['content']}"',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              _menuOption(
                icon: CupertinoIcons.reply,
                label: 'Responder',
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _replyingTo = msg);
                },
              ),

              if (isMe) ...[
                _menuOption(
                  icon: CupertinoIcons.pencil,
                  label: 'Editar',
                  onTap: () {
                    Navigator.pop(context);
                    _controller.text = msg['content'] as String;
                    setState(() {
                      _editingMsg = msg;
                      _replyingTo = null;
                    });
                  },
                ),
                _menuOption(
                  icon: CupertinoIcons.delete,
                  label: 'Eliminar',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _chatService.deleteMessage(msg['id'] as String);
                  },
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? Colors.white;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: TextStyle(color: c, fontSize: 15)),
      onTap: onTap,
      dense: true,
    );
  }

  // --------------------------------------------------------
  // Input bar
  // --------------------------------------------------------
  Widget _buildInput() {
    return Container(
      color: const Color(0xFF111111),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner de edición
          if (_editingMsg != null)
            _buildBanner(
              icon: Icons.edit,
              color: Colors.blueAccent,
              label: 'Editando mensaje',
              onClose: () {
                _controller.clear();
                setState(() => _editingMsg = null);
              },
            ),

          // Banner de respuesta
          if (_replyingTo != null && _editingMsg == null)
            _buildBanner(
              icon: Icons.reply,
              color: Colors.cyanAccent,
              label: _replyingTo!['content'] as String,
              onClose: () => setState(() => _replyingTo = null),
            ),

          // Separador
          Container(height: 1, color: Colors.white10),

          // Campo de texto + botón
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (_) => _onTyping(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: _editingMsg != null
                          ? 'Edita tu mensaje...'
                          : 'Escribe un mensaje...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF222222),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _editingMsg != null
                          ? Colors.blueAccent
                          : Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _editingMsg != null ? Icons.check : Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onClose,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withOpacity(0.08),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.white38),
            onPressed: onClose,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}