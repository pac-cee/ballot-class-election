import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ElectionSkeleton extends StatefulWidget {
  const ElectionSkeleton({super.key});

  @override
  State<ElectionSkeleton> createState() => _ElectionSkeletonState();
}

class _ElectionSkeletonState extends State<ElectionSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> pulse;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    pulse = Tween<double>(
      begin: 0.48,
      end: 0.92,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.stop();
      controller.value = 0.75;
    } else if (!controller.isAnimating) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Semantics(
          label: 'Preparing ballot',
          liveRegion: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: AnimatedBuilder(
                  animation: pulse,
                  builder: (context, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bone(width: 210, height: 14, opacity: pulse.value),
                      const SizedBox(height: 18),
                      _Bone(width: 350, height: 34, opacity: pulse.value),
                      const SizedBox(height: 12),
                      _Bone(width: 290, height: 18, opacity: pulse.value),
                      const SizedBox(height: 30),
                      _Bone(
                        width: double.infinity,
                        height: 68,
                        radius: 18,
                        opacity: pulse.value,
                      ),
                      const SizedBox(height: 22),
                      _Bone(
                        width: double.infinity,
                        height: 58,
                        radius: 15,
                        opacity: pulse.value,
                      ),
                      const SizedBox(height: 30),
                      _Bone(width: 138, height: 22, opacity: pulse.value),
                      const SizedBox(height: 14),
                      for (var index = 0; index < 3; index++) ...[
                        _Bone(
                          width: double.infinity,
                          height: 78,
                          radius: 18,
                          opacity: pulse.value,
                        ),
                        if (index < 2) const SizedBox(height: 11),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 72 + MediaQuery.paddingOf(context).bottom,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    required this.opacity,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double opacity;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFDDE6F0),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
