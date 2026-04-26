# Plano de Ação — Property Showcase

> Atualizado em 26/04/2026. Siga os passos na ordem. Cada commit deve compilar sem erros.

---

## Decisões tomadas

| Dimensão | Decisão | Justificativa |
|---|---|---|
| State management | **Riverpod** | Mais moderno, menos boilerplate, tendência atual |
| Navegação | **GoRouter** | Padrão Flutter team, suporta deep links nativamente |
| Dados — imóveis | **Mock local** | Foco na arquitetura, sem dependência externa |
| Dados — chat | **WebSocket mock (Dart streams)** | Demonstra o padrão sem precisar de servidor real |
| Push notifications | **Firebase FCM** | Requisito obrigatório da vaga |
| Design | **Inspirado no mercado imobiliário** | Laranja `#F05A28`, off-white `#FAF7F2`, cinza, preto |
| Testes | **Unit tests no domínio + Golden tests nos widgets** | Unit: lógica. Golden: fidelidade visual pixel-a-pixel |
| Estrutura | **Feature-first Clean Architecture** | Padrão atual Flutter, fácil de defender em entrevista |
| CI/CD | **GitHub Actions** | Roda testes + gera APK a cada push |

---

## Telas a construir

1. **Home** — listagem de imóveis com cards e fotos
2. **Detalhe do imóvel** — carrossel de fotos, player de vídeo, informações
3. **Chat** — conversa em tempo real via stream mock

---

## Estrutura de pastas final

```
lib/
├── core/
│   ├── design/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   └── app_theme.dart
│   ├── routes/
│   │   └── app_router.dart
│   └── shared/
│       └── widgets/
├── features/
│   ├── imoveis/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   └── chat/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── providers/
│           ├── pages/
│           └── widgets/
├── main.dart
└── firebase_options.dart   ← gerado na etapa do Firebase, NÃO versionar
```

---

## Pré-requisitos

Verifique antes de começar:

```bash
flutter --version        # precisa ser 3.19+ (canal stable)
dart --version
git --version
node --version           # necessário para Firebase CLI (commit 11)
```

Se o Flutter não estiver instalado: https://docs.flutter.dev/get-started/install

---

## Setup inicial — antes do primeiro commit

```bash
# 1. Criar o projeto
flutter create property_showcase --org com.luiddy --platforms android,ios
cd property_showcase

# 2. Inicializar git
git init

# 3. Criar repositório no GitHub e conectar (substitua SEU_USUARIO)
git remote add origin https://github.com/SEU_USUARIO/property-showcase.git
```

---

## Plano de commits

---

### Commit 1 — `chore: project setup`

#### 1.1 Substituir `pubspec.yaml` pelo conteúdo abaixo

```yaml
name: property_showcase
description: App de portfólio Flutter — mercado imobiliário.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.6.1

  # Navegação
  go_router: ^14.8.1

  # Mídia
  cached_network_image: ^3.4.1
  video_player: ^2.9.2
  photo_view: ^0.15.0

  # Skeleton loading
  shimmer: ^3.0.0

  # Firebase
  firebase_core: ^3.12.1
  firebase_messaging: ^15.2.5
  flutter_local_notifications: ^18.0.1

  # Design
  google_fonts: ^6.2.1

  # Utils
  equatable: ^2.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```

#### 1.2 Substituir `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_print
    - use_key_in_widget_constructors
    - prefer_single_quotes
```

#### 1.3 Adicionar ao `.gitignore`

Abra `.gitignore` e adicione no final:

```gitignore
# Firebase — nunca versionar
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# Variáveis de ambiente
.env
*.env.*
!.env.example
```

#### 1.4 Criar toda a estrutura de pastas

Execute na raiz do projeto (cria os diretórios e arquivos placeholder):

```bash
# Core
mkdir -p lib/core/design
mkdir -p lib/core/routes
mkdir -p lib/core/shared/widgets

# Feature imóveis
mkdir -p lib/features/imoveis/data/datasources
mkdir -p lib/features/imoveis/data/models
mkdir -p lib/features/imoveis/data/repositories
mkdir -p lib/features/imoveis/domain/entities
mkdir -p lib/features/imoveis/domain/repositories
mkdir -p lib/features/imoveis/domain/usecases
mkdir -p lib/features/imoveis/presentation/providers
mkdir -p lib/features/imoveis/presentation/pages
mkdir -p lib/features/imoveis/presentation/widgets

# Feature chat
mkdir -p lib/features/chat/data/datasources
mkdir -p lib/features/chat/data/models
mkdir -p lib/features/chat/data/repositories
mkdir -p lib/features/chat/domain/entities
mkdir -p lib/features/chat/domain/repositories
mkdir -p lib/features/chat/domain/usecases
mkdir -p lib/features/chat/presentation/providers
mkdir -p lib/features/chat/presentation/pages
mkdir -p lib/features/chat/presentation/widgets

# Testes
mkdir -p test/features/imoveis/domain/usecases
mkdir -p test/features/imoveis/presentation/widgets
mkdir -p test/features/chat/domain/usecases
mkdir -p test/features/chat/presentation/widgets
mkdir -p test/goldens
```

#### 1.5 Limpar `lib/main.dart`

Substitua o conteúdo gerado pelo Flutter por:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Property Showcase',
      home: Scaffold(body: Center(child: Text('Property Showcase'))),
    );
  }
}
```

#### 1.6 Deletar o arquivo de teste padrão

```bash
rm test/widget_test.dart
```

#### 1.7 Instalar as dependências

```bash
flutter pub get
```

#### 1.8 Verificar que compila

```bash
flutter analyze
```

#### 1.9 Commit

```bash
git add .
git commit -m "chore: project setup"
```

---

### Commit 2 — `feat: design system`

