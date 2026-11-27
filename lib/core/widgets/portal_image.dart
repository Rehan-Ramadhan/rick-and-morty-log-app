import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Network image with shimmer loading state and sci-fi fallback on invalid/failed URLs.
class PortalNetworkImage extends StatelessWidget {
  const PortalNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.width,
    this.height,
  });

  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    final hasValidUrl =
        trimmed.startsWith('http://') || trimmed.startsWith('https://');

    Widget content;
    if (!hasValidUrl) {
      content = _buildFallback();
    } else {
      content = CachedNetworkImage(
        imageUrl: trimmed,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.surface,
          highlightColor: AppColors.elevatedSurface,
          child: Container(
            width: width,
            height: height,
            color: AppColors.surface,
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }
    return content;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.elevatedSurface, AppColors.secondaryBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.radar_rounded,
              size: 32,
              color: AppColors.cyan.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 6),
            Text(
              'NO SIGNAL',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryText.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
