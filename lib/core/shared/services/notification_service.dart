import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handler para notificações em background (deve ser top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background: sem acesso ao contexto de UI
  debugPrint('Notificação em background: ${message.notification?.title}');
}

class NotificationService {
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static final _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Solicitar permissão de notificação
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    // Configurar handler para mensagens em background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Configurar notificações locais
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Criar canal de notificação para Android
    await _createAndroidNotificationChannel();

    // Handler para mensagens em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handler para quando app é aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);
  }

  static Future<void> _createAndroidNotificationChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
          ),
        );
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Notificação em foreground: ${message.notification?.title}');

    // Mostrar notificação local quando app está em foreground
    await _showLocalNotification(
      title: message.notification?.title ?? 'Notificação',
      body: message.notification?.body ?? '',
      payload: message.data['conversationId'] ?? '',
    );
  }

  static Future<void> _handleNotificationOpenedApp(
      RemoteMessage message) async {
    debugPrint('Notificação aberta: ${message.notification?.title}');
    // Aqui seria implementada a navegação para o chat
    // context.go('/chat/${message.data['conversationId']}');
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificação tocada: ${response.payload}');
    // Aqui seria implementada a navegação para o chat
  }

  static Future<String?> getDeviceToken() async {
    return _firebaseMessaging.getToken();
  }
}
