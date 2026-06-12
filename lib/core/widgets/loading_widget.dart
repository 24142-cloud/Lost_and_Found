
import 'package:flutter/material.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _skeletonBox(height: 28, width: 140, radius: 8),
              const SizedBox(height: 8),
              _skeletonBox(height: 14, width: 220, radius: 6),
              const SizedBox(height: 24),
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                      child: _skeletonBox(height: 80, radius: 16),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              ...List.generate(4, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _skeletonBox(height: 110, radius: 16),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _skeletonBox({
    required double height,
    double? width,
    double radius = 8,
  }) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

