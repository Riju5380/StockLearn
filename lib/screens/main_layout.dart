import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'stocks/stocks_tab_layout.dart';
import 'classes/classes_screen.dart';
import 'news/news_screen.dart';
import 'profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late PageController _pageController;
  AppStateProvider? _appStateProvider;

  static const List<Widget> _screens = [
    StocksTabLayout(),
    ClassesScreen(),
    NewsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = Provider.of<AppStateProvider>(context, listen: false).navigationIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppStateProvider>(context);
    if (_appStateProvider != appState) {
      _appStateProvider?.removeListener(_onStateChanged);
      _appStateProvider = appState;
      _appStateProvider?.addListener(_onStateChanged);
    }
  }

  void _onStateChanged() {
    final targetIndex = _appStateProvider?.navigationIndex ?? 0;
    if (_pageController.hasClients && _pageController.page?.round() != targetIndex) {
      final currentIndex = _pageController.page?.round() ?? 0;
      if ((targetIndex - currentIndex).abs() > 1) {
        _pageController.jumpToPage(targetIndex);
      } else {
        _pageController.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _appStateProvider?.removeListener(_onStateChanged);
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF151D30) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit App', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to exit StockLearn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final selectedIndex = appState.navigationIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        
        if (selectedIndex != 0) {
          // Redirect to Stocks tab (index 0) first
          appState.setNavigationIndex(0);
        } else {
          // If already on Stocks tab, show exit confirmation dialog
          final shouldExit = await _showExitConfirmationDialog(context);
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // tab changes are animated
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            appState.setNavigationIndex(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: FaIcon(FontAwesomeIcons.chartLine, size: 18),
              ),
              label: 'Stocks',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: FaIcon(FontAwesomeIcons.graduationCap, size: 18),
              ),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: FaIcon(FontAwesomeIcons.newspaper, size: 18),
              ),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: FaIcon(FontAwesomeIcons.user, size: 18),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
