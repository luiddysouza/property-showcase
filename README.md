# Property Showcase

App Flutter de portfólio — plataforma imobiliária que conecta proprietários a corretores.

> Construído para demonstrar domínio técnico em Flutter: Clean Architecture, Riverpod, GoRouter, FCM, unit tests e design system.

---

## Recursos

- **Listagem de Imóveis** — cards responsivos com preço e endereço
- **Galeria Interativa** — carrossel de fotos + player de vídeos integrado
- **Chat em Tempo Real** — streams mock simulando WebSocket
- **Push Notifications** — Firebase Cloud Messaging + notificações locais
- **Deep Links** — esquema `propshowcase://` para navegação profunda
- **Design System** — tokens de cor, tipografia e espaçamento

---

## Stack Técnico

| Camada | Tecnologia |
|---|---|
| State management | Riverpod 2.4.10 |
| Navegação | GoRouter 13.0.0 + deep links |
| Mídia | video_player + cached_network_image |
| Notificações | Firebase Cloud Messaging |
| Testes | Unit tests (mocktail) |
| Build | Flutter 3.27.0+ |

---

## Arquitetura

Clean Architecture — Feature-first:

```
features/
└── feature_name/
    ├── data/
    │   ├── datasources/    # Mock e API
    │   ├── models/         # Serialização JSON
    │   └── repositories/   # Implementação concreta
    ├── domain/
    │   ├── entities/       # Objetos puros
    │   ├── repositories/   # Contratos abstratos
    │   └── usecases/       # Lógica de negócio
    └── presentation/
        ├── providers/      # Riverpod DI
        ├── pages/          # Telas
        └── widgets/        # Componentes reutilizáveis
```

**Regras de camada:**
- `domain/` não importa nada de `data/` ou `presentation/`
- `presentation/` acessa `domain/` via providers Riverpod
- Sem chamadas diretas a repositório fora de providers

---

## Como Rodar

### Pré-requisitos
- Flutter 3.27.0+
- Dart 3.3.0+
- Git

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/property-showcase.git
cd property-showcase

# 2. Instale dependências
flutter pub get

# 3. Configure Firebase (opcional para push notifications)
# Consulte docs-app-portfolio-property-showcase.md para instruções detalhadas
# O app funciona sem Firebase — notificações estarão desabilitadas

# 4. Execute
flutter run

# 5. Testes
flutter test
```

### Configuração Firebase (Opcional)

Para ativar push notifications, execute:

```bash
flutterfire configure
```

Isso gerará `lib/firebase_options.dart` (gitignore). Consulte a documentação oficial do FlutterFire para configurar credenciais do Google.

---

## Estrutura do Projeto

```
lib/
├── core/
│   ├── design/           # Design tokens (cores, tipografia, espaçamento)
│   ├── routes/           # GoRouter config
│   └── shared/           # Serviços globais (notificações)
├── features/
│   ├── imoveis/          # Propriedades — listagem e detalhe
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── chat/             # Mensagens — comunicação em tempo real
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart             # Entry point

test/
├── features/
│   ├── imoveis/          # Testes da feature
│   └── chat/
├── flutter_test_config.dart  # Configuração do runner de testes
```

---

## Telas

### Home
Listagem de propriedades em cards responsivos:
- Imagem destacada com cache
- Endereço, preço e métricas (quartos, banheiros, área)
- Skeleton loading animado
- Navegação por swipe ou tap para detalhe

### Detalhe do Imóvel
Visualizador interativo:
- Carrossel full-screen de fotos (PageView)
- Player de vídeos com controle manual
- Informações completas (endereço, preço, descrição)
- Indicador de páginas
- Botão voltar com GoRouter

### Chat
Conversa em tempo real (mock):
- Lista de mensagens com auto-scroll
- Diferenciação visual (mensagens "minha" vs "do outro")
- Campo de entrada multilinhas
- Envio com validação simples
- Respostas automáticas do bot simulando conversa

---

## Decisões de Design

| Aspecto | Decisão | Razão |
|---|---|---|
| **State Management** | Riverpod | Moderno, menos boilerplate, tendência Flutter 2024+ |
| **Navegação** | GoRouter | Padrão Flutter team, deep links nativo |
| **Dados** | Mock local | Foco arquitetura, sem dependências externas |
| **Chat** | Streams Dart | Demonstra padrão WebSocket sem servidor |
| **Testes** | Unit tests | Cobertura de lógica crítica |
| **Notificações** | FCM | Requisito real de produção |
| **Cores** | Laranja (#F05A28) | Identidade mercado imobiliário |

---

## Conventions

### Nomenclatura

| Tipo | Padrão | Exemplo |
|---|---|---|
| Entidade | PascalCase | `Imovel`, `Message` |
| Model | `[Nome]Model` | `ImovelModel` |
| Repository (interface) | `[Nome]Repository` | `ImovelRepository` |
| Repository (impl) | `[Nome]RepositoryImpl` | `ImovelRepositoryImpl` |
| Datasource | `[Nome][Fonte]Datasource` | `ImovelMockDatasource` |
| Usecase | Verbo + Substantivo | `GetImoveis`, `SendMessage` |
| Provider | `[recurso]Provider` | `imoveisProvider`, `sendMessageProvider` |
| Arquivo | snake_case.dart | `imovel_card.dart`, `get_imoveis.dart` |

### Design System

Nunca use valores literais — sempre use tokens:

```dart
// ✅ Correto
color: AppColors.primary
style: AppTypography.heading1
padding: EdgeInsets.all(AppSpacing.md)

// ❌ Errado
color: Color(0xFFF05A28)
style: TextStyle(fontSize: 24)
padding: EdgeInsets.all(16)
```

---

## Contribuindo

1. Faça um fork
2. Crie uma branch (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'feat: Nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

---

## Próximos Passos

- [ ] Integração com API real de imóveis
- [ ] Autenticação com Firebase Auth
- [ ] Armazenamento persistente (Hive/Isar)
- [ ] Foto de perfil do usuário
- [ ] Busca e filtros avançados
- [ ] Favoritos e histórico
- [ ] Notificações em real-time com Websocket
- [ ] CI/CD com GitHub Actions
- [ ] Deployment no Play Store / App Store

---

## Licença

MIT © 2024

---

## Suporte

Para dúvidas ou sugestões, abra uma [issue](https://github.com/seu-usuario/property-showcase/issues).
