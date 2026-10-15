import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum NoticeTone { success, info, error }

OverlayEntry? _activeNotice;

void showNotice(
  BuildContext context, {
  required String message,
  NoticeTone tone = NoticeTone.success,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  _activeNotice?.remove();
  _activeNotice = null;
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;

  void dismiss() {
    if (entry.mounted) entry.remove();
    if (identical(_activeNotice, entry)) _activeNotice = null;
  }

  entry = OverlayEntry(
    builder: (context) => _NoticeOverlay(
      message: message,
      tone: tone,
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: dismiss,
    ),
  );
  _activeNotice = entry;
  overlay.insert(entry);
}

class _NoticeOverlay extends StatefulWidget {
  const _NoticeOverlay({
    required this.message,
    required this.tone,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final NoticeTone tone;
  final VoidCallback onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<_NoticeOverlay> createState() => _NoticeOverlayState();
}

class _NoticeOverlayState extends State<_NoticeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> fade;
  late final Animation<Offset> slide;
  Timer? timer;
  bool closing = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 150),
    );
    final curved = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    fade = curved;
    slide = Tween<Offset>(
      begin: const Offset(0, -0.16),
      end: Offset.zero,
    ).animate(curved);
    controller.forward();
    timer = Timer(
      widget.actionLabel == null
          ? const Duration(milliseconds: 2800)
          : const Duration(seconds: 5),
      close,
    );
  }

  Future<void> close() async {
    if (closing || !mounted) return;
    closing = true;
    timer?.cancel();
    if (!MediaQuery.disableAnimationsOf(context)) {
      await controller.reverse();
    }
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _NoticePalette.forTone(widget.tone);
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 16,
      right: 16,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SlideTransition(
            position: slide,
            child: FadeTransition(
              opacity: fade,
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Material(
                  color: palette.background,
                  elevation: 8,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.black.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: palette.border),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: palette.iconBackground,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              palette.icon,
                              size: 19,
                              color: palette.foreground,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          if (widget.actionLabel case final label?) ...[
                            const SizedBox(width: 6),
                            TextButton(
                              onPressed: () {
                                widget.onAction?.call();
                                close();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: palette.foreground,
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(label),
                            ),
                          ] else
                            IconButton(
                              onPressed: close,
                              tooltip: 'Dismiss message',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close, size: 19),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticePalette {
  const _NoticePalette({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color iconBackground;
  final Color foreground;
  final IconData icon;

  factory _NoticePalette.forTone(NoticeTone tone) {
    return switch (tone) {
      NoticeTone.success => const _NoticePalette(
        background: Color(0xFFF7FCF9),
        border: Color(0xFFCDE8D8),
        iconBackground: Color(0xFFDDF4E7),
        foreground: Color(0xFF087443),
        icon: Icons.check_rounded,
      ),
      NoticeTone.info => const _NoticePalette(
        background: Color(0xFFF6F9FF),
        border: Color(0xFFD3E2FF),
        iconBackground: Color(0xFFDEEAFF),
        foreground: AppColors.primary,
        icon: Icons.info_outline_rounded,
      ),
      NoticeTone.error => const _NoticePalette(
        background: Color(0xFFFFF8F7),
        border: Color(0xFFF2C8C3),
        iconBackground: Color(0xFFFBE1DE),
        foreground: AppColors.danger,
        icon: Icons.error_outline_rounded,
      ),
    };
  }
}
