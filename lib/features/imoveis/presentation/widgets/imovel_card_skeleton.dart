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
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 150,
                    color: AppColors.surface,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: 14,
                    width: 200,
                    color: AppColors.surface,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 14,
                    width: 100,
                    color: AppColors.surface,
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