#### 2.1 Criar `lib/core/design/app_colors.dart`

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Primária
  static const Color primary = Color(0xFFF05A28);
  static const Color primaryLight = Color(0xFFFFF0EB);

  // Neutros
  static const Color background = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFEEEBE6);
  static const Color divider = Color(0xFFE0DDD8);

  // Texto
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Estados
  static const Color inactive = Color(0xFFB0ADAB);
  static const Color error = Color(0xFFD32F2F);
  static const Color selected = Color(0xFFF05A28);
}
```

#### 2.2 Criar `lib/core/design/app_spacing.dart`

```dart
abstract class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 40.0;
  static const double xxl = 64.0;
}
```

#### 2.3 Criar `lib/core/design/app_typography.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static TextStyle get heading1 => GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading2 => GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyBold => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get price => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
}
```

#### 2.4 Criar `lib/core/design/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}
```

#### 2.5 Atualizar `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Showcase',
      theme: AppTheme.light(),
      home: const Scaffold(
        body: Center(child: Text('Property Showcase')),
      ),
    );
  }
}
```

#### 2.6 Verificar e commitar

```bash
flutter analyze
git add .
git commit -m "feat: design system"
```

---

### Commit 3 — `feat: navigation`

#### 3.1 Criar páginas placeholder (necessárias para o router compilar)

**`lib/features/imoveis/presentation/pages/home_page.dart`**
```dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home')),
    );
  }
}
```

**`lib/features/imoveis/presentation/pages/imovel_detail_page.dart`**
```dart
import 'package:flutter/material.dart';

class ImovelDetailPage extends StatelessWidget {
  final String imovelId;

  const ImovelDetailPage({super.key, required this.imovelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Imóvel $imovelId')),
      body: const Center(child: Text('Detalhe')),
    );
  }
}
```

**`lib/features/chat/presentation/pages/chat_page.dart`**
```dart
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String conversationId;

  const ChatPage({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(child: Text('Chat')),
    );
  }
}
```

#### 3.2 Criar `lib/core/routes/app_router.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/imoveis/presentation/pages/home_page.dart';
import '../../features/imoveis/presentation/pages/imovel_detail_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/imovel/:id',
        builder: (context, state) => ImovelDetailPage(
          imovelId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) => ChatPage(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),
    ],
  );
});
```

#### 3.3 Atualizar `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design/app_theme.dart';
import 'core/routes/app_router.dart';

