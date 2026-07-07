import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/app_state_provider.dart';
import '../../models/transaction.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  String _selectedFilter = 'All'; // 'All', 'Buy', 'Sell', 'Profit', 'Loss'

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allTx = appState.transactions;

    // Calculate trade metrics
    final totalTrades = allTx.length;
    final winningTradesList = allTx.where((tx) => tx.type == 'SELL' && tx.realizedProfitLoss > 0).toList();
    final losingTradesList = allTx.where((tx) => tx.type == 'SELL' && tx.realizedProfitLoss < 0).toList();
    
    final winningTradesCount = winningTradesList.length;
    final losingTradesCount = losingTradesList.length;

    double winRate = 0.0;
    double lossRate = 0.0;
    final sellCount = winningTradesCount + losingTradesCount;
    if (sellCount > 0) {
      winRate = (winningTradesCount / sellCount) * 100;
      lossRate = (losingTradesCount / sellCount) * 100;
    }

    // Find best trade (highest realized profit)
    double bestTradeVal = 0.0;
    String bestTradeSymbol = 'N/A';
    for (var tx in allTx) {
      if (tx.type == 'SELL' && tx.realizedProfitLoss > bestTradeVal) {
        bestTradeVal = tx.realizedProfitLoss;
        bestTradeSymbol = tx.symbol;
      }
    }

    // Filter transactions list
    List<StockTransaction> filteredTx = [];
    if (_selectedFilter == 'All') {
      filteredTx = allTx;
    } else if (_selectedFilter == 'Buy') {
      filteredTx = allTx.where((tx) => tx.type == 'BUY').toList();
    } else if (_selectedFilter == 'Sell') {
      filteredTx = allTx.where((tx) => tx.type == 'SELL').toList();
    } else if (_selectedFilter == 'Profit') {
      filteredTx = allTx.where((tx) => tx.type == 'SELL' && tx.realizedProfitLoss > 0).toList();
    } else if (_selectedFilter == 'Loss') {
      filteredTx = allTx.where((tx) => tx.type == 'SELL' && tx.realizedProfitLoss < 0).toList();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Trade Metrics Dashboard (2x2 Grid)
          _buildMetricsGrid(totalTrades, winningTradesCount, losingTradesCount, winRate, lossRate, bestTradeVal, bestTradeSymbol, isDark),
          const SizedBox(height: 20),

          // 2. Filter Tabs Horizontal Selector
          _buildFilterTabs(isDark),
          const SizedBox(height: 16),

          // 3. Transactions Log List
          if (filteredTx.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151D30) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Text(
                  'No transactions found for filter "$_selectedFilter".',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTx.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildTransactionRow(context, filteredTx[index], isDark);
              },
            ),
          const SizedBox(height: 24),

          // 4. Tax promo card matching screenshots
          _buildTaxPromoCard(context, isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 2x2 grid card metrics
  Widget _buildMetricsGrid(
      int total,
      int winCount,
      int lossCount,
      double winRate,
      double lossRate,
      double bestVal,
      String bestSymbol,
      bool isDark) {
    
    Widget metricBox(String label, String value, IconData icon, Color color, [String? subText]) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                FaIcon(icon, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (subText != null) ...[
              const SizedBox(height: 2),
              Text(subText, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        metricBox('Total Trades', '$total', FontAwesomeIcons.chartBar, const Color(0xFF2563EB), '+12% this month'),
        metricBox('Winning Trades', '$winCount', FontAwesomeIcons.circleCheck, const Color(0xFF10B981), 'Win Rate: ${winRate.toStringAsFixed(1)}%'),
        metricBox('Losing Trades', '$lossCount', FontAwesomeIcons.circleXmark, const Color(0xFFEF4444), 'Loss Rate: ${lossRate.toStringAsFixed(1)}%'),
        metricBox(
          'Best Trade',
          bestVal == 0 ? 'N/A' : '₹${bestVal.toStringAsFixed(0)}',
          FontAwesomeIcons.medal,
          const Color(0xFF7C3AED),
          bestSymbol == 'N/A' ? null : '$bestSymbol (Jun 2026)',
        ),
      ],
    );
  }

  // Filter tabs bar
  Widget _buildFilterTabs(bool isDark) {
    final List<String> filters = ['All', 'Buy', 'Sell', 'Profit', 'Loss'];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            selectedColor: const Color(0xFF1E3A8A),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            backgroundColor: isDark ? const Color(0xFF151D30) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  // Row card matching screenshots
  Widget _buildTransactionRow(BuildContext context, StockTransaction tx, bool isDark) {
    final isBuy = tx.type == 'BUY';
    final isUsStock = tx.symbol == 'AAPL' || tx.symbol == 'GOOGL' || tx.symbol == 'NVDA';
    final currencySymbol = isUsStock ? '\$' : '₹';

    Color valueColor = isDark ? Colors.white : const Color(0xFF0F172A);
    String valueText = '₹${tx.totalAmount.toStringAsFixed(2)}';
    String badgeText = 'Executed';
    Color badgeBg = const Color(0xFF2563EB).withOpacity(0.1);
    Color badgeFg = const Color(0xFF2563EB);

    if (!isBuy) {
      final isProfit = tx.realizedProfitLoss >= 0;
      badgeText = isProfit ? 'Successful' : 'Settled';
      badgeBg = isProfit ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1);
      badgeFg = isProfit ? const Color(0xFF10B981) : const Color(0xFFD97706);
      
      valueColor = isProfit ? const Color(0xFF10B981) : const Color(0xFFEF4444);
      valueText = '${isProfit ? '+' : '-'}₹${tx.realizedProfitLoss.abs().toStringAsFixed(2)} ${isProfit ? 'PROFIT' : 'LOSS'}';
    }

    final dateStr = '${tx.timestamp.day} ${_getMonthName(tx.timestamp.month)} ${tx.timestamp.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isBuy
                  ? const Color(0xFF2563EB).withOpacity(0.1)
                  : (tx.realizedProfitLoss >= 0 ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isBuy ? Icons.shopping_cart_outlined : Icons.sell_outlined,
                color: isBuy
                    ? const Color(0xFF2563EB)
                    : (tx.realizedProfitLoss >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Middle content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tx.type} ${tx.symbol}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  '${tx.shares.toStringAsFixed(tx.shares == tx.shares.toInt() ? 0 : 2)} Shares • $dateStr',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          // Right content (value + badge)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valueText,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: valueColor),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  badgeText,
                  style: TextStyle(color: badgeFg, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Promo card matching screenshots
  Widget _buildTaxPromoCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2138) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Master your taxes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Learn how to calculate Short-Term Capital Gains (STCG) on your simulated profits.',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.4),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text('Start Module', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
