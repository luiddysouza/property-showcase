# Documentação — Property Showcase

> Referência completa para desenvolvimento. Cobre regras de negócio, configuração Firebase, segurança, custos e guia de setup.

---

## 1. Visão Geral do Produto

### O que o app simula

O app é um portfólio técnico que simula uma plataforma imobiliária onde **proprietários de imóveis** disponibilizam material profissional (fotos e vídeos) para **corretores assinantes** trabalharem.

### Atores do sistema

| Ator | Papel no app |
|---|---|
| **Corretor** | Usuário principal — navega imóveis, acessa mídias, inicia chats |
| **Proprietário** | Dono do imóvel — responde no chat (simulado como bot neste app) |
| **Sistema** | Envia notificações push quando há nova mensagem |

---

## 2. Regras de Negócio

### 2.1 Imóveis

- Um imóvel tem: título, endereço, preço, área (m²), quartos, banheiros, descrição e lista de mídias
- Mídias são classificadas em `foto` ou `video`
- Um imóvel deve ter pelo menos 1 mídia do tipo foto
- A primeira foto da lista é sempre a capa (exibida no card da listagem)
- O imóvel não pode ser editado ou deletado neste app (apenas visualização)

### 2.2 Galeria de mídias

- Fotos são exibidas em carrossel com `PageView` + indicador de posição
- Vídeos são reproduzidos inline — não abrem player externo
- O player de vídeo começa pausado; o usuário inicia manualmente
- Ao sair da tela de detalhe, o vídeo deve ser pausado e disposed (evitar vazamento de recursos)

### 2.3 Chat

- Cada imóvel tem exatamente 1 conversa associada (identificada pelo `imovelId`)
- Mensagens têm: id, texto, senderId, timestamp, direção (enviada/recebida)
- O usuário atual é sempre `senderId: 'me'`
- A resposta automática (simulando o proprietário) é disparada após 1,5 segundos
- Mensagens são ordenadas por timestamp (ascendente) — mais antigas no topo
- A lista faz auto-scroll para a mensagem mais recente ao receber nova mensagem
- O botão de envio fica desabilitado quando o campo de texto está vazio ou só tem espaços

### 2.4 Notificações push

- Notificação é enviada quando o proprietário (bot) responde no chat
- O payload da notificação contém `conversationId` para navegação direta
- Em foreground: exibe banner local (não navega automaticamente)
- Em background/terminated: toque na notificação navega diretamente para o chat correto

---

## 3. Design System — Tokens

### Paleta de cores

Paleta definida para o projeto:

```dart
// lib/core/design/app_colors.dart
abstract class AppColors {
  // Primária
  static const Color primary        = Color(0xFFF05A28); // laranja primário
  static const Color primaryLight   = Color(0xFFFFF0EB); // laranja translúcido

  // Neutros
  static const Color background     = Color(0xFFFAF7F2); // off-white/creme
  static const Color surface        = Color(0xFFEEEBE6); // cards e superfícies
  static const Color divider        = Color(0xFFE0DDD8); // separadores

  // Texto
  static const Color textPrimary    = Color(0xFF1A1A1A); // preto
  static const Color textSecondary  = Color(0xFF888888); // cinza médio
  static const Color textOnPrimary  = Color(0xFFFFFFFF); // texto sobre laranja

  // Estados
  static const Color inactive       = Color(0xFFB0ADAB); // ícones inativos
  static const Color error          = Color(0xFFD32F2F); // erros
}
```

### Tipografia

```dart
// lib/core/design/app_typography.dart
// Fonte: DM Sans (Google Fonts)
abstract class AppTypography {
  static TextStyle heading1 = GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w700);
  static TextStyle heading2 = GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle body     = GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle bodyBold = GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle caption  = GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400);
  static TextStyle label    = GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500);
}
```

### Espaçamentos

```dart
// lib/core/design/app_spacing.dart
abstract class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 40.0;
  static const double xxl = 64.0;
}
```

---

## 4. Configuração Firebase — Passo a Passo

> Apenas o Firebase Messaging (FCM) é usado. Tudo dentro do plano **Spark (gratuito)**.

### 4.1 Pré-requisitos

- Conta Google (qualquer Gmail)
- Flutter SDK instalado
- Node.js instalado (para o Firebase CLI)

### 4.2 Criar o projeto no Firebase Console

1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. Clique em **"Adicionar projeto"**
3. Nome: `property-showcase` (ou qualquer nome)
4. Desative o Google Analytics (não é necessário)
5. Clique em **"Criar projeto"**

