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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Filter stocks for lists
    final wishlistStocks = appState.stocks.where((s) => s.isFavorite).toList();
    
    final sortedStocks = List<Stock>.from(appState.stocks)
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    
    final gainers = sortedStocks.take(3).toList();
    final losers = sortedStocks.reversed.take(3).toList();

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

          // 4. Top Gainers
          _buildSectionHeader(context, 'Top Gainers', () => onNavigateToTab(1)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gainers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildStockRow(context, gainers[index]);
            },
          ),
          const SizedBox(height: 24),

          // 5. Top Losers
          _buildSectionHeader(context, 'Top Losers', () => onNavigateToTab(1)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: losers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildStockRow(context, losers[index]);
            },
          ),
          const SizedBox(height: 24),

          // 6. Your Progress Card
          _buildProgressCard(context),
          const SizedBox(height: 24),

          // 7. Daily Challenge Card
          _buildDailyChallengeCard(context),
          const SizedBox(height: 24),

          // 8. Pro Tip Card
          _buildProTipCard(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Virtual Balance Card matching screenshot
  Widget _buildBalanceCard(BuildContext context, AppStateProvider appState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

  // Quick Actions Grid matching screenshots
  Widget _buildQuickActionsGrid(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget actionCard(String label, FaIconData icon, Color color, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151D30) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.5,
      children: [
        actionCard('Market', FontAwesomeIcons.chartLine, const Color(0xFF2563EB), () => onNavigateToTab(1)),
        actionCard('Portfolio', FontAwesomeIcons.wallet, const Color(0xFF10B981), () => onNavigateToTab(2)),
        actionCard('Learn', FontAwesomeIcons.bookOpen, const Color(0xFFD97706), () {
          appState.setNavigationIndex(1);
          appState.setClassesTabIndex(1);
        }),
        actionCard('History', FontAwesomeIcons.clockRotateLeft, const Color(0xFF7C3AED), () => onNavigateToTab(3)),
      ],
    );
  }

  // Stock Row Design used on Wishlist, Gainers, Losers
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

  // Your Progress card matching screenshots
  Widget _buildProgressCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              Text(
                'Your Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Beginner Level', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('65%', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.65,
              minHeight: 8,
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('LESSONS', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('12/18', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('QUIZ SCORE', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('850', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Keep it up! Complete 3 more lessons to unlock the Intermediate Trading certificate.',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              showUnderDevelopmentDialog(context, 'Continue Learning');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Continue Learning', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Daily Challenge card matching screenshots
  Widget _buildDailyChallengeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bolt, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text(
                'Daily Challenge',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Predict Nifty 50 close price within ±0.2% range.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('Ends in 4h', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(width: 16),
              Icon(Icons.emoji_events_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('Reward: 500 Coins', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Daily Challenge'),
                  content: const Text('This is a simulated challenge. Predict the closed price of Nifty50. Submissions will open during live hours.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: Color(0xFF1E3A8A)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Participate', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Pro Tip card matching screenshots
  Widget _buildProTipCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.4) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text('Pro Tip: Volatility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"High volatility doesn\'t always mean a bad investment. It means price swings are frequent, which can create entry opportunities for long-term growth."',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
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
      // Indian format support (e.g. 1,00,000)
      return val.toStringAsFixed(2);
    }
    return val.toStringAsFixed(2);
  }
}
