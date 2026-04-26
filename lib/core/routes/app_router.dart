import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/imoveis/presentation/pages/home_page.dart';
import '../../features/imoveis/presentation/pages/imovel_detail_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Normaliza deep links com scheme propshowcase:// para paths internos
      final uri = state.uri;
      if (uri.scheme == 'propshowcase') {
        return '/${uri.host}${uri.path.isEmpty ? '' : uri.path}';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
        // Sub-rotas garantem que Home seja sempre o pai na pilha de navegação.
        // Assim, Back em Detail ou Chat volta para Home (inclusive via deep link).
        routes: [
          GoRoute(
            path: 'imovel/:id',
            name: 'imovel-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ImovelDetailPage(imovelId: id);
            },
          ),
          GoRoute(
            path: 'chat/:conversationId',
            name: 'chat',
            builder: (context, state) {
              final conversationId = state.pathParameters['conversationId']!;
              return ChatPage(conversationId: conversationId);
            },
          ),
        ],
      ),
    ],
  );
});
