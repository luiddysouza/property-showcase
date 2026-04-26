import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/design/app_colors.dart';

class ImovelCardSkeleton extends StatelessWidget {
  const ImovelCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.divider,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
      ),
    );
  }
}
