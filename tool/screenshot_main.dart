import 'package:class_election/core/theme/app_theme.dart';
import 'package:class_election/core/widgets/app_notice.dart';
import 'package:class_election/models/candidate.dart';
import 'package:class_election/navigation/election_shell.dart';
import 'package:class_election/state/election_controller.dart';
import 'package:flutter/material.dart';

const screen = String.fromEnvironment('SCREEN', defaultValue: 'vote');

void main() {
  final controller = screen == 'vote' || screen == 'notice'
      ? ElectionController.demo()
      : ElectionController(
          candidates: [
            Candidate(id: 1, name: 'Keza Uwase', votes: 4),
            Candidate(id: 2, name: 'Mutoni Alice', votes: 4),
            Candidate(id: 3, name: 'Eric Mugisha', votes: 1),
          ],
        );
  controller.continueDemo();
  runApp(_ScreenshotApp(controller: controller));
}

class _ScreenshotApp extends StatelessWidget {
  const _ScreenshotApp({required this.controller});

  final ElectionController controller;

  @override
  Widget build(BuildContext context) {
    final index = switch (screen) {
      'results' => 3,
      'candidates' => 2,
      'vote' || 'notice' => 1,
      _ => 0,
    };
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _ScreenshotHome(controller: controller, initialIndex: index),
    );
  }
}

class _ScreenshotHome extends StatefulWidget {
  const _ScreenshotHome({required this.controller, required this.initialIndex});

  final ElectionController controller;
  final int initialIndex;

  @override
  State<_ScreenshotHome> createState() => _ScreenshotHomeState();
}

class _ScreenshotHomeState extends State<_ScreenshotHome> {
  @override
  void initState() {
    super.initState();
    if (screen == 'notice') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showNotice(
          context,
          message: 'Aline Uwase voted for Keza Uwase.',
          actionLabel: 'Undo',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElectionShell(
      controller: widget.controller,
      initialIndex: widget.initialIndex,
    );
  }
}
