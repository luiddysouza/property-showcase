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

  const ImovelCard({
    super.key,
    required this.imovel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/imovel/${imovel.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: imovel.midias.isNotEmpty
                    ? imovel.midias.first.url
                    : 'https://via.placeholder.com/300x200',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ImovelCardSkeleton(),
                errorWidget: (_, __, ___) => Container(
                  height: 160,
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: AppColors.inactive),
                  ),
                ),
              ),
            ),
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    imovel.titulo,
                    style: AppTypography.bodyBold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Endereço
                  Text(
                    imovel.endereco,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Preço
                  Text(
                    'R\$ ${(imovel.preco / 1000000).toStringAsFixed(2)}M',
                    style: AppTypography.heading2.copyWith(
                      color: AppColors.primary,
                    ),
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
