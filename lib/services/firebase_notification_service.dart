import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

// Función para manejar mensajes en segundo plano (debe ser top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Asegurarse de inicializar Firebase, aunque en versiones recientes a veces no es necesario
  // si ya se inicializó en main, pero en background isolate es mejor prevenir.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Si ya está inicializado puede lanzar error
  }
  print('🛑 Mensaje recibido en segundo plano: ${message.messageId}');
}

class FirebaseNotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _notificationService = NotificationService();

  // Argumento opcional usando corchetes []
  Future<void> initialize([String? userId]) async {
    // 1. Solicitar permisos (iOS y Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('🔒 Permisos de notificaciones: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Obtener Token FCM
      final fcmToken = await _firebaseMessaging.getToken();
      print('🔥 FCM Token: $fcmToken');

      if (userId != null && fcmToken != null) {
        try {
          // Guardar el token en la tabla 'profiles' (o 'usuarios' si esa usas para metadatos)
          // Asumimos que existe la columna 'fcm_token' en la tabla 'profiles'
          final supabase = Supabase.instance.client;
          await supabase.from('profiles').upsert({
            'id': userId,
            'fcm_token': fcmToken,
          });
          print('✅ Token FCM guardado en Supabase para usuario $userId');
        } catch (e) {
          print('⚠️ Error guardando Token FCM en Supabase: $e');
        }
      }

      // 3. Configurar listeners

      // Primer plano (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('🔔 Mensaje en primer plano: ${message.notification?.title}');

        // Mostrar notificación local
        if (message.notification != null) {
          _notificationService.showNotification(
            title: message.notification!.title ?? 'Sin título',
            body: message.notification!.body ?? '',
            payload:
                message.data['route'], // Ejemplo: usar 'route' para navegar
          );
        }
      });

      // Segundo plano (Background) se configura en main.dart o aquí como handler estático
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Al abrir la app desde notificación
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('👆 Notificación abierta (App minimizada): ${message.data}');
        // Aquí podrías implementar navegación
      });
    } else {
      print('❌ Permiso de notificaciones denegado');
    }
  }
}
