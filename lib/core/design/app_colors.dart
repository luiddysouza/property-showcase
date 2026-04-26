import 'package:flutter/material.dart';

abstract class AppColors {
  // Primária
  static const Color primary = Color(0xFFF05A28); // laranja primário
  static const Color primaryLight = Color(0xFFFFF0EB); // laranja translúcido

  // Neutros
  static const Color background = Color(0xFFFAF7F2); // off-white/creme
  static const Color surface = Color(0xFFEEEBE6); // cards e superfícies
  static const Color divider = Color(0xFFE0DDD8); // separadores

  // Texto
  static const Color textPrimary = Color(0xFF1A1A1A); // preto
  static const Color textSecondary = Color(0xFF888888); // cinza médio
  static const Color textOnPrimary = Color(0xFFFFFFFF); // texto sobre laranja

  // Estados
  static const Color inactive = Color(0xFFB0ADAB); // ícones inativos
  static const Color error = Color(0xFFD32F2F); // erros
  static const Color selected = Color(0xFFF05A28); // selecionado
}
