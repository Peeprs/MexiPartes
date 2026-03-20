import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  // --------------------------------------------------------
  // Crear o recuperar un chat entre comprador y vendedor
  // para un producto específico
  // --------------------------------------------------------
  Future<String> getOrCreateChat({
    required String sellerId,
    required String productId,
    required String productName,
  }) async {
    final buyerId = currentUserId;
    if (buyerId == null) throw Exception('No hay sesión activa');
    if (buyerId == sellerId) throw Exception('No puedes chatear contigo mismo');

    // Buscar chat existente
    final existing = await _supabase
        .from('chats')
        .select('id')
        .eq('buyer_id', buyerId)
        .eq('seller_id', sellerId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    // Crear nuevo chat
    final result = await _supabase
        .from('chats')
        .insert({
          'buyer_id': buyerId,
          'seller_id': sellerId,
          'product_id': productId,
          'product_name': productName,
        })
        .select('id')
        .single();

    return result['id'] as String;
  }

  // --------------------------------------------------------
  // Enviar mensaje
  // --------------------------------------------------------
  Future<void> sendMessage({
    required String chatId,
    required String content,
    String? replyToId,
    String? replyToContent,
  }) async {
    final senderId = currentUserId;
    if (senderId == null) throw Exception('No hay sesión activa');

    final data = <String, dynamic>{
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content.trim(),
    };

    if (replyToId != null) {
      data['reply_to_id'] = replyToId;
      data['reply_to_content'] = replyToContent;
    }

    await _supabase.from('messages').insert(data);

    // Actualizar preview del chat
    await _supabase.from('chats').update({
      'last_message': content.trim(),
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', chatId);
  }

  // --------------------------------------------------------
  // Editar mensaje (solo el autor)
  // --------------------------------------------------------
  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    await _supabase.from('messages').update({
      'content': newContent.trim(),
      'is_edited': true,
    }).eq('id', messageId);
  }

  // --------------------------------------------------------
  // Eliminar mensaje (solo el autor)
  // --------------------------------------------------------
  Future<void> deleteMessage(String messageId) async {
    await _supabase.from('messages').delete().eq('id', messageId);
  }

  // --------------------------------------------------------
  // Marcar mensajes como entregados y leídos
  // --------------------------------------------------------
  Future<void> markAsDelivered(String messageId) async {
    await _supabase
        .from('messages')
        .update({'is_delivered': true})
        .eq('id', messageId);
  }

  Future<void> markAsRead(String messageId) async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('id', messageId);
  }

  // --------------------------------------------------------
  // Indicador de escritura
  // --------------------------------------------------------
  Future<void> setTyping(String chatId, bool isTyping) async {
    final userId = currentUserId;
    if (userId == null) return;

    // Determinar si soy buyer o seller
    final chat = await _supabase
        .from('chats')
        .select('buyer_id')
        .eq('id', chatId)
        .single();

    final isBuyer = chat['buyer_id'] == userId;
    final field = isBuyer ? 'is_typing_buyer' : 'is_typing_seller';

    await _supabase.from('chats').update({field: isTyping}).eq('id', chatId);
  }

  // --------------------------------------------------------
  // Stream de mensajes en tiempo real
  // --------------------------------------------------------
  Stream<List<Map<String, dynamic>>> messagesStream(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((data) => data.cast<Map<String, dynamic>>());
  }

  // --------------------------------------------------------
  // Stream del chat (para indicador de escritura)
  // --------------------------------------------------------
  Stream<Map<String, dynamic>?> chatStream(String chatId) {
    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('id', chatId)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  // --------------------------------------------------------
  // Lista de chats del usuario actual
  // --------------------------------------------------------
  Future<List<Map<String, dynamic>>> getMyChats() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final data = await _supabase
        .from('chats')
        .select()
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('last_message_at', ascending: false);

    return data.cast<Map<String, dynamic>>();
  }

  // --------------------------------------------------------
  // Helper: soy el comprador en este chat?
  // --------------------------------------------------------
  bool isCurrentUserSender(String senderId) => senderId == currentUserId;
}