void main() {
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
```

#### 3.4 Configurar deep links no Android

Abra `android/app/src/main/AndroidManifest.xml`.

Dentro da tag `<activity>` que já existe, adicione o `<intent-filter>` de deep link:

```xml
<activity
    android:name=".MainActivity"
    ...>

    <!-- intent-filter que já existe (MAIN/LAUNCHER) -->
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>

    <!-- ADICIONAR: deep link propshowcase:// -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="propshowcase" />
    </intent-filter>

</activity>
```

#### 3.5 Configurar deep links no iOS

Abra `ios/Runner/Info.plist` e adicione antes do `</dict>` final:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>propshowcase</string>
        </array>
    </dict>
</array>
```

#### 3.6 Verificar e commitar

```bash
flutter analyze
git add .
git commit -m "feat: navigation"
```

---

### Commit 4 — `feat(imoveis): domain layer`

#### 4.1 Criar `lib/features/imoveis/domain/entities/midia.dart`

```dart
import 'package:equatable/equatable.dart';

enum MidiaTipo { foto, video }

class Midia extends Equatable {
  final String url;
  final MidiaTipo tipo;

  const Midia({required this.url, required this.tipo});

  @override
  List<Object?> get props => [url, tipo];
}
```

#### 4.2 Criar `lib/features/imoveis/domain/entities/imovel.dart`

```dart
import 'package:equatable/equatable.dart';
import 'midia.dart';

class Imovel extends Equatable {
  final String id;
  final String titulo;
  final String endereco;
  final double preco;
  final double areaM2;
  final int quartos;
  final int banheiros;
  final String descricao;
  final List<Midia> midias;

  const Imovel({
    required this.id,
    required this.titulo,
    required this.endereco,
    required this.preco,
    required this.areaM2,
    required this.quartos,
    required this.banheiros,
    required this.descricao,
    required this.midias,
  });

  /// Retorna a primeira foto da lista como capa do card.
  /// Regra de negócio: todo imóvel deve ter pelo menos 1 foto.
  Midia get capaMedia => midias.firstWhere(
        (m) => m.tipo == MidiaTipo.foto,
        orElse: () => midias.first,
      );

  @override
  List<Object?> get props => [id];
}
```

#### 4.3 Criar `lib/features/imoveis/domain/repositories/imovel_repository.dart`

```dart
import '../entities/imovel.dart';

abstract class ImovelRepository {
  Future<List<Imovel>> getImoveis();
  Future<Imovel> getImovelById(String id);
}
```

#### 4.4 Criar `lib/features/imoveis/domain/usecases/get_imoveis.dart`

```dart
import '../entities/imovel.dart';
import '../repositories/imovel_repository.dart';

class GetImoveis {
  final ImovelRepository _repository;

  const GetImoveis(this._repository);

  Future<List<Imovel>> call() => _repository.getImoveis();
}
```

#### 4.5 Criar `lib/features/imoveis/domain/usecases/get_imovel_by_id.dart`

```dart
import '../entities/imovel.dart';
import '../repositories/imovel_repository.dart';

class GetImovelById {
  final ImovelRepository _repository;

  const GetImovelById(this._repository);

  Future<Imovel> call(String id) => _repository.getImovelById(id);
}
```

#### 4.6 Verificar e commitar

```bash
flutter analyze
git add .
git commit -m "feat(imoveis): domain layer"
```

---

### Commit 5 — `feat(imoveis): data layer`

#### 5.1 Criar `lib/features/imoveis/data/models/imovel_model.dart`

```dart
import '../../domain/entities/imovel.dart';
import '../../domain/entities/midia.dart';

class MidiaModel extends Midia {
  const MidiaModel({required super.url, required super.tipo});

  factory MidiaModel.fromJson(Map<String, dynamic> json) {
    return MidiaModel(
      url: json['url'] as String,
      tipo: json['tipo'] == 'video' ? MidiaTipo.video : MidiaTipo.foto,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'tipo': tipo.name,
      };
}

class ImovelModel extends Imovel {
  const ImovelModel({
    required super.id,
    required super.titulo,
    required super.endereco,
    required super.preco,
    required super.areaM2,
    required super.quartos,
    required super.banheiros,
    required super.descricao,
    required super.midias,
  });

  factory ImovelModel.fromJson(Map<String, dynamic> json) {
    return ImovelModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      endereco: json['endereco'] as String,
      preco: (json['preco'] as num).toDouble(),
      areaM2: (json['areaM2'] as num).toDouble(),
      quartos: json['quartos'] as int,
      banheiros: json['banheiros'] as int,
      descricao: json['descricao'] as String,
      midias: (json['midias'] as List)
          .map((m) => MidiaModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
```

#### 5.2 Criar `lib/features/imoveis/data/datasources/imovel_mock_datasource.dart`

```dart
import '../models/imovel_model.dart';
import '../../domain/entities/midia.dart';

class ImovelMockDatasource {
  List<ImovelModel> getImoveis() {
    return [
      ImovelModel(
        id: '1',
        titulo: 'Casa em Condomínio Fechado',
        endereco: 'Alphaville, Barueri – SP',
        preco: 850000,
        areaM2: 180,
        quartos: 3,
        banheiros: 2,
        descricao: 'Casa em condomínio com segurança 24h, piscina e área de lazer completa. Acabamento de alto padrão com piso porcelanato e cozinha planejada.',
        midias: const [
          MidiaModel(url: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800', tipo: MidiaTipo.foto),
          MidiaModel(url: 'https://images.unsplash.com/photo-1576941089067-2de3c901e126?w=800', tipo: MidiaTipo.foto),
          MidiaModel(url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', tipo: MidiaTipo.video),
        ],
      ),
      ImovelModel(
        id: '2',
        titulo: 'Apartamento Moderno',
        endereco: 'Vila Olímpia, São Paulo – SP',
        preco: 620000,
        areaM2: 90,
        quartos: 2,
        banheiros: 2,
        descricao: 'Apartamento com varanda gourmet, vista panorâmica e vaga de garagem. Condomínio com academia e piscina.',
        midias: const [
          MidiaModel(url: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800', tipo: MidiaTipo.foto),
          MidiaModel(url: 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800', tipo: MidiaTipo.foto),
        ],
      ),
      ImovelModel(
        id: '3',
        titulo: 'Cobertura Duplex',
        endereco: 'Jardins, São Paulo – SP',
        preco: 1200000,
        areaM2: 250,
        quartos: 4,
        banheiros: 3,
        descricao: 'Cobertura duplex com terraço privativo, churrasqueira e jacuzzi. Vista 360° para a cidade.',
        midias: const [
          MidiaModel(url: 'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800', tipo: MidiaTipo.foto),
          MidiaModel(url: 'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=800', tipo: MidiaTipo.foto),
        ],
      ),
      ImovelModel(
        id: '4',
        titulo: 'Casa com Piscina',
        endereco: 'Tamboré, Santana de Parnaíba – SP',
        preco: 975000,
        areaM2: 220,
        quartos: 4,
        banheiros: 3,
        descricao: 'Casa espaçosa com piscina aquecida, jardim e espaço gourmet. Excelente localização próxima a escolas e shoppings.',
        midias: const [
          MidiaModel(url: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800', tipo: MidiaTipo.foto),
          MidiaModel(url: 'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=800', tipo: MidiaTipo.foto),
          MidiaModel(url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', tipo: MidiaTipo.video),
        ],
      ),
      ImovelModel(
        id: '5',
        titulo: 'Studio Compacto',
        endereco: 'Pinheiros, São Paulo – SP',
        preco: 320000,
        areaM2: 38,
        quartos: 1,
        banheiros: 1,
        descricao: 'Studio totalmente reformado com móveis planejados. Ideal para investimento ou moradia. Próximo ao metrô.',
        midias: const [
          MidiaModel(url: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800', tipo: MidiaTipo.foto),
        ],
      ),
      ImovelModel(
        id: '6',
        titulo: 'Sobrado 3 Dormitórios',
        endereco: 'Campinas – SP',
        preco: 480000,
        areaM2: 130,
        quartos: 3,
        banheiros: 2,
        descricao: 'Sobrado em rua tranquila, quintal amplo e garagem para 2 carros. Bairro nobre com boa infraestrutura.',
        midias: const [
          MidiaModel(url: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800', tipo: MidiaTipo.foto),
          MidiaModel(url: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800', tipo: MidiaTipo.foto),
        ],
      ),
    ];
  }

  ImovelModel getImovelById(String id) {
    final imovel = getImoveis().where((i) => i.id == id).firstOrNull;
    if (imovel == null) throw Exception('Imóvel não encontrado: $id');
    return imovel;
  }
}
```

#### 5.3 Criar `lib/features/imoveis/data/repositories/imovel_repository_impl.dart`

```dart
import '../../domain/entities/imovel.dart';
import '../../domain/repositories/imovel_repository.dart';
import '../datasources/imovel_mock_datasource.dart';

class ImovelRepositoryImpl implements ImovelRepository {
  final ImovelMockDatasource _datasource;

  const ImovelRepositoryImpl(this._datasource);

  @override
  Future<List<Imovel>> getImoveis() async {
    // Simula latência de rede
    await Future.delayed(const Duration(milliseconds: 600));
    return _datasource.getImoveis();
  }

  @override
  Future<Imovel> getImovelById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _datasource.getImovelById(id);
  }
}
```

#### 5.4 Criar `lib/features/imoveis/presentation/providers/imovel_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/imovel_mock_datasource.dart';
import '../../data/repositories/imovel_repository_impl.dart';
import '../../domain/entities/imovel.dart';
import '../../domain/repositories/imovel_repository.dart';
import '../../domain/usecases/get_imovel_by_id.dart';
import '../../domain/usecases/get_imoveis.dart';

// DI — repositório e usecases
final imovelRepositoryProvider = Provider<ImovelRepository>((ref) {
  return ImovelRepositoryImpl(ImovelMockDatasource());
});

final getImoveisProvider = Provider<GetImoveis>((ref) {
  return GetImoveis(ref.read(imovelRepositoryProvider));
});

final getImovelByIdProvider = Provider<GetImovelById>((ref) {
  return GetImovelById(ref.read(imovelRepositoryProvider));
});

// Estado da listagem
final imoveisNotifierProvider =
    AsyncNotifierProvider<ImoveisNotifier, List<Imovel>>(
  ImoveisNotifier.new,
);

class ImoveisNotifier extends AsyncNotifier<List<Imovel>> {
  @override
  Future<List<Imovel>> build() async {
    return ref.read(getImoveisProvider).call();
  }
}

// Estado do detalhe (carregado por ID)
final imovelDetalheProvider =
    FutureProvider.family<Imovel, String>((ref, id) async {
  return ref.read(getImovelByIdProvider).call(id);
});
```

#### 5.5 Verificar e commitar

```bash
flutter analyze
git add .
git commit -m "feat(imoveis): data layer"
```

---

### Commit 6 — `feat(imoveis): home screen`

#### 6.1 Criar `lib/features/imoveis/presentation/widgets/imovel_card_skeleton.dart`

```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/design/app_colors.dart';
import '../../../../../core/design/app_spacing.dart';

class ImovelCardSkeleton extends StatelessWidget {
  const ImovelCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.divider,
      child: Container(
        height: 260,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
```

#### 6.2 Criar `lib/features/imoveis/presentation/widgets/imovel_card.dart`

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/design/app_colors.dart';
import '../../../../../core/design/app_spacing.dart';
import '../../../../../core/design/app_typography.dart';
import '../../domain/entities/imovel.dart';
import 'imovel_card_skeleton.dart';

class ImovelCard extends StatelessWidget {
  final Imovel imovel;

  const ImovelCard({super.key, required this.imovel});

  String _formatPrice(double price) {
    final value = price / 1000;
    if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}M';
    }
    return 'R\$ ${value.toStringAsFixed(0)}K';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/imovel/${imovel.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem de capa com Hero
            Hero(
              tag: 'imovel_capa_${imovel.id}',
              child: CachedNetworkImage(
                imageUrl: imovel.capaMedia.url,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ImovelCardSkeleton(),
                errorWidget: (_, __, ___) => Container(
                  height: 180,
                  color: AppColors.divider,
                  child: const Icon(Icons.broken_image,
                      color: AppColors.inactive),
                ),
              ),
            ),
            // Informações
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(imovel.titulo, style: AppTypography.bodyBold),
                  const SizedBox(height: AppSpacing.xs),
                  Text(imovel.endereco, style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatPrice(imovel.preco),
                          style: AppTypography.price),
                      Row(
                        children: [
                          const Icon(Icons.bed_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: AppSpacing.xs),
                          Text('${imovel.quartos}',
                              style: AppTypography.caption),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.square_foot,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: AppSpacing.xs),
                          Text('${imovel.areaM2.toInt()}m²',
                              style: AppTypography.caption),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 6.3 Substituir `lib/features/imoveis/presentation/pages/home_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design/app_colors.dart';
import '../../../../../core/design/app_typography.dart';
import '../providers/imovel_providers.dart';
import '../widgets/imovel_card.dart';
import '../widgets/imovel_card_skeleton.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imoveisAsync = ref.watch(imoveisNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Imóveis', style: AppTypography.heading2),
        backgroundColor: AppColors.background,
      ),
      body: imoveisAsync.when(
        loading: () => ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => const ImovelCardSkeleton(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Erro ao carregar imóveis', style: AppTypography.body),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(imoveisNotifierProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (imoveis) => imoveis.isEmpty
            ? Center(
                child: Text('Nenhum imóvel disponível',
                    style: AppTypography.body),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: imoveis.length,
                itemBuilder: (_, index) =>
                    ImovelCard(imovel: imoveis[index]),
              ),
      ),
    );
  }
}
```

#### 6.4 Verificar e commitar

```bash
flutter analyze
git add .
git commit -m "feat(imoveis): home screen"
```

---

### Commit 7 — `feat(imoveis): detail screen`

#### 7.1 Criar `lib/features/imoveis/presentation/widgets/video_player_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/design/app_colors.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        height: 240,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        // Controles
        Container(
          color: Colors.black45,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
              Expanded(
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: AppColors.primaryLight,
                    backgroundColor: AppColors.inactive,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

#### 7.2 Substituir `lib/features/imoveis/presentation/pages/imovel_detail_page.dart`

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/design/app_colors.dart';
import '../../../../../core/design/app_spacing.dart';
import '../../../../../core/design/app_typography.dart';
import '../../domain/entities/imovel.dart';
import '../../domain/entities/midia.dart';
import '../providers/imovel_providers.dart';
import '../widgets/imovel_card_skeleton.dart';
import '../widgets/video_player_widget.dart';

class ImovelDetailPage extends ConsumerWidget {
  final String imovelId;

  const ImovelDetailPage({super.key, required this.imovelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imovelAsync = ref.watch(imovelDetalheProvider(imovelId));

    return imovelAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Imóvel não encontrado')),
      ),
      data: (imovel) => _ImovelDetailContent(imovel: imovel),
    );
  }
}

class _ImovelDetailContent extends StatefulWidget {
  final Imovel imovel;

  const _ImovelDetailContent({required this.imovel});

  @override
  State<_ImovelDetailContent> createState() => _ImovelDetailContentState();
}

class _ImovelDetailContentState extends State<_ImovelDetailContent> {
  int _currentPage = 0;

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'R\$ $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final imovel = widget.imovel;
    final fotos =
        imovel.midias.where((m) => m.tipo == MidiaTipo.foto).toList();
    final videos =
        imovel.midias.where((m) => m.tipo == MidiaTipo.video).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrossel de fotos com Hero
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: fotos.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => Hero(
                      tag: i == 0 ? 'imovel_capa_${imovel.id}' : 'foto_${imovel.id}_$i',
                      child: CachedNetworkImage(
                        imageUrl: fotos[i].url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => const ImovelCardSkeleton(),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.divider,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                  // Indicador de página
                  if (fotos.length > 1)
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          fotos.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentPage == i ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? AppColors.primary
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Informações
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(imovel.titulo, style: AppTypography.heading1),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(imovel.endereco, style: AppTypography.caption),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(_formatPrice(imovel.preco), style: AppTypography.price),
                  const SizedBox(height: AppSpacing.md),
                  // Métricas
                  Row(
                    children: [
                      _MetricItem(
                          icon: Icons.bed_outlined,
                          label: '${imovel.quartos} quartos'),
                      const SizedBox(width: AppSpacing.lg),
                      _MetricItem(
                          icon: Icons.bathtub_outlined,
                          label: '${imovel.banheiros} banheiros'),
                      const SizedBox(width: AppSpacing.lg),
                      _MetricItem(
                          icon: Icons.square_foot,
                          label: '${imovel.areaM2.toInt()}m²'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Text('Descrição', style: AppTypography.heading2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(imovel.descricao, style: AppTypography.body),
                ],
              ),
            ),
            // Vídeos (se houver)
            if (videos.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('Tour Virtual', style: AppTypography.heading2),
              ),
              const SizedBox(height: AppSpacing.sm),
              VideoPlayerWidget(url: videos.first.url),
              const SizedBox(height: AppSpacing.md),
            ],
            // Botão de contato
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/chat/${imovel.id}'),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Falar com o corretor'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.label),
      ],
    );
  }
}
```

#### 7.3 Verificar e commitar

```bash
flutter analyze
git add .
git commit -m "feat(imoveis): detail screen"
```

---

### Commit 8 — `feat(chat): domain layer`

#### 8.1 Criar `lib/features/chat/domain/entities/message.dart`

```dart
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final DateTime sentAt;

  const Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.sentAt,
  });

  bool get isFromMe => senderId == 'me';

  @override
  List<Object?> get props => [id];
}
```

#### 8.2 Criar `lib/features/chat/domain/repositories/chat_repository.dart`

```dart
import '../entities/message.dart';

