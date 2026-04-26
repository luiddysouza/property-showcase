---
applyTo: "**"
---

# Instruções — Property Showcase

> Copie este arquivo para `.github/copilot-instructions.md` na raiz do projeto Flutter.
> Ele será lido automaticamente pelo GitHub Copilot em todo o workspace.

---

## Contexto do projeto

App Flutter de portfólio (Property Showcase): listagem de imóveis com galeria de mídia e chat em tempo real.

---

## Arquitetura

**Clean Architecture feature-first.** Cada feature tem suas próprias camadas internas:

```
features/
└── nome_da_feature/
    ├── data/
    │   ├── datasources/    # fontes externas (mock, API, Firebase)
    │   ├── models/         # serialização (extends/implements entity)
    │   └── repositories/   # implementação concreta do contrato
    ├── domain/
    │   ├── entities/       # objetos de negócio puros (sem framework)
    │   ├── repositories/   # contratos abstratos (interfaces)
    │   └── usecases/       # uma ação por arquivo, uma responsabilidade
    └── presentation/
        ├── providers/      # Riverpod providers e notifiers
        ├── pages/          # telas completas (route targets)
        └── widgets/        # widgets reutilizáveis da feature
```

**Regras de camada que não podem ser violadas:**
- `domain/` não importa nada de `data/` nem de `presentation/`
- `domain/` não importa pacotes externos (exceto `equatable`)
- `presentation/` só acessa `domain/` via providers — nunca chama repositório diretamente
- `data/` só depende de `domain/` (para implementar contratos)

---

## State Management

**Riverpod** com `AsyncNotifier` para estado assíncrono e `StreamProvider` para streams.

```dart
// Provider de lista — padrão correto
@riverpod
class ImoveisNotifier extends _$ImoveisNotifier {
  @override
  Future<List<Imovel>> build() async {
    return ref.read(getImoveisProvider).call();
  }
}

// NÃO usar: setState, ChangeNotifier, ou acessar repositório direto na página
```

---

## Design System — regras de uso

**Nunca use valores literais de cor, fonte ou espaçamento.** Sempre use os tokens:

```dart
// CERTO
color: AppColors.primary
style: AppTypography.body
padding: EdgeInsets.all(AppSpacing.md)

// ERRADO
color: Color(0xFFF05A28)
style: TextStyle(fontSize: 16)
padding: EdgeInsets.all(16)
```

**Paleta de cores (não inventar cores novas sem adicionar ao AppColors):**
- `primary` = `#F05A28` — laranja primário
- `background` = `#FAF7F2` — off-white
- `surface` = `#EEEBE6` — cards
- `textPrimary` = `#1A1A1A`
- `textSecondary` = `#888888`

**Fonte:** DM Sans via `google_fonts` — importada através de `AppTypography`, nunca `GoogleFonts.dmSans()` inline.

---

## Navegação

**GoRouter.** Todas as rotas estão em `lib/core/routes/app_router.dart`.

```dart
// Navegar — SEMPRE via GoRouter, nunca Navigator.push diretamente
context.go('/imovel/$id');
context.push('/chat/$conversationId');

// Definir nova rota — adicionar em app_router.dart
GoRoute(
  path: '/nova-rota',
  builder: (context, state) => const NovaTela(),
),
```

Deep links configurados com esquema `propshowcase://`. Qualquer nova rota deve ser testável via `propshowcase://caminho`.

---

## Entidades do domínio

```dart
// Imovel
class Imovel extends Equatable {
  final String id;
  final String titulo;
  final String endereco;
  final double preco;
  final List<Midia> midias;
  final int quartos;
  final int banheiros;
  final double areaM2;
  final String descricao;
}

// Midia
class Midia extends Equatable {
  final String url;
  final MidiaTipo tipo; // MidiaTipo.foto | MidiaTipo.video
}

// Message
class Message extends Equatable {
  final String id;
  final String text;
  final String senderId; // 'me' = usuário atual
  final DateTime sentAt;
  bool get isFromMe => senderId == 'me';
}
```