### 4.3 Instalar o Firebase CLI e FlutterFire CLI

```bash
# Firebase CLI
npm install -g firebase-tools

# Login no Firebase
firebase login

# FlutterFire CLI
dart pub global activate flutterfire_cli
```

### 4.4 Configurar o app Flutter com Firebase

Na raiz do projeto Flutter:

```bash
flutterfire configure
```

O comando vai perguntar:
- Qual projeto Firebase usar → selecione `property-showcase`
- Quais plataformas → selecione `android` e `ios`

Isso vai gerar automaticamente:
- `lib/firebase_options.dart` — **NÃO versionar** (ver seção de segurança)
- `android/app/google-services.json` — **NÃO versionar**
- `ios/Runner/GoogleService-Info.plist` — **NÃO versionar**

### 4.5 Configuração nativa Android

No arquivo `android/build.gradle` (nível projeto), verifique se tem:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

No arquivo `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 4.6 Configuração nativa iOS

No `ios/Runner/AppDelegate.swift`, confirme que está assim:
```swift
import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

No `ios/Runner/Info.plist`, adicione as permissões de notificação:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 4.7 Inicializar no `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}
```

### 4.8 Testar notificação push manualmente

1. Rode o app em um dispositivo físico ou emulador
2. Capture o token FCM no console (log no `main.dart`)
3. No Firebase Console → **Cloud Messaging** → **Enviar mensagem de teste**
4. Cole o token FCM do dispositivo
5. Envie — a notificação deve aparecer

---

## 5. Segurança — Regras Obrigatórias

### 5.1 O que NÃO pode ser versionado

| Arquivo | Motivo |
|---|---|
| `lib/firebase_options.dart` | Contém API keys do Firebase |
| `android/app/google-services.json` | Contém credenciais Android |
| `ios/Runner/GoogleService-Info.plist` | Contém credenciais iOS |
| `.env` (se criado) | Variáveis de ambiente locais |

### 5.2 `.gitignore` — entradas obrigatórias

Adicione ao `.gitignore` do projeto Flutter:

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

### 5.3 Arquivos de template para outros devs

Crie `android/app/google-services.template.json`:
```json
{
  "project_info": {
    "project_number": "SEU_PROJECT_NUMBER",
    "project_id": "SEU_PROJECT_ID"
  },
  "_comment": "Copie este arquivo para google-services.json e preencha com suas credenciais do Firebase Console"
}
```

### 5.4 GitHub Actions — injetando credenciais com segurança

No repositório GitHub: **Settings → Secrets and variables → Actions → New repository secret**

Crie os secrets:
- `GOOGLE_SERVICES_JSON` → conteúdo completo do `google-services.json` (em base64)
- `FIREBASE_OPTIONS_DART` → conteúdo do `firebase_options.dart` (em base64)

No workflow CI:
```yaml
- name: Decode Firebase config
  run: |
    echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 --decode > android/app/google-services.json
    echo "${{ secrets.FIREBASE_OPTIONS_DART }}" | base64 --decode > lib/firebase_options.dart
```

### 5.5 Por que as keys do Firebase não são "secretas" tecnicamente

As chaves no `google-services.json` identificam seu app no Firebase, mas **não dão acesso direto aos dados**. O controle de acesso real é feito pelas **Firebase Security Rules**. Ainda assim, não expor as chaves é boa prática para evitar:
- Abuso de cota (outros apps usarem seu projeto)
- Spam de notificações FCM no seu projeto

### 5.6 Firebase Security Rules

No Firebase Console → Firestore → Regras:

```javascript
// Regras para app de portfólio — sem auth real, mas fechado para o mundo
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Nenhuma leitura/escrita pública
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

> **Nota:** Como o app de portfólio não usa Firestore (usa chat mock local), essas regras são defensivas — garantem que mesmo se alguém descobrir as keys, não consegue ler nem escrever nada.

---

## 6. Análise de Custos

> Tudo a seguir usa o plano **Spark (gratuito)** do Firebase. Não é necessário cadastrar cartão de crédito para os limites descritos.

| Serviço | Plano usado | Limite gratuito | Uso esperado no portfólio |
|---|---|---|---|
| Firebase Messaging (FCM) | Spark | **Ilimitado** | < 100 mensagens |
| Firestore | Spark (não usado ativamente) | 50K leituras/dia, 20K escritas/dia | 0 (regras fechadas) |
| Google Fonts (DM Sans) | Gratuito | Ilimitado | Baixo |
| Imagens Unsplash | Gratuito | 50 req/hora (demo API) | Usar URLs fixas, sem API key |
| GitHub Actions | Gratuito (repo público) | 2.000 min/mês | ~5 min por push |
| **Total** | | | **R$ 0,00** |

> **Atenção com Unsplash:** Não use a API do Unsplash com chave. Use URLs diretas de imagens públicas no formato `https://images.unsplash.com/photo-[ID]?w=800` — isso não requer autenticação e não tem custo.

