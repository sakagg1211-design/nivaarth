import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../advisor/advisor_chat_page.dart';
import '../dashboard/dashboard_page.dart';
import '../portfolio/portfolio_page.dart';
import '../search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  DateTime? _lastBackPressTime;

  late final List<Widget> pages = [
    DashboardPage(
      onOpenAdvisor: () => setState(() => currentIndex = 2),
    ),
    const PortfolioPage(),
    const AdvisorChatPage(),
    const SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If not on Dashboard tab, switch to Dashboard first
        if (currentIndex != 0) {
          setState(() => currentIndex = 0);
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit Nivaarth'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF16171B),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0D10),
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF111215),
          border: Border(
            top: BorderSide(color: Color(0xFF23252B), width: 1),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: const Color(0xFF1E2024),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Color(0xFFE5A93C),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                );
              }
              return const TextStyle(
                color: Color(0xFF757A85),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: Color(0xFFE5A93C),
                  size: 22,
                );
              }
              return const IconThemeData(
                color: Color(0xFF757A85),
                size: 22,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            height: 68,
            elevation: 0,
            backgroundColor: const Color(0xFF111215),
            surfaceTintColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Portfolio',
              ),
              NavigationDestination(
                icon: Icon(Icons.smart_toy_outlined),
                selectedIcon: Icon(Icons.smart_toy_rounded),
                label: 'NV Advisor',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