---

## Padrões de widget

### Loading state
Use skeleton (container animado com cor `AppColors.surface`) — **nunca `CircularProgressIndicator` em tela cheia**.

```dart
// Padrão de skeleton
AnimatedContainer(
  duration: const Duration(milliseconds: 800),
  color: AppColors.surface,
  // ...
)
```

### Tratamento de erro
Mostrar mensagem amigável + botão de retry — nunca expor stack trace para o usuário.

### Imagens remotas
Sempre com `CachedNetworkImage` — nunca `Image.network` diretamente.

```dart
CachedNetworkImage(
  imageUrl: midia.url,
  fit: BoxFit.cover,
  placeholder: (_, __) => const ImovelCardSkeleton(),
  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
)
```

---

## Testes

### Unit tests (domínio)
- Localização: `test/features/[feature]/domain/usecases/`
- Mocks: usar `mocktail` — nunca `mockito`
- Cada usecase tem seu próprio arquivo de teste
- Testar: caminho feliz, falha do repositório, edge cases de negócio

### Golden tests (widgets)
- Localização: `test/features/[feature]/widgets/`
- Tamanho padrão de tela: `Size(375, 812)` para tela cheia, `Size(375, altura)` para componentes
- Sempre chamar `await loadAppFonts()` via `flutter_test_config.dart`
- Commitar os PNGs gerados junto com o código
- **Atualizar goldens somente quando a mudança visual for intencional:**
  ```bash
  flutter test --update-goldens
  ```

---

## Segurança — regras absolutas

1. **Nunca commitar** `firebase_options.dart`, `google-services.json` ou `GoogleService-Info.plist`
2. **Nunca colocar** API key, token, secret ou senha em código Dart
3. Qualquer valor sensível vai em variável de ambiente via `flutter_dotenv` ou GitHub Secrets
4. Se o Copilot sugerir hardcode de key, rejeitar e usar a abstração correta

---

## Como implementar uma nova feature

Siga esta ordem — não pule etapas:

1. **Domain first**: criar entidade + contrato do repositório + usecases
2. **Data**: criar modelo (serialização) + datasource + implementação do repositório
3. **Registration**: registrar no sistema de DI (Riverpod provider ou GetIt)
4. **Presentation**: criar provider → page → widgets
5. **Tests**: unit test dos usecases → golden test dos widgets principais
6. **Route**: adicionar rota no `app_router.dart` se for uma nova tela

---

## Convenções de nomenclatura

| Tipo | Convenção | Exemplo |
|---|---|---|
| Entidade | `PascalCase` | `Imovel`, `Message` |
| Model | `[Entidade]Model` | `ImovelModel`, `MessageModel` |
| Repository (interface) | `[Feature]Repository` | `ImovelRepository` |
| Repository (impl) | `[Feature]RepositoryImpl` | `ImovelRepositoryImpl` |
| Datasource | `[Feature][Fonte]Datasource` | `ImovelMockDatasource` |
| Usecase | verbo + substantivo | `GetImoveis`, `SendMessage` |
| Provider | `[entidade/acao]Provider` | `imoveisProvider`, `sendMessageProvider` |
| Page | `[Nome]Page` | `HomePage`, `ChatPage` |
| Widget | `[Nome]` descritivo | `ImovelCard`, `MessageBubble` |
| Arquivo | `snake_case.dart` | `imovel_card.dart`, `get_imoveis.dart` |

---

## O que NÃO fazer (anti-patterns)

- `BuildContext` em classes fora de `presentation/`
- Lógica de negócio em widgets ou providers (pertence aos usecases)
- `setState` fora de `StatefulWidget` de UI pura (ex: animações simples)
- Importar `dart:io` ou pacotes de plataforma em `domain/`
- Magic numbers sem constante nomeada
- Cores, fontes ou espaçamentos literais fora do design system
- `print()` em produção — usar `debugPrint()` apenas
