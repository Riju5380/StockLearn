import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/profile_avatar.dart';
import 'dashboard_view.dart';
import 'market_view.dart';
import 'portfolio_view.dart';
import 'history_view.dart';
import 'notifications_screen.dart';

class StocksTabLayout extends StatefulWidget {
  const StocksTabLayout({super.key});

  @override
  State<StocksTabLayout> createState() => _StocksTabLayoutState();
}

class _StocksTabLayoutState extends State<StocksTabLayout> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 4 Tabs: Dashboard, Market, Portfolio, History
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    // Only rebuild to update canPop when index finished changing
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _tabController.index == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              const Icon(Icons.show_chart, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                'StockLearn',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                Provider.of<AppStateProvider>(context, listen: false).setNavigationIndex(3);
              },
              child: const Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ProfileAvatar(radius: 16, iconSize: 18),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                dividerHeight: 0.0,
                indicatorColor: const Color(0xFF1E3A8A),
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: isDark ? Colors.white : const Color(0xFF0F172A),
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Market'),
                  Tab(text: 'Portfolio'),
                  Tab(text: 'History'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            DashboardView(
              onNavigateToTab: (index) {
                _tabController.animateTo(index);
              },
            ),
            const MarketView(),
            const PortfolioView(),
            const HistoryView(),
          ],
        ),
      ),
    );
  }
}
