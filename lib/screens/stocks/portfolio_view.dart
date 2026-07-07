import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/app_state_provider.dart';
import '../../models/stock.dart';
import 'stock_detail_screen.dart';
import '../../utils/dialogs.dart';

class PortfolioView extends StatelessWidget {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final invested = appState.totalInvested;
    final current = appState.portfolioValue;
    final pl = appState.overallProfitLossInr;
    final plPercent = appState.overallProfitLossPercent;

    final plSign = pl >= 0 ? '+' : '';
    final plColor = pl >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    // Filter holdings list
    final heldSymbols = appState.holdings.keys.toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Portfolio Metrics Summary Block
          _buildMetricsSummaryCard(invested, current, pl, plPercent, plSign, plColor, isDark),
          const SizedBox(height: 16),

          // 2. Allocation Breakdown Chart Card
          if (heldSymbols.isNotEmpty) ...[
            _buildAllocationCard(context, appState, isDark),
            const SizedBox(height: 16),
          ],

          // 3. Your Holdings List
          _buildHoldingsSection(context, appState, heldSymbols, isDark),
          const SizedBox(height: 16),

          // 4. Portfolio Health Indicators Grid
          _buildHealthGrid(context, isDark),
          const SizedBox(height: 16),

          // 5. Grow Your Knowledge promo banner
          _buildPromoBanner(context, isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Summary Card matching screenshots
  Widget _buildMetricsSummaryCard(
      double invested,
      double current,
      double pl,
      double plPercent,
      String plSign,
      Color plColor,
      bool isDark) {
    
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
          const Text('TOTAL INVESTED', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '₹${invested.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const Divider(height: 24),
          const Text('CURRENT VALUE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '₹${current.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          const Text('OVERALL PROFIT/LOSS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(pl >= 0 ? Icons.arrow_upward : Icons.arrow_downward, color: plColor, size: 16),
              const SizedBox(width: 4),
              Text(
                '$plSign₹${pl.abs().toStringAsFixed(2)} (${plPercent.toStringAsFixed(2)}%)',
                style: TextStyle(color: plColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Allocation breakdown utilizing fl_chart PieChart
  Widget _buildAllocationCard(BuildContext context, AppStateProvider appState, bool isDark) {
    // Group holdings by sector to calculate percentages
    final Map<String, double> sectorValues = {};
    double totalValue = 0.0;

    appState.holdings.forEach((symbol, shares) {
      final stock = appState.stocks.firstWhere((s) => s.symbol == symbol, orElse: () => appState.stocks[0]);
      double priceInInr = stock.price;
      if (stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA') {
        priceInInr = stock.price * AppStateProvider.usdToInr;
      }
      final value = shares * priceInInr;
      sectorValues[stock.sector] = (sectorValues[stock.sector] ?? 0.0) + value;
      totalValue += value;
    });

    final List<PieChartSectionData> sections = [];
    final List<Widget> legends = [];

    // Distinct colors for chart
    final List<Color> colors = [
      const Color(0xFF1E3A8A), // Deep Navy
      const Color(0xFF10B981), // Emerald Green
      const Color(0xFF2563EB), // Accent Blue
      const Color(0xFFD97706), // Amber
      const Color(0xFF7C3AED), // Purple
      const Color(0xFFEC4899), // Pink
    ];

    int colorIndex = 0;
    sectorValues.forEach((sector, value) {
      final percentage = totalValue == 0 ? 0.0 : (value / totalValue) * 100;
      final color = colors[colorIndex % colors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 35,
          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );

      legends.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('$sector (${percentage.toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 11)),
          ],
        ),
      );

      colorIndex++;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Allocation Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 35,
                    sections: sections,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: legends,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Holdings list card matching screenshots
  Widget _buildHoldingsSection(BuildContext context, AppStateProvider appState, List<String> symbols, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Holdings', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {
                showUnderDevelopmentDialog(context, 'Portfolio reports');
              },
              child: const Text('View Report', style: TextStyle(color: Color(0xFF2563EB))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (symbols.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151D30) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'You do not own any stocks yet.\nGo to the Market section to buy stocks.',
                style: TextStyle(color: Colors.grey, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: symbols.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final symbol = symbols[index];
              final shares = appState.holdings[symbol] ?? 0.0;
              final avgPrice = appState.avgPurchasePrices[symbol] ?? 0.0;
              final stock = appState.stocks.firstWhere((s) => s.symbol == symbol, orElse: () => appState.stocks[0]);

              final isUsStock = stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA';
              final currencySymbol = isUsStock ? '\$' : '₹';
              double priceInInr = stock.price;
              double avgPriceInInr = avgPrice;
              if (isUsStock) {
                priceInInr = stock.price * AppStateProvider.usdToInr;
                avgPriceInInr = avgPrice * AppStateProvider.usdToInr;
              }

              // Value calculation in INR
              final currentTotalValInr = shares * priceInInr;
              final holdingPLInr = shares * (priceInInr - avgPriceInInr);
              final isPositive = holdingPLInr >= 0;
              final plColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
              final plSign = isPositive ? '+' : '';

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StockDetailScreen(stock: stock)),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF151D30) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      // Badge
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
                      // Middle details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stock.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text(
                              '${shares.toStringAsFixed(shares == shares.toInt() ? 0 : 2)} Shares @ $currencySymbol${avgPrice.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      // Value details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${currentTotalValInr.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$plSign₹${holdingPLInr.abs().toStringAsFixed(2)}',
                            style: TextStyle(color: plColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // Health Scorecards matching screenshots
  Widget _buildHealthGrid(BuildContext context, bool isDark) {
    Widget healthCard(String label, String value, IconData icon, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: FaIcon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        healthCard('Diversification Score', '84/100', FontAwesomeIcons.shieldHalved, const Color(0xFF2563EB)),
        const SizedBox(height: 10),
        healthCard('Risk Level', 'Moderate', FontAwesomeIcons.circleExclamation, const Color(0xFF10B981)),
        const SizedBox(height: 10),
        healthCard('Performance Trend', 'Strong Buy', FontAwesomeIcons.arrowTrendUp, const Color(0xFF7C3AED)),
      ],
    );
  }

  // Bottom educational promo banner matching screenshots
  Widget _buildPromoBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF151D30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grow Your Knowledge',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Your portfolio\'s health is the reflection of your learning journey. Keep exploring new market trends.',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please tap on bottom "Classes" tab to explore learning courses.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text('Explore Education', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
