import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/chat_service.dart';
import '../screens/chat_screen.dart';

class BuyerChatsScreen extends StatefulWidget {
  const BuyerChatsScreen({super.key});

  @override
  State<BuyerChatsScreen> createState() => _BuyerChatsScreenState();
}

class _BuyerChatsScreenState extends State<BuyerChatsScreen> {
  final _chatService = ChatService();
  final _supabase    = Supabase.instance.client;

  // ── Stream de chats donde soy el comprador ──────────────
  Stream<List<Map<String, dynamic>>> _chatsStream() {
    final buyerId = _chatService.currentUserId;
    if (buyerId == null) return const Stream.empty();

    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('buyer_id', buyerId)
        .order('last_message_at', ascending: false)
        .map((data) => data.cast<Map<String, dynamic>>());
  }

  // Mensajes no leídos de un chat (los del vendedor que no he leído)
  Future<int> _unreadCount(String chatId) async {
    final myId = _chatService.currentUserId;
    if (myId == null) return 0;
    try {
      final result = await _supabase
          .from('messages')
          .select('id')
          .eq('chat_id', chatId)
          .neq('sender_id', myId)
          .eq('is_read', false);
      return (result as List).length;
    } catch (_) {
      return 0;
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    final dt   = DateTime.parse(timestamp).toLocal();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inHours < 1)   return '${diff.inMinutes}m';
    if (diff.inDays < 1)    return '${diff.inHours}h';
    if (diff.inDays < 7)    return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Conversaciones')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatsStream(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar chats',
                  style: TextStyle(color: Colors.red[300])),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 72,
                      color: theme.textTheme.bodySmall?.color),
                  const SizedBox(height: 20),
                  Text('Sin conversaciones',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Cuando preguntes a un vendedor\naparecerá aquí',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(height: 1.5),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 80,
              endIndent: 16,
              color: theme.dividerColor,
            ),
            itemBuilder: (context, i) {
              final chat   = chats[i];
              final chatId = chat['id'] as String;
              return _ChatTile(
                chat: chat,
                chatService: _chatService,
                formatTime: _formatTime,
                unreadFuture: _unreadCount(chatId),
                theme: theme,
              );
            },
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Tile individual
// ──────────────────────────────────────────────────────────
class _ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final ChatService chatService;
  final String Function(String?) formatTime;
  final Future<int> unreadFuture;
  final ThemeData theme;

  const _ChatTile({
    required this.chat,
    required this.chatService,
    required this.formatTime,
    required this.unreadFuture,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final chatId      = chat['id'] as String;
    final productName = chat['product_name'] as String? ?? 'Producto';
    final lastMsg     = chat['last_message']  as String? ?? 'Sin mensajes';
    final lastAt      = chat['last_message_at'] as String?;
    final timeLabel   = formatTime(lastAt);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            otherUserName: 'Vendedor · $productName',
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // ── Avatar del producto ──
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.storefront_outlined,
                color: theme.colorScheme.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMsg,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Hora + badge ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeLabel, style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                FutureBuilder<int>(
                  future: unreadFuture,
                  builder: (_, snap) {
                    final count = snap.data ?? 0;
                    if (count == 0) return const SizedBox(height: 18);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
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