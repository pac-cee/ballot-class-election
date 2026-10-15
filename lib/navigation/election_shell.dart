import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/election_ui.dart';
import '../features/candidates/candidates_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
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
    selectedIndex = widget.initialIndex.clamp(0, 4);
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void selectPage(int index) {
    if (selectedIndex == index) return;
    setState(() => selectedIndex = index);
    if (MediaQuery.disableAnimationsOf(context)) {
      pageController.jumpToPage(index);
    } else {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 960;
          final pages = [
            HomeScreen(
              controller: widget.controller,
              onOpenBallot: () => selectPage(1),
              onOpenCampaigns: () => selectPage(2),
              onOpenResults: () => selectPage(3),
            ),
            VoteScreen(
              controller: widget.controller,
              onOpenResults: () => selectPage(3),
            ),
            CandidatesScreen(controller: widget.controller),
            ResultsScreen(controller: widget.controller),
            ProfileScreen(controller: widget.controller),
          ];
          final pageView = PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: pages,
          );
          if (desktop) {
            return Scaffold(
              body: Row(
                children: [
                  Container(
                    width: 220,
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: BallotBrand(),
                        ),
                        const SizedBox(height: 28),
                        for (var i = 0; i < _destinations.length; i++)
                          _DesktopNavItem(
                            destination: _destinations[i],
                            selected: selectedIndex == i,
                            onTap: () => selectPage(i),
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.soft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.ink,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _initials,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.controller.currentUser?.name ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    Text(
                                      'Verified',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: pageView),
                ],
              ),
            );
          }
          return Scaffold(
            body: pageView,
            bottomNavigationBar: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: selectPage,
                destinations: [
                  for (final item in _destinations)
                    NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.label,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String get _initials => (widget.controller.currentUser?.name ?? 'Student')
      .split(' ')
      .take(2)
      .map((part) => part[0])
      .join();
}

class _NavDestination {
  const _NavDestination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _NavDestination('Home', Icons.home_outlined, Icons.home_rounded),
  _NavDestination(
    'Ballot',
    Icons.how_to_vote_outlined,
    Icons.how_to_vote_rounded,
  ),
  _NavDestination('Campaigns', Icons.campaign_outlined, Icons.campaign_rounded),
  _NavDestination('Results', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
  _NavDestination(
    'Profile',
    Icons.person_outline_rounded,
    Icons.person_rounded,
  ),
];

class _DesktopNavItem extends StatelessWidget {
  const _DesktopNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });
  final _NavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Material(
      color: selected ? AppColors.ink : Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 21,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(width: 11),
              Text(
                destination.label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: selected ? Colors.white : AppColors.ink),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
