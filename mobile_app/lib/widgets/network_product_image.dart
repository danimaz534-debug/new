import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkProductImage extends StatelessWidget {
  const NetworkProductImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? imageUrl;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final child = imageUrl == null || imageUrl!.isEmpty
        ? _fallback()
        : CachedNetworkImage(
            imageUrl: imageUrl!,
            height: height,
            fit: fit,
            placeholder: (context, _) => _fallback(),
            errorWidget: (context, _, __) => _fallback(),
          );

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: child,
    );
  }

  Widget _fallback() {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE2E8F0), Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.devices_rounded, size: 42, color: Color(0xFF64748B)),
      ),
    );
  }
}