abstract class ChatRepository {
  Stream<List<Message>> watchMessages(String conversationId);
  Future<void> sendMessage(String conversationId, String text);
  void dispose();
}
```

#### 8.3 Criar `lib/features/chat/domain/usecases/watch_messages.dart`

```dart
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class WatchMessages {
  final ChatRepository _repository;

  const WatchMessages(this._repository);

  Stream<List<Message>> call(String conversationId) =>
      _repository.watchMessages(conversationId);
}
```

#### 8.4 Criar `lib/features/chat/domain/usecases/send_message.dart`

```dart
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository _repository;

  const SendMessage(this._repository);

  Future<void> call(String conversationId, String text) =>
      _repository.sendMessage(conversationId, text);
}
```

#### 8.5 Verificar e commitar

```bash
flutter analyze
git add .
git commit -m "feat(chat): domain layer"
```

---

### Commit 9 — `feat(chat): stream mock datasource`

#### 9.1 Criar `lib/features/chat/data/models/message_model.dart`

```dart
import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.text,
    required super.senderId,
    required super.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      senderId: json['senderId'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'senderId': senderId,
        'sentAt': sentAt.toIso8601String(),
      };
}
```

#### 9.2 Criar `lib/features/chat/data/datasources/chat_mock_datasource.dart`

```dart
import 'dart:async';
import '../models/message_model.dart';

