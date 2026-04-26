import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (opcional)
  try {
    await Firebase.initializeApp();
    // Inicializar serviço de notificações apenas se Firebase foi configurado
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('⚠️ Firebase não configurado: $e');
    debugPrint('Execute: flutterfire configure');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Property Showcase',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
