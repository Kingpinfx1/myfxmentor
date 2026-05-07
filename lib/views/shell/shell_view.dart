import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../home/home_view.dart';
import '../journal/journal_view.dart';
import '../insights/insights_view.dart';
import '../profile/profile_view.dart';
import '../log_trade/log_trade_view.dart';

class ShellView extends StatefulWidget {
  const ShellView({super.key});

  @override
  State<ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<ShellView> {
  int _currentIndex = 0;

  final _pages = [
    const HomeView(),
    const JournalView(),
    const InsightsView(),
    const ProfileView(),
  ];

  void _onTap(int index) {
    if (index == 1) {
      // Log Trade — opens modal, does not switch tab
      HapticFeedback.mediumImpact();
      Get.to(
        () => const LogTradeView(),
        transition: Transition.downToUp,
        fullscreenDialog: true,
      );
      return;
    }
    HapticFeedback.selectionClick();
    final pageIndex = index > 1 ? index - 1 : index;
    setState(() => _currentIndex = pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex >= 1 ? _currentIndex + 1 : _currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline, size: 28),
            selectedIcon: Icon(Icons.add_circle, size: 28),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
