import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Configuración para Android
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración para iOS
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Inicializar plugin con argumentos nombrados (según linter)
      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('🔔 Notificación tocada: ${response.payload}');
        },
      );

      // Configuración específica de Android (Canales y Permisos)
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
            _notifications
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidPlugin != null) {
          // Crear el canal de notificaciones
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              'mexipartes_channel',
              'Notificaciones Generales',
              description: 'Canal principal de notificaciones',
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            ),
          );

          // Solicitar permisos en Android 13+
          try {
            await androidPlugin.requestNotificationsPermission();
          } catch (e) {
            print('⚠️ Error pidiendo permisos (Android): $e');
          }
        }
      }

      _initialized = true;
      print('✅ Notificaciones locales inicializadas (Servicio Interno)');
    } catch (e) {
      print('❌ Error al inicializar notificaciones: $e');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Detalles de la notificación para Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'mexipartes_channel',
          'Notificaciones Generales',
          channelDescription: 'Canal principal',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final int id = DateTime.now().millisecondsSinceEpoch % 100000;

    try {
      // Llamada correcta a show usando argumentos nombrados
      await _notifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      print("❌ Error mostrando notificación: $e");
    }
  }

  // --- Helpers ---

  Future<void> notifyOrderConfirmed(String orderId, double total) async {
    await showNotification(
      title: '✅ Pedido Confirmado',
      body: 'Tu pedido por \$$total ha sido recibido.',
      payload: 'order_$orderId',
    );
  }

  Future<void> notifyItemAddedToCart(String productName) async {
    await showNotification(
      title: '🛒 Agregado al carrito',
      body: '$productName está en tu carrito.',
      payload: 'cart',
    );
  }

  Future<void> notifyLowStock(String productName, int stock) async {
    await showNotification(
      title: '⚠️ Stock Bajo',
      body: '$productName tiene solo $stock unidades.',
      payload: 'seller_dashboard',
    );
  }

  Future<void> notifyNewSale(String productName, double amount) async {
    await showNotification(
      title: '💰 Nueva Venta',
      body: 'Vendiste $productName por \$$amount.',
      payload: 'sales',
    );
  }
}
