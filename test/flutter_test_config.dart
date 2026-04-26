import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

// Necessário para golden tests carregarem a fonte DM Sans corretamente.
// Esse arquivo é carregado automaticamente pelo runner de testes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Desabilitar download de fontes em testes
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
