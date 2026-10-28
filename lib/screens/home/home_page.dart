import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/layout/breakpoints.dart';
import '../advisor/advisor_chat_page.dart';
import '../dashboard/dashboard_page.dart';
import '../portfolio/portfolio_page.dart';
import '../search/search_page.dart';

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}

const _navItems = [
  _NavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
  _NavItem(Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet_rounded, 'Portfolio'),
  _NavItem(Icons.smart_toy_outlined, Icons.smart_toy_rounded, 'NV Advisor'),
  _NavItem(Icons.search_rounded, Icons.search_rounded, 'Search'),
];

const _gold = Color(0xFFE5A93C);
const _muted = Color(0xFF757A85);
const _panel = Color(0xFF111215);
const _border = Color(0xFF23252B);

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

  void _select(int index) => setState(() => currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);
    final stack = IndexedStack(index: currentIndex, children: pages);

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
        // Wide screens: sidebar + one centered content column for every tab.
        body: isDesktop
            ? Row(
                children: [
                  _Sidebar(currentIndex: currentIndex, onSelect: _select),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: Breakpoints.contentMaxWidth),
                        child: SizedBox.expand(child: stack),
                      ),
                    ),
                  ),
                ],
              )
            : stack,
        bottomNavigationBar: isDesktop ? null : _bottomBar(),
      ),
    );
  }

  Widget _bottomBar() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(
          top: BorderSide(color: _border, width: 1),
        ),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFF1E2024),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: _gold,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              );
            }
            return const TextStyle(
              color: _muted,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: _gold,
                size: 22,
              );
            }
            return const IconThemeData(
              color: _muted,
              size: 22,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          height: 68,
          elevation: 0,
          backgroundColor: _panel,
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: _select,
          destinations: [
            for (final item in _navItems)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _Sidebar({required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(right: BorderSide(color: _border, width: 1)),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 22, 14, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset('assets/images/logo.jpg',
                          width: 36, height: 36, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'NIVAARTH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              for (var i = 0; i < _navItems.length; i++)
                _SidebarTile(
                  item: _navItems[i],
                  selected: i == currentIndex,
                  onTap: () => onSelect(i),
                ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Private Beta',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? _gold : const Color(0xFFB4B8C2);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? const Color(0xFF1E2024) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          hoverColor: const Color(0xFF191B1F),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(selected ? item.selectedIcon : item.icon,
                    color: color, size: 21),
                const SizedBox(width: 14),
                Text(
                  item.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
