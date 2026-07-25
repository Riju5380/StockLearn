import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/app_state_provider.dart';
import '../../models/stock.dart';
import 'stock_detail_screen.dart';
import '../../utils/dialogs.dart';

class DashboardView extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const DashboardView({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    // Filter stocks for wishlist
    final wishlistStocks = appState.stocks.where((s) => s.isFavorite).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Virtual Balance Card
          _buildBalanceCard(context, appState),
          const SizedBox(height: 24),

          // 2. Quick Actions
          _buildSectionHeader(context, 'Quick Actions', null),
          const SizedBox(height: 12),
          _buildQuickActionsGrid(context),
          const SizedBox(height: 24),

          // 3. Wishlist Section
          _buildSectionHeader(context, 'Wishlist', () => onNavigateToTab(1)), // Go to Market
          const SizedBox(height: 12),
          if (wishlistStocks.isEmpty)
            _buildEmptyStateCard(context, 'Your wishlist is empty. Add stocks from Market.', () => onNavigateToTab(1))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wishlistStocks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildStockRow(context, wishlistStocks[index]);
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Virtual Balance Card
  Widget _buildBalanceCard(BuildContext context, AppStateProvider appState) {
    final pl = appState.dailyProfitLossInr;
    final plPercent = appState.dailyProfitLossPercent;
    
    final sign = pl >= 0 ? '+' : '';
    final color = pl >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)], // Deep Navy gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'VIRTUAL BALANCE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${_formatCurrency(appState.walletBalance)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Portfolio Value',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_formatCurrency(appState.portfolioValue)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              Column(
                children: [
                  Text(
                    'Daily P/L',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sign₹${_formatCurrency(pl.abs())} (${plPercent.toStringAsFixed(2)}%)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => onNavigateToTab(1), // Go to Market
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981), // Emerald green
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Trade Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(
            'Market opens in 02:14:45',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  // Quick Actions Grid displaying 7 feature options
  Widget _buildQuickActionsGrid(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget actionCard(String label, FaIconData icon, Color color, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151D30) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.05,
      children: [
        actionCard(
          'Virtual Trading',
          FontAwesomeIcons.chartLine,
          const Color(0xFF2563EB),
          () => showUnderDevelopmentDialog(context, 'Virtual Trading'),
        ),
        actionCard(
          'Courses',
          FontAwesomeIcons.graduationCap,
          const Color(0xFF10B981),
          () => appState.setNavigationIndex(1),
        ),
        actionCard(
          'Live Classes',
          FontAwesomeIcons.video,
          const Color(0xFFEF4444),
          () => showUnderDevelopmentDialog(context, 'Live Classes'),
        ),
        actionCard(
          'News',
          FontAwesomeIcons.newspaper,
          const Color(0xFFF59E0B),
          () => appState.setNavigationIndex(2),
        ),
        actionCard(
          'IPO\'s',
          FontAwesomeIcons.rocket,
          const Color(0xFF8B5CF6),
          () => showUnderDevelopmentDialog(context, 'IPO\'s'),
        ),
        actionCard(
          'Community Chat',
          FontAwesomeIcons.comments,
          const Color(0xFFEC4899),
          () => showUnderDevelopmentDialog(context, 'Community Chat'),
        ),
        actionCard(
          'Exams & Certification',
          FontAwesomeIcons.award,
          const Color(0xFF14B8A6),
          () => showUnderDevelopmentDialog(context, 'Exams & Certification'),
        ),
      ],
    );
  }

  // Stock Row Design used on Wishlist
  Widget _buildStockRow(BuildContext context, Stock stock) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pl = stock.changePercent;
    final isPositive = pl >= 0;
    final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final sign = isPositive ? '+' : '';

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => StockDetailScreen(stock: stock)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            // Avatar Logo
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  stock.symbol,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stock.sector,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Price Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA'
                      ? '\$${stock.price.toStringAsFixed(2)}'
                      : '₹${_formatCurrency(stock.price)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  '$sign${pl.toStringAsFixed(2)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Section Header helper
  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback? onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All', style: TextStyle(color: Color(0xFF2563EB))),
          ),
      ],
    );
  }

  Widget _buildEmptyStateCard(BuildContext context, String message, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite_border, color: Colors.grey, size: 36),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Search Market', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // Currency formatting helper
  String _formatCurrency(double val) {
    if (val >= 10000000) {
      return '${(val / 10000000).toStringAsFixed(2)} Cr';
    } else if (val >= 100000) {
      return val.toStringAsFixed(2);
    }
    return val.toStringAsFixed(2);
  }
}
