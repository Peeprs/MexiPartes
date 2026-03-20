import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

/// Servicio de escucha de eventos en tiempo real
class RealtimeNotificationService {
  static final RealtimeNotificationService _instance =
      RealtimeNotificationService._internal();
  factory RealtimeNotificationService() => _instance;
  RealtimeNotificationService._internal();

  final _supabase = Supabase.instance.client;
  RealtimeChannel? _ordersChannel;
  RealtimeChannel? _stockChannel;
  String? _currentSellerId;

  /// Iniciar escucha de nuevas órdenes (para vendedores)
  Future<void> startListeningForOrders(String sellerId) async {
    _currentSellerId = sellerId;

    // Cancelar suscripción anterior si existe
    if (_ordersChannel != null) {
      await _supabase.removeChannel(_ordersChannel!);
    }

    // Crear canal de escucha para la tabla 'orders'
    _ordersChannel = _supabase
        .channel('orders_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'orders',
          callback: _handleNewOrder,
        )
        .subscribe();

    print('🔔 Escuchando nuevas órdenes para vendedor: $sellerId');
  }

  /// Manejar nueva orden recibida
  void _handleNewOrder(PostgresChangePayload payload) {
    print('📦 Nueva orden detectada: ${payload.newRecord}');

    try {
      final orderData = payload.newRecord;
      final items = orderData['items'] as List<dynamic>? ?? [];
      final orderId = orderData['id'];
      final totalVal = orderData['total'];
      final double total = (totalVal is num) ? totalVal.toDouble() : 0.0;

      // Verificar si esta orden contiene productos del vendedor actual
      bool isMyOrder = false;
      String productName = '';

      for (var item in items) {
        final sellerId = item['seller_id'] as String?;
        if (sellerId == _currentSellerId) {
          isMyOrder = true;
          productName = item['product_name'] ?? 'Producto';
          break;
        }
      }

      // Si es una orden que nos concierne, enviar notificación
      if (isMyOrder) {
        _sendSellerNotification(
          orderId: orderId?.toString() ?? 'N/A',
          productName: productName,
          total: total,
        );
      }
    } catch (e) {
      print('⚠️ Error procesando orden: $e');
    }
  }

  /// Enviar notificación al vendedor
  Future<void> _sendSellerNotification({
    required String orderId,
    required String productName,
    required double total,
  }) async {
    await NotificationService().showNotification(
      title: '🎉 ¡Nueva Venta!',
      body: 'Vendiste "$productName" por \$$total',
      payload: 'order_$orderId',
    );

    print('� Notificación de venta enviada');
  }

  /// Escuchar cambios de stock (para vendedores)
  Future<void> startListeningForStockChanges(String sellerId) async {
    if (_stockChannel != null) {
      await _supabase.removeChannel(_stockChannel!);
    }

    _stockChannel = _supabase
        .channel('stock_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            final newRecord = payload.newRecord;
            final productSellerId = newRecord['seller_id'] as String?;

            if (productSellerId == sellerId) {
              final stockVal = newRecord['stock'];
              final stock = (stockVal is num) ? stockVal.toInt() : 0;
              final productName = newRecord['nombre'] as String? ?? 'Producto';

              // Alerta de stock bajo
              if (stock > 0 && stock <= 5) {
                NotificationService().notifyLowStock(productName, stock);
              }
            }
          },
        )
        .subscribe();

    print('📊 Escuchando cambios de stock');
  }

  /// Detener escucha
  Future<void> stopListening() async {
    if (_ordersChannel != null) {
      await _supabase.removeChannel(_ordersChannel!);
      _ordersChannel = null;
    }
    if (_stockChannel != null) {
      await _supabase.removeChannel(_stockChannel!);
      _stockChannel = null;
    }
    print('🔕 Notificaciones detenidas');
  }
}