---

## 7. Golden Tests — Guia de Uso

### O que são

Golden tests capturam um "screenshot" de um widget em formato PNG e salvam como referência. A cada execução subsequente, comparam o novo render com a referência salva. Qualquer diferença visual quebra o teste.

### Onde ficam os arquivos golden

```
test/
└── goldens/
    ├── imovel_card_normal.png
    ├── imovel_card_loading.png
    ├── message_bubble_sent.png
    └── message_bubble_received.png
```

### Comandos essenciais

```bash
# Gerar os goldens pela primeira vez (ou após mudança intencional)
flutter test --update-goldens

# Rodar os testes normalmente (compara com referência)
flutter test

# Rodar apenas os golden tests
flutter test test/features/imoveis/widgets/imovel_card_golden_test.dart
```

### Exemplo de golden test

```dart
// test/features/imoveis/widgets/imovel_card_golden_test.dart
void main() {
  testGoldens('ImovelCard — estado normal', (tester) async {
    await tester.pumpWidgetBuilder(
      ImovelCard(imovel: imovelMock),
      surfaceSize: const Size(375, 200),
    );
    await screenMatchesGolden(tester, 'imovel_card_normal');
  });

  testGoldens('ImovelCard — estado loading', (tester) async {
    await tester.pumpWidgetBuilder(
      const ImovelCardSkeleton(),
      surfaceSize: const Size(375, 200),
    );
    await screenMatchesGolden(tester, 'imovel_card_loading');
  });
}
```

### Quando atualizar os goldens

- Sempre que uma mudança visual for **intencional** (novo espaçamento, cor ajustada, etc.)
- Nunca em CI — o CI só lê, nunca atualiza
- Commitar os arquivos `.png` gerados junto com o código

---

## 8. Deep Links — Configuração

### Esquema personalizado: `propshowcase://`

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="propshowcase" />
</intent-filter>
```

**iOS** — `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>propshowcase</string>
        </array>
    </dict>
</array>
```

### Rotas disponíveis via deep link

| Deep link | Destino |
|---|---|
| `propshowcase://imovel/abc123` | Detalhe do imóvel com id `abc123` |
| `propshowcase://chat/conv456` | Chat da conversa `conv456` |

### Testando deep links

```bash
# Android
adb shell am start -W -a android.intent.action.VIEW -d "propshowcase://imovel/1" com.luiddy.property_showcase

# iOS Simulator
xcrun simctl openurl booted "propshowcase://chat/1"
```

---

## 9. Estrutura de Arquivos de Teste

```
test/
├── flutter_test_config.dart        # carrega DM Sans para golden tests
├── core/
│   └── design/
│       └── app_colors_golden_test.dart
├── features/
│   ├── imoveis/
│   │   ├── domain/
│   │   │   ├── usecases/
│   │   │   │   ├── get_imoveis_test.dart
│   │   │   │   └── get_imovel_by_id_test.dart
│   │   └── widgets/
│   │       └── imovel_card_golden_test.dart
│   └── chat/
│       ├── domain/
│       │   └── usecases/
│       │       └── send_message_test.dart
│       └── widgets/
│           └── message_bubble_golden_test.dart
└── goldens/
    ├── imovel_card_normal.png
    ├── imovel_card_loading.png
    ├── message_bubble_sent.png
    └── message_bubble_received.png
```

---

## 10. Checklist antes de mostrar o projeto em entrevista

- [ ] App roda no simulador/emulador sem erros no console
- [ ] `flutter analyze` retorna 0 issues
- [ ] `flutter test` passa todos os testes (unit + golden)
- [ ] Golden PNGs estão commitados e atualizados
- [ ] README tem screenshots reais das 3 telas
- [ ] GitHub Actions está verde (badge no README)
- [ ] Link para o APK no README está funcionando
- [ ] Nenhuma key ou secret está exposto no repositório
- [ ] `git log --oneline` mostra commits limpos e descritivos
- [ ] Deep link `propshowcase://imovel/1` funciona no emulador Android
