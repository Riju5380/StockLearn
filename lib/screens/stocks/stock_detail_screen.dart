import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_state_provider.dart';
import '../../models/stock.dart';
import 'buy_stock_screen.dart';
import 'sell_stock_screen.dart';

class StockDetailScreen extends StatefulWidget {
  final Stock stock;

  const StockDetailScreen({super.key, required this.stock});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  String _selectedTimeline = '1D'; // '1D', '1W', '1M', '1Y', 'All'
  bool _isCandleChart = false;

  @override
  Widget build(BuildContext context) {
    // Find dynamic updated stock from AppStateProvider to capture live updates
    final appState = Provider.of<AppStateProvider>(context);
    final dynamicStock = appState.stocks.firstWhere(
      (s) => s.symbol == widget.stock.symbol,
      orElse: () => widget.stock,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = dynamicStock.changePercent >= 0;
    final trendColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final sign = isPositive ? '+' : '';

    // Get prices history list for selected timeline
    List<double> selectedPricesHistory = dynamicStock.history1D;
    if (_selectedTimeline == '1W') selectedPricesHistory = dynamicStock.history1W;
    else if (_selectedTimeline == '1M') selectedPricesHistory = dynamicStock.history1M;
    else if (_selectedTimeline == '1Y') selectedPricesHistory = dynamicStock.history1Y;
    else if (_selectedTimeline == 'All') selectedPricesHistory = dynamicStock.historyAll;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Details', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              dynamicStock.isFavorite ? Icons.star : Icons.star_border,
              color: dynamicStock.isFavorite ? const Color(0xFFF59E0B) : (isDark ? Colors.white : Colors.black),
            ),
            onPressed: () {
              appState.toggleWishlist(dynamicStock);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 1. Stock Header Information
                  _buildStockHeader(dynamicStock, trendColor, sign),
                  const SizedBox(height: 20),

                  // 2. Chart Section (with fl_chart)
                  _buildChartCard(context, selectedPricesHistory, trendColor),
                  const SizedBox(height: 24),

                  // 3. Key Statistics Grid
                  _buildKeyStatistics(dynamicStock),
                  const SizedBox(height: 24),

                  // 4. Educational Card
                  _buildEducationalTip(context, dynamicStock),
                  const SizedBox(height: 24),

                  // 5. Market Insights (News list specific to stock)
                  _buildMarketInsights(context, dynamicStock),
                  const SizedBox(height: 24),

                  // 6. About Section
                  _buildAboutSection(context, dynamicStock),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Persistent Action Buttons at Bottom
            _buildActionButtons(context, dynamicStock),
          ],
        ),
      ),
    );
  }

  // Stock Details Header matching screenshot
  Widget _buildStockHeader(Stock stock, Color trendColor, String sign) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      stock.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stock.sector,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                stock.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA'
                        ? '\$${stock.price.toStringAsFixed(2)}'
                        : '₹${stock.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$sign${stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA' ? '\$' : '₹'}${stock.change.abs().toStringAsFixed(2)} (${stock.changePercent.toStringAsFixed(2)}%)',
                    style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Interactive Chart Card
  Widget _buildChartCard(BuildContext context, List<double> prices, Color trendColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 16, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          // Timeline & Chart Type Selector Row
          Row(
            children: [
              Expanded(child: _buildTimelineSelector()),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isCandleChart = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: !_isCandleChart
                              ? (isDark ? const Color(0xFF151D30) : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.show_chart,
                          size: 16,
                          color: !_isCandleChart
                              ? (isDark ? Colors.white : const Color(0xFF2563EB))
                              : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    GestureDetector(
                      onTap: () => setState(() => _isCandleChart = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isCandleChart
                              ? (isDark ? const Color(0xFF151D30) : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.candlestick_chart,
                          size: 16,
                          color: _isCandleChart
                              ? (isDark ? Colors.white : const Color(0xFF2563EB))
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Interactive Chart View
          SizedBox(
            height: 220,
            child: _isCandleChart
                ? _buildCandleChart(prices, isDark, trendColor)
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: prices.length / 4,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index < 0 || index >= prices.length) return const SizedBox();
                              
                              String label = '';
                              if (_selectedTimeline == '1D') {
                                if (index == 0) label = '09:30 AM';
                                else if (index == prices.length ~/ 3) label = '11:30 AM';
                                else if (index == (prices.length ~/ 3) * 2) label = '01:30 PM';
                                else if (index == prices.length - 1) label = '04:00 PM';
                              } else if (_selectedTimeline == '1W') {
                                label = 'Day $index';
                              } else {
                                label = 'P$index';
                              }
                              
                              return Text(
                                label,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                widget.stock.symbol == 'AAPL' || widget.stock.symbol == 'GOOGL' || widget.stock.symbol == 'NVDA'
                                    ? '\$${value.toStringAsFixed(0)}'
                                    : '₹${value.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (prices.length - 1).toDouble(),
                      minY: prices.reduce((a, b) => a < b ? a : b) * 0.99,
                      maxY: prices.reduce((a, b) => a > b ? a : b) * 1.01,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            prices.length,
                            (index) => FlSpot(index.toDouble(), prices[index]),
                          ),
                          isCurved: true,
                          color: trendColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [trendColor.withOpacity(0.25), trendColor.withOpacity(0.0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                widget.stock.symbol == 'AAPL' || widget.stock.symbol == 'GOOGL' || widget.stock.symbol == 'NVDA'
                                    ? '\$${spot.y.toStringAsFixed(2)}'
                                    : '₹${spot.y.toStringAsFixed(2)}',
                                TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Horizontal selector tabs for timelines
  Widget _buildTimelineSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> timelines = ['1D', '1W', '1M', '1Y', 'All'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: timelines.map((t) {
          final isSelected = _selectedTimeline == t;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTimeline = t;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF151D30) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected && !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF1E3A8A))
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Key Statistics grid matching screenshots
  Widget _buildKeyStatistics(Stock stock) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget statRow(String label, String value) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Statistics', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151D30) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              statRow('Market Cap', stock.marketCap),
              statRow('P/E Ratio', stock.peRatio.toStringAsFixed(2)),
              statRow('Dividend Yield', '${stock.dividendYield.toStringAsFixed(2)}%'),
              statRow('Avg Volume', stock.avgVolume),
              statRow('52W High', stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA' ? '\$${stock.high52w}' : '₹${stock.high52w}'),
              statRow('52W Low', stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA' ? '\$${stock.low52w}' : '₹${stock.low52w}'),
            ],
          ),
        ),
      ],
    );
  }

  // Educational tip card
  Widget _buildEducationalTip(BuildContext context, Stock stock) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.15) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2563EB).withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(Icons.school, color: Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why is P/E Ratio important?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 6),
                Text(
                  'The Price-to-Earnings (P/E) ratio shows how much investors are willing to pay for each dollar of a company\'s earnings. A higher P/E might mean the stock is overvalued or that investors expect high future growth.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('See Classes section for intermediate stock lessons.')),
                    );
                  },
                  child: Row(
                    children: const [
                      Text('Learn more in Academy', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 12, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Market Insights (Related News)
  Widget _buildMarketInsights(BuildContext context, Stock stock) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget newsCard(String category, String title, String source, String time) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(category.toUpperCase(), style: const TextStyle(color: Color(0xFF2563EB), fontSize: 9, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text('$source • $time', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.newspaper, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Market Insights', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {},
              child: const Text('View all news', style: TextStyle(color: Color(0xFF2563EB))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        newsCard(
          'TECH TODAY',
          '${stock.name} Expansion into Mixed Reality Expected to Drive Q3 Growth',
          'Financial Times',
          '2h ago',
        ),
        const SizedBox(height: 12),
        newsCard(
          'REGULATORY',
          'How New Privacy Laws Could Impact Tech Giant Ad Revenues',
          'Bloomberg',
          '5h ago',
        ),
      ],
    );
  }

  // About Section
  Widget _buildAboutSection(BuildContext context, Stock stock) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ABOUT ${stock.name.toUpperCase()}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stock.description,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // Bottom Persistent buttons (BUY / SELL)
  Widget _buildActionButtons(BuildContext context, Stock stock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          // BUY Button (Green)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BuyStockScreen(stock: stock)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // Emerald green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text('BUY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 16),
          // SELL Button (Red)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SellStockScreen(stock: stock)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444), // Rose red
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.remove_circle, size: 20),
              label: const Text('SELL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandleChart(List<double> prices, bool isDark, Color trendColor) {
    final candles = _generateCandles(prices);
    return CustomPaint(
      size: const Size(double.infinity, 220),
      painter: CandlestickPainter(
        candles: candles,
        isDark: isDark,
        symbol: widget.stock.symbol,
        timeline: _selectedTimeline,
      ),
    );
  }

  List<CandleData> _generateCandles(List<double> prices) {
    List<CandleData> candles = [];
    for (int i = 0; i < prices.length; i++) {
      double close = prices[i];
      double open = i > 0 ? prices[i - 1] : close * 0.995;
      
      double bodyDiff = (open - close).abs();
      if (bodyDiff == 0) bodyDiff = close * 0.0005;

      double highFactor = 0.2 + (i % 3) * 0.15;
      double lowFactor = 0.2 + ((i + 1) % 3) * 0.15;

      double high = max(open, close) + bodyDiff * highFactor;
      double low = min(open, close) - bodyDiff * lowFactor;

      if (low < 0) low = min(open, close) * 0.99;

      candles.add(CandleData(open: open, high: high, low: low, close: close));
    }
    return candles;
  }
}

class CandleData {
  final double open;
  final double high;
  final double low;
  final double close;

  CandleData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

class CandlestickPainter extends CustomPainter {
  final List<CandleData> candles;
  final bool isDark;
  final String symbol;
  final String timeline;

  CandlestickPainter({
    required this.candles,
    required this.isDark,
    required this.symbol,
    required this.timeline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    double highestHigh = candles.map((c) => c.high).reduce(max);
    double lowestLow = candles.map((c) => c.low).reduce(min);
    
    double diffY = highestHigh - lowestLow;
    if (diffY == 0) diffY = highestHigh * 0.02;
    double maxY = highestHigh + diffY * 0.05;
    double minY = lowestLow - diffY * 0.05;
    if (minY < 0) minY = 0.0;

    double drawHeight = size.height - 20; 
    double drawWidth = size.width - 45; 

    double scaleY(double val) {
      if (maxY == minY) return drawHeight / 2;
      return drawHeight - ((val - minY) / (maxY - minY) * drawHeight);
    }

    int gridLinesCount = 4;
    for (int j = 0; j <= gridLinesCount; j++) {
      double gridY = drawHeight * j / gridLinesCount;
      canvas.drawLine(
        Offset(45, gridY),
        Offset(size.width, gridY),
        Paint()
          ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)
          ..strokeWidth = 1,
      );

      double priceVal = maxY - (j / gridLinesCount) * (maxY - minY);
      String priceText = symbol == 'AAPL' || symbol == 'GOOGL' || symbol == 'NVDA'
          ? '\$${priceVal.toStringAsFixed(0)}'
          : '₹${priceVal.toStringAsFixed(0)}';

      final textSpan = TextSpan(
        text: priceText,
        style: TextStyle(color: Colors.grey[500], fontSize: 9),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, gridY - 6));
    }

    double xStep = drawWidth / candles.length;
    int labelsCount = 4;
    for (int i = 0; i < labelsCount; i++) {
      int index = ((candles.length - 1) * i / (labelsCount - 1)).round();
      if (index >= candles.length) index = candles.length - 1;

      double x = 45 + index * xStep + xStep / 2;

      String label = '';
      if (timeline == '1D') {
        if (i == 0) label = '09:30 AM';
        else if (i == 1) label = '11:30 AM';
        else if (i == 2) label = '01:30 PM';
        else label = '04:00 PM';
      } else if (timeline == '1W') {
        label = 'Day ${index + 1}';
      } else if (timeline == '1M') {
        label = 'Day ${index + 1}';
      } else if (timeline == '1Y') {
        label = 'Month ${index + 1}';
      } else {
        label = 'P$index';
      }

      final textSpan = TextSpan(
        text: label,
        style: TextStyle(color: Colors.grey[500], fontSize: 8, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 20, size.height - 12));
    }

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final isBullish = candle.close >= candle.open;
      final color = isBullish ? const Color(0xFF10B981) : const Color(0xFFEF4444);

      double x = 45 + i * xStep + xStep / 2;
      double yHigh = scaleY(candle.high);
      double yLow = scaleY(candle.low);
      double yOpen = scaleY(candle.open);
      double yClose = scaleY(candle.close);

      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(x, yHigh), Offset(x, yLow), wickPaint);

      double rectTop = min(yOpen, yClose);
      double rectBottom = max(yOpen, yClose);
      double bodyWidth = xStep * 0.65;
      if (bodyWidth < 2) bodyWidth = 2;
      if (bodyWidth > 12) bodyWidth = 12;

      final bodyPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x - bodyWidth / 2, rectTop, x + bodyWidth / 2, rectBottom),
          const Radius.circular(1.5),
        ),
        bodyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CandlestickPainter oldDelegate) {
    return oldDelegate.candles != candles || oldDelegate.isDark != isDark || oldDelegate.timeline != timeline;
  }
}
