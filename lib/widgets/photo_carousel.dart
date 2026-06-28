import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shi_wu_ji/constants/app_colors.dart';

/// 多图轮播组件：左右切换按钮 + 指示器 + 手势滑动 + 点击大图预览 + 响应式。
class PhotoCarousel extends StatefulWidget {
  /// 照片本地路径列表
  final List<String> photos;

  /// 轮播高度（响应式：按屏幕宽度 3:4 适配，上限由此值约束）
  final double maxHeight;

  final BorderRadius borderRadius;

  const PhotoCarousel({
    super.key,
    required this.photos,
    this.maxHeight = 240,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.photos.length) return;
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _openFullScreen(int index) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (ctx, anim, sec) =>
            _FullScreenGallery(photos: widget.photos, initial: index),
        transitionsBuilder: (ctx, anim, sec, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    if (photos.isEmpty) {
      return _buildEmpty();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    // 响应式高度：屏幕宽度 × 3/4，但不超过 maxHeight
    final height = (screenWidth * 0.75).clamp(160.0, widget.maxHeight);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Stack(
              children: [
                // 主轮播
                PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  pageController: _controller,
                  itemCount: photos.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  builder: (ctx, i) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: FileImage(File(photos[i])),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      heroAttributes: PhotoViewHeroAttributes(tag: 'photo_$i'),
                      onTapUp: (_, __, ___) => _openFullScreen(i),
                    );
                  },
                  backgroundDecoration: const BoxDecoration(
                    color: AppColors.background,
                  ),
                  loadingBuilder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentGold,
                      strokeWidth: 2,
                    ),
                  ),
                ),

                // 左右切换按钮
                if (photos.length > 1) ...[
                  _NavButton(
                    alignment: Alignment.centerLeft,
                    icon: Icons.chevron_left,
                    visible: _current > 0,
                    onTap: () => _goTo(_current - 1),
                  ),
                  _NavButton(
                    alignment: Alignment.centerRight,
                    icon: Icons.chevron_right,
                    visible: _current < photos.length - 1,
                    onTap: () => _goTo(_current + 1),
                  ),

                  // 底部指示器 + 计数
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: _Indicator(count: photos.length, current: _current),
                  ),
                ],

                // 点击放大提示（单图也支持）
                if (photos.length == 1)
                  const Positioned(top: 8, right: 8, child: _ExpandHint()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final height = (screenWidth * 0.6).clamp(140.0, widget.maxHeight);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: AppColors.textHint,
            ),
            SizedBox(height: 8),
            Text(
              '暂无照片',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

/// 圆形半透明导航按钮
class _NavButton extends StatelessWidget {
  final Alignment alignment;
  final IconData icon;
  final bool visible;
  final VoidCallback onTap;

  const _NavButton({
    required this.alignment,
    required this.icon,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: !visible,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// 底部指示器 + 当前/总数
class _Indicator extends StatelessWidget {
  final int count;
  final int current;

  const _Indicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${current + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                ' / $count',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpandHint extends StatelessWidget {
  const _ExpandHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.zoom_out_map, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text('点击查看大图', style: TextStyle(fontSize: 10, color: Colors.white)),
        ],
      ),
    );
  }
}

/// 全屏大图预览
class _FullScreenGallery extends StatefulWidget {
  final List<String> photos;
  final int initial;

  const _FullScreenGallery({required this.photos, required this.initial});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
    _controller = PageController(initialPage: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _current = i),
            builder: (ctx, i) {
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(widget.photos[i])),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 4,
                heroAttributes: PhotoViewHeroAttributes(tag: 'photo_$i'),
              );
            },
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (_, __) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white70,
                strokeWidth: 2,
              ),
            ),
          ),
          // 顶部关闭 + 计数
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_current + 1} / ${widget.photos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