/// Mock que simula comunicação em tempo real via StreamController.
/// A arquitetura é idêntica ao que seria com WebSocket real —
/// só o datasource muda, nada acima precisa saber.
class ChatMockDatasource {
  final Map<String, List<MessageModel>> _mensagens = {};
  final Map<String, StreamController<List<MessageModel>>> _controllers = {};

  static const List<String> _respostasBot = [
    'Olá! Obrigado pelo contato. Posso ajudar com mais informações?',
    'Com certeza! O imóvel está disponível para visita.',
    'Qual seria a melhor data para você visitar?',
    'Posso te enviar mais fotos se desejar!',
    'O proprietário aceita negociação. Podemos conversar.',
  ];
  int _respostaIndex = 0;

  StreamController<List<MessageModel>> _getOrCreateController(
      String conversationId) {
    if (!_controllers.containsKey(conversationId)) {
      _controllers[conversationId] =
          StreamController<List<MessageModel>>.broadcast();
      _mensagens[conversationId] = [];
    }
    return _controllers[conversationId]!;
  }

  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _getOrCreateController(conversationId).stream;
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final controller = _getOrCreateController(conversationId);
    final messages = _mensagens[conversationId]!;

    // Adiciona mensagem do usuário
    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: 'me',
      sentAt: DateTime.now(),
    );
    messages.add(userMessage);
    controller.add(List.unmodifiable(messages));

    // Simula resposta do bot após 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!controller.isClosed) {
      final botMessage = MessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: _respostasBot[_respostaIndex % _respostasBot.length],
        senderId: 'corretor',
        sentAt: DateTime.now(),
      );
      _respostaIndex++;
      messages.add(botMessage);
      controller.add(List.unmodifiable(messages));
    }
  }

  void dispose(String conversationId) {
    _controllers[conversationId]?.close();
    _controllers.remove(conversationId);
    _mensagens.remove(conversationId);
  }
}
```

#### 9.3 Criar `lib/features/chat/data/repositories/chat_repository_impl.dart`

```dart
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_mock_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatMockDatasource _datasource;

  const ChatRepositoryImpl(this._datasource);

  @override
  Stream<List<Message>> watchMessages(String conversationId) =>
      _datasource.watchMessages(conversationId);

  @override
  Future<void> sendMessage(String conversationId, String text) =>
      _datasource.sendMessage(conversationId, text);

  @override
  void dispose() {}
}
```

#### 9.4 Criar `lib/features/chat/presentation/providers/chat_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/chat_mock_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/watch_messages.dart';

