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
    final imoveisAsync = ref.watch(imoveisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Property Showcase',
          style: AppTypography.heading2,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: imoveisAsync.when(
        data: (imoveis) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: imoveis.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ImovelCard(imovel: imoveis[index]),
              );
            },
          );
        },
        loading: () {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: ImovelCardSkeleton(),
              );
            },
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar imóveis',
                  style: AppTypography.bodyBold,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
