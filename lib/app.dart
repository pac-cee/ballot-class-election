import 'dart:async';

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/election_skeleton.dart';
import 'navigation/election_shell.dart';
import 'state/election_controller.dart';

class BallotApp extends StatefulWidget {
  const BallotApp({super.key, required this.controller});

  final ElectionController controller;

  @override
  State<BallotApp> createState() => _BallotAppState();
}

class _BallotAppState extends State<BallotApp> {
  Timer? readyTimer;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    readyTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => ready = true);
    });
  }

  @override
  void dispose() {
    readyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ballot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.015),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: ready
            ? ElectionShell(
                key: const ValueKey('election'),
                controller: widget.controller,
              )
            : const ElectionSkeleton(key: ValueKey('skeleton')),
      ),
    );
  }
}