// Datasource como singleton para manter estado entre navegações
final chatDatasourceProvider = Provider<ChatMockDatasource>((ref) {
  final ds = ChatMockDatasource();
  ref.onDispose(ds.dispose);
  return ds;
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.read(chatDatasourceProvider));
});

final watchMessagesProvider = Provider<WatchMessages>((ref) {
  return WatchMessages(ref.read(chatRepositoryProvider));
});

final sendMessageProvider = Provider<SendMessage>((ref) {
  return SendMessage(ref.read(chatRepositoryProvider));
});

// Stream de mensagens por conversationId
final messagesStreamProvider =
    StreamProvider.family<List<Message>, String>((ref, conversationId) {
  return ref.read(watchMessagesProvider).call(conversationId);
});
```

#### 9.5 Verificar e commitar

```bash
flutter analyze
git add .
git commit -m "feat(chat): stream mock datasource"
```

---

### Commit 10 — `feat(chat): chat screen`

#### 10.1 Criar `lib/features/chat/presentation/widgets/message_bubble.dart`

```dart
import 'package:flutter/material.dart';
import '../../../../../core/design/app_colors.dart';
import '../../../../../core/design/app_spacing.dart';
import '../../../../../core/design/app_typography.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isFromMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : AppSpacing.md,
          right: isMe ? AppSpacing.md : 64,
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTypography.body.copyWith(
                color: isMe ? AppColors.textOnPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(message.sentAt),
              style: AppTypography.caption.copyWith(
                color: isMe
                    ? AppColors.textOnPrimary.withOpacity(0.7)
                    : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 10.2 Criar `lib/features/chat/presentation/widgets/chat_input.dart`

```dart
import 'package:flutter/material.dart';
import '../../../../../core/design/app_colors.dart';
import '../../../../../core/design/app_spacing.dart';

class ChatInput extends StatefulWidget {
  final void Function(String text) onSend;

  const ChatInput({super.key, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _hasText = v.trim().isNotEmpty),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Digite uma mensagem...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _hasText ? _send : null,
                icon: const Icon(Icons.send_rounded),
                color: _hasText ? AppColors.primary : AppColors.inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 10.3 Substituir `lib/features/chat/presentation/pages/chat_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design/app_colors.dart';
import '../../../../../core/design/app_typography.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatPage({super.key, required this.conversationId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(messagesStreamProvider(widget.conversationId));

    // Auto-scroll ao receber mensagens
    ref.listen(messagesStreamProvider(widget.conversationId), (_, next) {
      next.whenData((_) => _scrollToBottom());
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Corretor', style: AppTypography.bodyBold),
            Text('Imóvel #${widget.conversationId}',
                style: AppTypography.caption),
          ],
        ),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: Text('Iniciando conversa...'),
              ),
              error: (_, __) => const Center(
                child: Text('Erro ao carregar mensagens'),
              ),
              data: (messages) => messages.isEmpty
                  ? const Center(
                      child: Text('Envie uma mensagem para iniciar'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (_, i) =>
                          MessageBubble(message: messages[i]),
                    ),
            ),
          ),
          ChatInput(
            onSend: (text) {
              ref
                  .read(sendMessageProvider)
                  .call(widget.conversationId, text);
            },
          ),
        ],
      ),
    );
  }
}
```

#### 10.4 Verificar e commitar

```bash
flutter analyze
git add .
git commit -m "feat(chat): chat screen"
```

---

### Commit 11 — `feat: push notifications (FCM)`

> **Pré-requisito:** Ter uma conta Google. Firebase usa o plano Spark (gratuito) — não precisa de cartão.

#### 11.1 Instalar Firebase CLI e FlutterFire CLI

```bash
# Firebase CLI (requer Node.js)
npm install -g firebase-tools

# Login
firebase login

# FlutterFire CLI
dart pub global activate flutterfire_cli
```

#### 11.2 Criar projeto no Firebase Console

1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. **"Adicionar projeto"** → nome: `property-showcase`
3. Desative o Google Analytics → **"Criar projeto"**
4. Aguarde a criação

#### 11.3 Configurar o app com FlutterFire

Na raiz do projeto Flutter:

```bash
flutterfire configure
```

O comando pergunta:
- Qual projeto → selecione `property-showcase`
- Plataformas → marque `android` e `ios`

Isso gera automaticamente:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

**Esses três arquivos já estão no `.gitignore` — não os versione.**

#### 11.4 Configurar Android nativo

Em `android/build.gradle` (arquivo de nível raiz), verifique se `classpath` do Google Services existe:

```gradle
buildscript {
    dependencies {
        // já deve existir; adicione se não tiver:
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Em `android/app/build.gradle`, adicione no topo (após outros `apply plugin`):

```gradle
apply plugin: 'com.google.gms.google-services'
```

#### 11.5 Configurar iOS nativo

Em `ios/Runner/Info.plist`, adicione antes de `</dict>`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

#### 11.6 Criar `lib/core/shared/services/notification_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handler para notificações em background (deve ser top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background: sem acesso ao contexto de UI
}

class NotificationService {
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static const _channelId = 'property_chat_channel';
  static const _channelName = 'Mensagens Property Showcase';

  static Future<void> init() async {
    // Registra handler de background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Solicita permissão (necessário no iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configura canal Android
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Inicializa plugin local
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Foreground: mostra banner local
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });

    // Log do token (apenas para testes manuais)
    final token = await FirebaseMessaging.instance.getToken();
    // ignore: avoid_print
    debugPrint('[FCM Token] $token');
  }
}
```

#### 11.7 Atualizar `lib/main.dart` com Firebase

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/shared/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();

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
```

#### 11.8 Criar pasta de serviços

```bash
mkdir -p lib/core/shared/services
```

#### 11.9 Verificar e commitar

```bash
flutter analyze
git add .
git commit -m "feat: push notifications (FCM)"
```

---

### Commit 12 — `test: domain usecases`

#### 12.1 Criar `test/flutter_test_config.dart`

```dart
import 'dart:async';

// Necessário para golden tests carregarem a fonte DM Sans corretamente.
// Esse arquivo é carregado automaticamente pelo runner de testes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await testMain();
}
```

