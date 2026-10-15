import 'package:flutter/material.dart';

import '../../models/candidate.dart';
import '../theme/app_theme.dart';

class BallotBrand extends StatelessWidget {
  const BallotBrand({super.key, this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : AppColors.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.how_to_vote_rounded,
            color: AppColors.ink,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'PIGA KURA',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class CandidateAvatar extends StatelessWidget {
  const CandidateAvatar({
    super.key,
    required this.candidate,
    this.size = 52,
    this.showVerified = false,
  });
  final Candidate candidate;
  final double size;
  final bool showVerified;

  @override
  Widget build(BuildContext context) {
    final color = Color(candidate.colorValue);
    final initials = candidate.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(size * .32),
              border: Border.all(color: color.withValues(alpha: .46)),
            ),
            child: Text(
              initials,
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: size * .31,
                letterSpacing: -.4,
              ),
            ),
          ),
          if (showVerified)
            Positioned(
              right: -3,
              bottom: -3,
              child: Container(
                width: size * .34,
                height: size * .34,
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: size * .22,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.dark = false,
    this.solid = false,
    this.icon,
  });
  final String label;
  final Color color;
  final bool dark;
  final bool solid;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: dark
          ? AppColors.ink
          : solid
          ? color
          : color.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: dark ? Colors.white : AppColors.ink),
          const SizedBox(width: 5),
        ],
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: dark ? Colors.white : AppColors.ink,
            letterSpacing: .8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class AppPagePadding extends StatelessWidget {
  const AppPagePadding({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 780),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        child: child,
      ),
    ),
  );
}
