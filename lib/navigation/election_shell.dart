import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/candidates/candidates_screen.dart';
import '../features/results/results_screen.dart';
import '../features/vote/vote_screen.dart';
import '../state/election_controller.dart';

class ElectionShell extends StatefulWidget {
  const ElectionShell({
    super.key,
    required this.controller,
    this.initialIndex = 0,
  });

  final ElectionController controller;
  final int initialIndex;

  @override
  State<ElectionShell> createState() => _ElectionShellState();
}

class _ElectionShellState extends State<ElectionShell> {
  late final PageController pageController;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex.clamp(0, 2);
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void selectPage(int index) {
    setState(() => selectedIndex = index);
    if (MediaQuery.disableAnimationsOf(context)) {
      pageController.jumpToPage(index);
      return;
    }
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => Scaffold(
        body: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            VoteScreen(controller: widget.controller),
            ResultsScreen(controller: widget.controller),
            CandidatesScreen(controller: widget.controller),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: selectPage,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.how_to_vote_outlined),
                selectedIcon: Icon(Icons.how_to_vote_rounded),
                label: 'Vote',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart_rounded),
                label: 'Results',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups_rounded),
                label: 'Candidates',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
