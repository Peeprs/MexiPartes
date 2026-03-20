import 'package:flutter/material.dart';
import 'package:mexipartes/screens/seller/seller_chats_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/chat_service.dart';
import '../../screens/seller/seller_dashboard_screen.dart';

/// Botón flotante que muestra el contador de mensajes no leídos
/// y abre la lista de chats del vendedor al presionarlo.
///
/// Uso: agrégalo como [floatingActionButton] en cualquier Scaffold,
/// o apílalo junto a otro FAB existente.
class SellerChatFab extends StatefulWidget {
  const SellerChatFab({super.key});

  @override
  State<SellerChatFab> createState() => _SellerChatFabState();
}

class _SellerChatFabState extends State<SellerChatFab>
    with SingleTickerProviderStateMixin {
  final _supabase    = Supabase.instance.client;
  final _chatService = ChatService();

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  int _totalUnread = 0;

  @override
  void initState() {
    super.initState();

    // Animación de pulso cuando hay mensajes sin leer
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _listenUnread();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────
  // Escuchar cambios en tiempo real de mensajes no leídos
  // ──────────────────────────────────────────────────────
  void _listenUnread() {
    final sellerId = _chatService.currentUserId;
    if (sellerId == null) return;

    // Recontamos cada vez que cambia cualquier mensaje
    _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('is_read', false)
        .listen((msgs) async {
          if (!mounted) return;

          // Filtrar solo los mensajes de chats donde soy vendedor
          // y que NO son míos (son del comprador)
          int count = 0;
          for (final msg in msgs) {
            final senderId = msg['sender_id'] as String?;
            if (senderId == sellerId) continue; // son míos

            final chatId = msg['chat_id'] as String?;
            if (chatId == null) continue;

            // Verificar que soy el vendedor de este chat
            try {
              final chat = await _supabase
                  .from('chats')
                  .select('seller_id')
                  .eq('id', chatId)
                  .maybeSingle();
              if (chat?['seller_id'] == sellerId) count++;
            } catch (_) {}
          }

          if (!mounted) return;
          setState(() => _totalUnread = count);

          // Activar/desactivar pulso
          if (count > 0 && !_pulseCtrl.isAnimating) {
            _pulseCtrl.repeat(reverse: true);
          } else if (count == 0 && _pulseCtrl.isAnimating) {
            _pulseCtrl.stop();
            _pulseCtrl.reset();
          }
        });
  }

  void _openChats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SellerChatsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _totalUnread > 0 ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Botón principal ──
          FloatingActionButton(
            heroTag: 'seller_chat_fab',
            onPressed: _openChats,
            backgroundColor: Colors.redAccent,
            tooltip: 'Mensajes de compradores',
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),

          // ── Badge de no leídos ──
          if (_totalUnread > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  _totalUnread > 99 ? '99+' : '$_totalUnread',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}