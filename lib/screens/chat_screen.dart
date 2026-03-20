import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _supabase = Supabase.instance.client;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  Map<String, dynamic>? _replyingTo;
  Map<String, dynamic>? _editingMsg;
  Timer? _typingTimer;
  StreamSubscription? _messagesSub;
  bool _isAppFocused = true;
  String? _firstNewMessageId;
  bool _hasFoundFirstNewMessage = false;
  final Map<String, Timer> _markAsReadTimers = {};
  final Set<String> _processedMessages = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _markMessagesAsRead();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isAppFocused = state == AppLifecycleState.resumed;
    });
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId) {
      _messagesSub?.cancel();
      _typingTimer?.cancel();
      for (var timer in _markAsReadTimers.values) {
        timer.cancel();
      }
      _markAsReadTimers.clear();
      _processedMessages.clear();
      setState(() {
        _editingMsg = null;
        _replyingTo = null;
        _hasFoundFirstNewMessage = false;
        _firstNewMessageId = null;
      });
      _markMessagesAsRead();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messagesSub?.cancel();
    _typingTimer?.cancel();
    for (var timer in _markAsReadTimers.values) {
      timer.cancel();
    }
    _markAsReadTimers.clear();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() {
    _messagesSub = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', widget.chatId)
        .listen((msgs) async {
          if (!_hasFoundFirstNewMessage && mounted) {
            try {
              final list = msgs.cast<Map<String, dynamic>>().toList()
                ..sort(
                  (a, b) => (a['created_at'] as String).compareTo(
                    b['created_at'] as String,
                  ),
                );
              final firstUnread = list.firstWhere(
                (m) => m['sender_type'] == 'guest' && m['is_read'] != true,
              );
              setState(() {
                _firstNewMessageId = firstUnread['id'];
                _hasFoundFirstNewMessage = true;
              });
            } catch (_) {
              _hasFoundFirstNewMessage = true;
            }
          }

          for (var msg in msgs) {
            if (msg['sender_type'] == 'guest') {
              final msgId = msg['id'] as String;

              if (_processedMessages.contains(msgId)) continue;
              _processedMessages.add(msgId);

              try {
                if (msg['is_delivered'] != true) {
                  await _supabase
                      .from('messages')
                      .update({'is_delivered': true})
                      .eq('id', msgId);
                }

                if (msg['is_read'] != true) {
                  _markAsReadTimers[msgId]?.cancel();
                  final delay = _isAppFocused ? 800 : 5000;

                  _markAsReadTimers[msgId] = Timer(
                    Duration(milliseconds: delay),
                    () async {
                      if (mounted) {
                        try {
                          await _supabase
                              .from('messages')
                              .update({'is_read': true})
                              .eq('id', msgId);
                        } catch (_) {}
                        _markAsReadTimers.remove(msgId);
                      }
                    },
                  );
                }
              } catch (_) {}
            }
          }
        });

    _supabase
        .channel('messages_status_${widget.chatId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: widget.chatId,
          ),
          callback: (payload) {
            if (mounted) {
              setState(() {});
            }
          },
        )
        .subscribe();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTime(String timestamp) {
    final dt = DateTime.parse(timestamp).toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildCheckmarks(Map<String, dynamic> msg, bool isMe) {
    if (!isMe) return const SizedBox.shrink();
    final isRead = msg['is_read'] == true;
    final isDelivered = msg['is_delivered'] == true;
    if (isRead) {
      return const Icon(Icons.done_all, size: 16, color: Colors.cyanAccent);
    }
    if (isDelivered) {
      return const Icon(Icons.done_all, size: 16, color: Colors.white70);
    }
    return const Icon(Icons.check, size: 16, color: Colors.white60);
  }

  Widget _buildDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
      ),
    );
  }

  void _onTyping() async {
    await _supabase
        .from('chats')
        .update({'is_typing_admin': true})
        .eq('id', widget.chatId);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () async {
      await _supabase
          .from('chats')
          .update({'is_typing_admin': false})
          .eq('id', widget.chatId);
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_editingMsg != null) {
      await _supabase
          .from('messages')
          .update({'content': text, 'is_edited': true})
          .eq('id', _editingMsg!['id']);
      setState(() => _editingMsg = null);
    } else {
      final msgData = <String, dynamic>{
        'chat_id': widget.chatId,
        'content': text,
        'sender_type': 'admin',
      };
      if (_replyingTo != null) {
        msgData['reply_to_id'] = _replyingTo!['id'];
        msgData['reply_to_content'] = _replyingTo!['content'];
      }
      await _supabase.from('messages').insert(msgData);
      setState(() => _replyingTo = null);
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
                  .from('messages')
                  .stream(primaryKey: ['id'])
                  .eq('chat_id', widget.chatId)
                  .order('created_at', ascending: true),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = snapshot.data!;

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length + 1,
                  itemBuilder: (context, i) {
                    // Typing indicator al final
                    if (i == msgs.length) {
                      return StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _supabase
                            .from('chats')
                            .stream(primaryKey: ['id'])
                            .eq('id', widget.chatId),
                        builder: (context, chatSnap) {
                          if (!chatSnap.hasData || chatSnap.data!.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final isTyping =
                              chatSnap.data!.first['is_typing_guest'] == true;
                          if (!isTyping) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15)
                                      .copyWith(
                                        bottomLeft: const Radius.circular(0),
                                      ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildDot()
                                        .animate(onPlay: (c) => c.repeat())
                                        .fade(
                                          begin: 0.3,
                                          end: 1,
                                          duration: 400.ms,
                                        )
                                        .then()
                                        .fade(
                                          begin: 1,
                                          end: 0.3,
                                          duration: 400.ms,
                                        ),
                                    const SizedBox(width: 4),
                                    _buildDot()
                                        .animate(
                                          delay: 200.ms,
                                          onPlay: (c) => c.repeat(),
                                        )
                                        .fade(
                                          begin: 0.3,
                                          end: 1,
                                          duration: 400.ms,
                                        )
                                        .then()
                                        .fade(
                                          begin: 1,
                                          end: 0.3,
                                          duration: 400.ms,
                                        ),
                                    const SizedBox(width: 4),
                                    _buildDot()
                                        .animate(
                                          delay: 400.ms,
                                          onPlay: (c) => c.repeat(),
                                        )
                                        .fade(
                                          begin: 0.3,
                                          end: 1,
                                          duration: 400.ms,
                                        )
                                        .then()
                                        .fade(
                                          begin: 1,
                                          end: 0.3,
                                          duration: 400.ms,
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fade().slideY(begin: 0.5, end: 0);
                        },
                      );
                    }

                    final msg = msgs[i];
                    final isMe = msg['sender_type'] == 'admin';
                    final time = _formatTime(msg['created_at']);
                    final isEdited = msg['is_edited'] == true;
                    final isFirstNew =
                        _firstNewMessageId != null &&
                        msg['id'] == _firstNewMessageId;

                    Widget messageWidget = Dismissible(
                      key: Key(msg['id']),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (direction) async {
                        setState(() => _replyingTo = msg);
                        return false;
                      },
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        color: Colors.transparent,
                        child: const Icon(Icons.reply, color: Colors.cyan),
                      ),
                      child: GestureDetector(
                        onLongPress: () {
                          FocusScope.of(context).unfocus();
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              transitionDuration:
                                  const Duration(milliseconds: 350),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 350),
                              pageBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                              ) {
                                return MenuContextualHero(
                                  msg: msg,
                                  isMe: isMe,
                                  time: time,
                                  onReply: () => setState(
                                    () => _replyingTo = msg,
                                  ),
                                  onEdit: () {
                                    _controller.text = msg['content'];
                                    setState(() {
                                      _editingMsg = msg;
                                      _replyingTo = null;
                                    });
                                  },
                                  onDelete: () async {
                                    await _supabase
                                        .from('messages')
                                        .delete()
                                        .eq('id', msg['id']);
                                  },
                                );
                              },
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'mensaje-${msg['id']}',
                          flightShuttleBuilder: (
                            flightContext,
                            animation,
                            flightDirection,
                            fromHeroContext,
                            toHeroContext,
                          ) {
                            return Material(
                              color: Colors.transparent,
                              child: toHeroContext.widget,
                            );
                          },
                          child: Material(
                            color: Colors.transparent,
                            child: Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.cyan[500]
                                        : (isDark
                                            ? const Color(0xFF1E1E1E)
                                            : Colors.white),
                                    borderRadius: BorderRadius.circular(16)
                                        .copyWith(
                                      bottomRight:
                                          isMe ? const Radius.circular(0) : null,
                                      bottomLeft: !isMe
                                          ? const Radius.circular(0)
                                          : null,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.end,
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                          top: 4.0,
                                          bottom: 2.0,
                                        ),
                                        child: Text(
                                          msg['content'],
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : (isDark
                                                    ? Colors.white
                                                    : Colors.black87),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          if (isEdited)
                                            Text(
                                              " (editado)",
                                              style: TextStyle(
                                                color: isMe
                                                    ? Colors.white60
                                                    : (isDark
                                                        ? Colors.white38
                                                        : Colors.black45),
                                                fontSize: 10,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          Text(
                                            time,
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white70
                                                  : (isDark
                                                      ? Colors.white54
                                                      : Colors.black54),
                                              fontSize: 11,
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            _buildCheckmarks(msg, isMe),
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
                      ),
                    ).animate().fade(duration: 400.ms, curve: Curves.easeOutQuad).slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        );

                    if (isFirstNew) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 24),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color: Colors.cyan,
                                    thickness: 1,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    "Mensajes Nuevos",
                                    style: TextStyle(
                                      color: Colors.cyan,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color: Colors.cyan,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          messageWidget,
                        ],
                      );
                    }

                    return messageWidget;
                  },
                );
              },
            ),
          ),
          _buildInput(isDark),
        ],
      ),
    );
  }

  Widget _buildInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_editingMsg != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.blue[900]!.withOpacity(0.3)
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: Colors.blue, width: 4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Editando mensaje...",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _editingMsg = null);
                    },
                  ),
                ],
              ),
            ),
          if (_replyingTo != null && _editingMsg == null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: Colors.cyan, width: 4),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Respondiendo a ${_replyingTo!['sender_type'] == 'guest' ? 'Invitado' : 'Ti'}",
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _replyingTo!['content'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => setState(() => _replyingTo = null),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (_) => _onTyping(),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: _editingMsg != null
                        ? "Edita tu mensaje..."
                        : "Escribe un mensaje...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF303030) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _editingMsg != null ? Icons.check_circle : Icons.send,
                  color: _editingMsg != null ? Colors.blue : Colors.cyan,
                ),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MenuContextualHero extends StatelessWidget {
  final dynamic msg;
  final bool isMe;
  final String time;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuContextualHero({
    super.key,
    required this.msg,
    required this.isMe,
    required this.time,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdited = msg['is_edited'] == true;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'mensaje-${msg['id']}',
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.cyan[500]
                              : (isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : null,
                            bottomLeft: !isMe ? const Radius.circular(0) : null,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8.0,
                                top: 4.0,
                                bottom: 2.0,
                              ),
                              child: Text(
                                msg['content'],
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white
                                          : Colors.black87),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isEdited)
                                  Text(
                                    " (editado)",
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white60
                                          : (isDark
                                              ? Colors.white38
                                              : Colors.black45),
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white70
                                        : (isDark
                                            ? Colors.white54
                                            : Colors.black54),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: ((value - 0.8) / 0.2).clamp(0.0, 1.0),
                      child: child,
                    ),
                  ),
                  child: Container(
                    width: 250,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _menuOption(
                          'Responder',
                          CupertinoIcons.reply,
                          null,
                          () {
                            Navigator.pop(context);
                            onReply();
                          },
                          isDark,
                        ),
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        if (isMe) ...[
                          _menuOption(
                            'Editar',
                            CupertinoIcons.pencil,
                            null,
                            () {
                              Navigator.pop(context);
                              onEdit();
                            },
                            isDark,
                          ),
                          Divider(
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ],
                        _menuOption(
                          'Resumir con IA',
                          CupertinoIcons.bolt,
                          Colors.cyan,
                          () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Próximamente: IA")),
                            );
                          },
                          isDark,
                          textColor: Colors.cyan,
                        ),
                        if (isMe) ...[
                          Divider(
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          _menuOption(
                            'Eliminar',
                            CupertinoIcons.delete,
                            Colors.red,
                            () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            isDark,
                            textColor: Colors.red,
                          ),
                        ],
                      ],
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

  Widget _menuOption(
    String title,
    IconData icon,
    Color? iconColor,
    VoidCallback onTap,
    bool isDark, {
    Color? textColor,
  }) {
    final tColor =
        textColor ?? (isDark ? Colors.white : const Color(0xFF2D3748));
    final iColor =
        textColor ?? (isDark ? Colors.white70 : (iconColor ?? Colors.blueGrey));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: tColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(icon, size: 20, color: iColor),
          ],
        ),
      ),
    );
  }
}
