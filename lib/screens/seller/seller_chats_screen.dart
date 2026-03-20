import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/chat_service.dart';
import '../chat_screen.dart';

class SellerChatsScreen extends StatefulWidget {
  const SellerChatsScreen({super.key});

  @override
  State<SellerChatsScreen> createState() => _SellerChatsScreenState();
}

class _SellerChatsScreenState extends State<SellerChatsScreen> {
  final _chatService = ChatService();
  final _supabase = Supabase.instance.client;

  // ──────────────────────────────────────────────────────
  // Stream de chats donde soy el vendedor, ordenados por
  // último mensaje
  // ──────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> _chatsStream() {
    final sellerId = _chatService.currentUserId;
    if (sellerId == null) return const Stream.empty();

    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('seller_id', sellerId)
        .order('last_message_at', ascending: false)
        .map((data) => data.cast<Map<String, dynamic>>());
  }

  // Contar mensajes no leídos de un chat específico
  Future<int> _unreadCount(String chatId) async {
    final myId = _chatService.currentUserId;
    if (myId == null) return 0;
    try {
      final result = await _supabase
          .from('messages')
          .select('id')
          .eq('chat_id', chatId)
          .neq('sender_id', myId)   // mensajes del comprador
          .eq('is_read', false);
      return (result as List).length;
    } catch (_) {
      return 0;
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.parse(timestamp).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1)  return 'ahora';
    if (diff.inHours < 1)    return '${diff.inMinutes}m';
    if (diff.inDays < 1)     return '${diff.inHours}h';
    if (diff.inDays < 7)     return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mensajes de Compradores'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatsStream(),
        builder: (context, snapshot) {
          // ── Cargando ──
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          // ── Error ──
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar chats',
                    style: TextStyle(color: Colors.red[300]),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data ?? [];

          // ── Sin chats ──
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 72,
                    color: isDark ? Colors.grey[700] : Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sin mensajes aún',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuando un comprador te escriba\naparecerá aquí',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Lista ──
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 80,
              endIndent: 16,
              color: isDark ? Colors.white10 : Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatTile(
                chat: chat,
                chatService: _chatService,
                formatTime: _formatTime,
                unreadCountFuture: _unreadCount(chat['id'] as String),
              );
            },
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Tile individual de cada chat
// ──────────────────────────────────────────────────────────
class _ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final ChatService chatService;
  final String Function(String?) formatTime;
  final Future<int> unreadCountFuture;

  const _ChatTile({
    required this.chat,
    required this.chatService,
    required this.formatTime,
    required this.unreadCountFuture,
  });

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final chatId    = chat['id'] as String;
    final buyerId   = chat['buyer_id'] as String? ?? '';
    final productName = chat['product_name'] as String? ?? 'Producto';
    final lastMsg   = chat['last_message'] as String? ?? 'Sin mensajes';
    final lastAt    = chat['last_message_at'] as String?;
    final timeLabel = formatTime(lastAt);

    // Inicial del comprador (usamos los primeros 2 chars del UUID como placeholder)
    final avatarLabel = buyerId.isNotEmpty
        ? buyerId.substring(0, 2).toUpperCase()
        : '??';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chatId,
              otherUserName: 'Comprador · $productName',
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // ── Avatar ──
            CircleAvatar(
              radius: 26,
              backgroundColor: isDark
                  ? Colors.redAccent.withOpacity(0.15)
                  : Colors.red[50],
              child: Text(
                avatarLabel,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Producto
                  Text(
                    productName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Último mensaje
                  Text(
                    lastMsg,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Derecha: hora + badge ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 6),
                FutureBuilder<int>(
                  future: unreadCountFuture,
                  builder: (context, snap) {
                    final count = snap.data ?? 0;
                    if (count == 0) return const SizedBox(height: 18);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}