#### 12.2 Criar `test/features/imoveis/domain/usecases/get_imoveis_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_showcase/features/imoveis/domain/entities/imovel.dart';
import 'package:property_showcase/features/imoveis/domain/repositories/imovel_repository.dart';
import 'package:property_showcase/features/imoveis/domain/usecases/get_imoveis.dart';

class MockImovelRepository extends Mock implements ImovelRepository {}

void main() {
  late GetImoveis sut;
  late MockImovelRepository mockRepository;

  setUp(() {
    mockRepository = MockImovelRepository();
    sut = GetImoveis(mockRepository);
  });

  final imovelMock = const Imovel(
    id: '1',
    titulo: 'Casa Teste',
    endereco: 'Rua Teste, 1',
    preco: 500000,
    areaM2: 100,
    quartos: 3,
    banheiros: 2,
    descricao: 'Descrição',
    midias: [],
  );

  group('GetImoveis', () {
    test('deve retornar lista de imóveis quando repositório tem dados', () async {
      when(() => mockRepository.getImoveis())
          .thenAnswer((_) async => [imovelMock]);

      final result = await sut.call();

      expect(result, [imovelMock]);
      verify(() => mockRepository.getImoveis()).called(1);
    });

    test('deve lançar exceção quando repositório falha', () async {
      when(() => mockRepository.getImoveis())
          .thenThrow(Exception('Erro de rede'));

      expect(() => sut.call(), throwsException);
    });
  });
}
```

#### 12.3 Criar `test/features/imoveis/domain/usecases/get_imovel_by_id_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_showcase/features/imoveis/domain/entities/imovel.dart';
import 'package:property_showcase/features/imoveis/domain/repositories/imovel_repository.dart';
import 'package:property_showcase/features/imoveis/domain/usecases/get_imovel_by_id.dart';

class MockImovelRepository extends Mock implements ImovelRepository {}

void main() {
  late GetImovelById sut;
  late MockImovelRepository mockRepository;

  setUp(() {
    mockRepository = MockImovelRepository();
    sut = GetImovelById(mockRepository);
  });

  const imovelMock = Imovel(
    id: '1',
    titulo: 'Casa Teste',
    endereco: 'Rua Teste, 1',
    preco: 500000,
    areaM2: 100,
    quartos: 3,
    banheiros: 2,
    descricao: 'Descrição',
    midias: [],
  );

  group('GetImovelById', () {
    test('deve retornar imóvel correto quando id existe', () async {
      when(() => mockRepository.getImovelById('1'))
          .thenAnswer((_) async => imovelMock);

      final result = await sut.call('1');

      expect(result, imovelMock);
      expect(result.id, '1');
    });

    test('deve lançar exceção quando id não existe', () async {
      when(() => mockRepository.getImovelById('999'))
          .thenThrow(Exception('Imóvel não encontrado: 999'));

      expect(() => sut.call('999'), throwsException);
    });
  });
}
```

#### 12.4 Criar `test/features/chat/domain/usecases/send_message_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_showcase/features/chat/domain/repositories/chat_repository.dart';
import 'package:property_showcase/features/chat/domain/usecases/send_message.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late SendMessage sut;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    sut = SendMessage(mockRepository);
  });

  group('SendMessage', () {
    test('deve chamar repositório com os parâmetros corretos', () async {
      when(() => mockRepository.sendMessage(any(), any()))
          .thenAnswer((_) async {});

      await sut.call('conv1', 'Olá!');

      verify(() => mockRepository.sendMessage('conv1', 'Olá!')).called(1);
    });

    test('deve lançar exceção quando repositório falha', () async {
      when(() => mockRepository.sendMessage(any(), any()))
          .thenThrow(Exception('Falha no envio'));

      expect(() => sut.call('conv1', 'Olá!'), throwsException);
    });
  });
}
```

#### 12.5 Rodar os testes

```bash
flutter test
```

Todos devem passar (3 grupos, 6 testes).

#### 12.6 Commitar

```bash
git add .
git commit -m "test: domain usecases"
```

---

### Commit 12b — `test: golden tests`

> Golden tests capturam o pixel exato de um widget. Falham se cor, espaçamento ou fonte mudar sem intenção.

#### 12b.1 Criar `test/features/imoveis/presentation/widgets/imovel_card_golden_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_showcase/core/design/app_theme.dart';
import 'package:property_showcase/features/imoveis/domain/entities/imovel.dart';
import 'package:property_showcase/features/imoveis/domain/entities/midia.dart';
import 'package:property_showcase/features/imoveis/presentation/widgets/imovel_card.dart';
import 'package:property_showcase/features/imoveis/presentation/widgets/imovel_card_skeleton.dart';

const _imovelMock = Imovel(
  id: '1',
  titulo: 'Casa em Condomínio',
  endereco: 'Alphaville, SP',
  preco: 850000,
  areaM2: 180,
  quartos: 3,
  banheiros: 2,
  descricao: 'Descrição',
  midias: [
    Midia(
      url: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
      tipo: MidiaTipo.foto,
    ),
  ],
);

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('ImovelCard — skeleton golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 260));
    await tester.pumpWidget(_wrap(const ImovelCardSkeleton()));
    await expectLater(
      find.byType(ImovelCardSkeleton),
      matchesGoldenFile('goldens/imovel_card_skeleton.png'),
    );
  });

  testWidgets('ImovelCard — sem imagem (erro de rede) golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 260));
    // ImovelCard com URL inválida para forçar estado de erro
    const imovelSemFoto = Imovel(
      id: '2',
      titulo: 'Casa Teste',
      endereco: 'Rua Teste, 1',
      preco: 500000,
      areaM2: 100,
      quartos: 2,
      banheiros: 1,
      descricao: 'Desc',
      midias: [Midia(url: 'INVALID', tipo: MidiaTipo.foto)],
    );
    await tester.pumpWidget(_wrap(ImovelCard(imovel: imovelSemFoto)));
    await tester.pump(); // processa frame
    await expectLater(
      find.byType(ImovelCard),
      matchesGoldenFile('goldens/imovel_card_erro.png'),
    );
  });
}
```

#### 12b.2 Criar `test/features/chat/presentation/widgets/message_bubble_golden_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_showcase/core/design/app_theme.dart';
import 'package:property_showcase/features/chat/domain/entities/message.dart';
import 'package:property_showcase/features/chat/presentation/widgets/message_bubble.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(8), child: child)),
    );

