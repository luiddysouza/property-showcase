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

  const ImovelDetailPage({
    super.key,
    required this.imovelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imovelAsync = ref.watch(imovelDetalheProvider(imovelId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: imovelAsync.when(
        data: (imovel) => _ImovelDetailContent(imovel: imovel),
        loading: () => const Center(child: ImovelCardSkeleton()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text('Erro ao carregar imóvel', style: AppTypography.bodyBold),
            ],
          ),
        ),
      ),
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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar customizado
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  Text(
                    'Detalhes',
                    style: AppTypography.heading2,
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ),

          // Carrossel de mídias
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: widget.imovel.midias.length,
              itemBuilder: (context, index) {
                final midia = widget.imovel.midias[index];
                return midia.tipo == MidiaTipo.foto
                    ? _buildFotoPage(midia)
                    : _buildVideoPage(midia);
              },
            ),
          ),

          // Indicador de página
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: Text(
                '${_currentPage + 1} / ${widget.imovel.midias.length}',
                style: AppTypography.label,
              ),
            ),
          ),

          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              widget.imovel.titulo,
              style: AppTypography.heading1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Endereço
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              widget.imovel.endereco,
              style: AppTypography.caption,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Preço
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'R\$ ${(widget.imovel.preco / 1000000).toStringAsFixed(2)}M',
              style: AppTypography.heading2.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Métricas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricItem(
                  icon: Icons.king_bed,
                  label: '${widget.imovel.quartos} Quartos',
                ),
                _MetricItem(
                  icon: Icons.bathtub,
                  label: '${widget.imovel.banheiros} Banheiros',
                ),
                _MetricItem(
                  icon: Icons.square_foot,
                  label: '${widget.imovel.areaM2.toStringAsFixed(0)} m²',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Descrição
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descrição', style: AppTypography.heading2),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.imovel.descricao,
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildFotoPage(Midia midia) {
    return CachedNetworkImage(
      imageUrl: midia.url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: AppColors.surface,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surface,
        child: const Center(
          child: Icon(Icons.broken_image, color: AppColors.inactive, size: 48),
        ),
      ),
    );
  }

  Widget _buildVideoPage(Midia midia) {
    return VideoPlayerWidget(url: midia.url);
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 32),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: AppTypography.caption, textAlign: TextAlign.center),
      ],
    );
  }
}
