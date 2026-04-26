import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/imoveis/presentation/pages/home_page.dart';
import '../../features/imoveis/presentation/pages/imovel_detail_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/imovel/:id',
        name: 'imovel-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ImovelDetailPage(imovelId: id);
        },
      ),
      GoRoute(
        path: '/chat/:conversationId',
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return ChatPage(conversationId: conversationId);
        },
      ),
    ],
  );
});