void main() {
  final sentAt = DateTime(2026, 4, 26, 10, 30);

  testWidgets('MessageBubble — mensagem enviada golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 120));
    final message = Message(
      id: '1',
      text: 'Tenho interesse no imóvel!',
      senderId: 'me',
      sentAt: sentAt,
    );
    await tester.pumpWidget(_wrap(MessageBubble(message: message)));
    await expectLater(
      find.byType(MessageBubble),
      matchesGoldenFile('goldens/message_bubble_sent.png'),
    );
  });

  testWidgets('MessageBubble — mensagem recebida golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 120));
    final message = Message(
      id: '2',
      text: 'Olá! Posso ajudar com mais informações?',
      senderId: 'corretor',
      sentAt: sentAt,
    );
    await tester.pumpWidget(_wrap(MessageBubble(message: message)));
    await expectLater(
      find.byType(MessageBubble),
      matchesGoldenFile('goldens/message_bubble_received.png'),
    );
  });
}
```

#### 12b.3 Gerar os arquivos PNG de referência

```bash
# Gera os goldens pela primeira vez (ou após mudança intencional)
flutter test --update-goldens
```

Os arquivos PNG são salvos em `test/goldens/`. **Commite-os junto com o código.**

#### 12b.4 Verificar que os testes passam normalmente

```bash
flutter test
```

#### 12b.5 Commitar (incluindo os PNGs)

```bash
git add .
git commit -m "test: golden tests"
```

---

### Commit 13 — `ci: github actions workflow`

#### 13.1 Criar pasta e arquivo

```bash
mkdir -p .github/workflows
```

#### 13.2 Criar `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test-and-build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Inject Firebase config
        run: |
          echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 --decode > android/app/google-services.json
          echo "${{ secrets.FIREBASE_OPTIONS_DART }}" | base64 --decode > lib/firebase_options.dart

      - name: Run tests
        run: flutter test

      - name: Build APK
        run: flutter build apk --release --no-pub

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
          retention-days: 30
```

#### 13.3 Configurar GitHub Secrets

No repositório GitHub, vá em **Settings → Secrets and variables → Actions → New repository secret**.

Crie dois secrets:

**`GOOGLE_SERVICES_JSON`** — conteúdo do arquivo em base64:
```bash
# Rode no terminal para obter o valor
base64 -w 0 android/app/google-services.json
```
Cole o resultado como valor do secret.

**`FIREBASE_OPTIONS_DART`** — conteúdo do arquivo em base64:
```bash
base64 -w 0 lib/firebase_options.dart
```
Cole o resultado como valor do secret.

#### 13.4 Commitar

```bash
git add .
git commit -m "ci: github actions workflow"
git push origin main
```

Verifique em **Actions** no GitHub que o pipeline ficou verde.

---

### Commit 14 — `docs: readme`

#### 14.1 Criar `README.md` na raiz do projeto

```markdown
# Property Showcase

App Flutter de portfólio — plataforma imobiliária que conecta proprietários a corretores.

> Construído para demonstrar domínio técnico em Flutter: Clean Architecture, Riverpod, GoRouter, FCM, golden tests e CI/CD.

![CI](https://github.com/SEU_USUARIO/property-showcase/actions/workflows/ci.yml/badge.svg)

---

## Telas

| Home | Detalhe | Chat |
|------|---------|------|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

---

## Stack

| Camada | Tecnologia |
|---|---|
| State management | Riverpod |
| Navegação | GoRouter + deep links |
| Mídia | video_player + CachedNetworkImage |
| Push notifications | Firebase Cloud Messaging |
| Testes | Unit (mocktail) + Golden (matchesGoldenFile) |
| CI/CD | GitHub Actions |

## Arquitetura

```
Feature-first Clean Architecture
features/
└── feature_name/
    ├── data/        # datasources, models, repository impl
    ├── domain/      # entities, repository interface, usecases
    └── presentation # providers (Riverpod), pages, widgets
```

## Como rodar localmente

```bash
# Clone
git clone https://github.com/SEU_USUARIO/property-showcase.git
cd property-showcase

# Dependências
flutter pub get

# Configurar Firebase (requer conta Google)
# Siga o guia em docs-app-portfolio-property-showcase.md

# Rodar
flutter run

# Testes
flutter test

# Atualizar goldens
flutter test --update-goldens
```

## APK

Download disponível nos [artefatos do último build](https://github.com/SEU_USUARIO/property-showcase/actions).
```

> Antes de commitar, substitua `SEU_USUARIO` pelo seu usuário do GitHub e adicione screenshots reais das 3 telas.

#### 14.2 Commitar

```bash
git add .
git commit -m "docs: readme"
git push origin main
```

---

## Ordem de prioridade se o tempo apertar

1. Commits 1–3 (setup + design + navegação)
2. Commits 4–7 (imóveis completo — core do produto)
3. Commits 8–10 (chat — diferencial técnico)
4. Commit 14 (README — sempre antes de qualquer entrevista)
5. Commit 11 (FCM)
6. Commits 12–12b (testes)
7. Commit 13 (CI)

---

## O que dizer sobre esse projeto na entrevista

> "Criei um app de portfólio que replica o core do produto de vocês: listagem e galeria de mídia de imóveis, chat em tempo real com arquitetura pronta para trocar o mock por WebSocket real, push notifications com FCM, design system com DM Sans e a paleta laranja e off-white do app de vocês, Clean Architecture feature-first com Riverpod, golden tests que falham se 1px mudar, e pipeline de CI que roda testes e gera APK. Posso mostrar o repositório e o APK agora se quiser."
