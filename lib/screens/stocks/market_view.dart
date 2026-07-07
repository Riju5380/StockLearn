import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/stock.dart';
import 'stock_detail_screen.dart';

class MarketView extends StatefulWidget {
  const MarketView({super.key});

  @override
  State<MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends State<MarketView> {
  final _searchController = TextEditingController();
  String _selectedSector = 'All';
  String _sortBy = 'Gain'; // 'Price', 'Gain', 'Volume'
  bool _searchActive = false;

  final List<String> _sectors = ['All', 'Technology', 'Banking', 'Energy', 'Automobile', 'Pharma'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter by sector & search term
    List<Stock> filteredStocks = appState.stocks.where((stock) {
      final matchesSector = _selectedSector == 'All' || stock.sector == _selectedSector;
      final matchesSearch = stock.symbol.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          stock.name.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesSector && matchesSearch;
    }).toList();

    // Sort stocks
    if (_sortBy == 'Price') {
      filteredStocks.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Gain') {
      filteredStocks.sort((a, b) => b.changePercent.compareTo(a.changePercent));
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search companies, indices, or sectors...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF151D30) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),
          ),

          // Main scrollable area
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                // 2. Market Sentiment Card
                _buildSentimentCard(context),
                const SizedBox(height: 16),

                // 3. Category Chips (Horizontal Scroll)
                _buildSectorChips(context),
                const SizedBox(height: 16),

                // 4. Sort Toggles
                _buildSortToggles(context),
                const SizedBox(height: 16),

                // 5. Stock List
                if (filteredStocks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        'No stocks found matching your filters.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredStocks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildMarketStockCard(context, filteredStocks[index]);
                    },
                  ),
                const SizedBox(height: 24),

                // 6. Pagination Footer matching screenshots
                Center(
                  child: Text(
                    'Showing ${filteredStocks.length} of 500+ stocks',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All simulated stocks are already loaded.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Load More Stocks', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Market Sentiment Card matching screenshots
  Widget _buildSentimentCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Market Sentiment',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(Icons.trending_up, color: const Color(0xFF10B981).withOpacity(0.8), size: 24),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Sensex is up by 1.2% today. Bulls are leading the tech rally.',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VOLUME', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  const Text('1.2B Shares', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VOLATILITY', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  const Text('Low (12.4)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Categories list
  Widget _buildSectorChips(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _sectors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sector = _sectors[index];
          final isSelected = _selectedSector == sector;
          return ChoiceChip(
            label: Text(sector),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedSector = sector;
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

  // Sort toggles row matching screenshots
  Widget _buildSortToggles(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget sortButton(String value) {
      final isSelected = _sortBy == value;
      return Expanded(
        child: InkWell(
          onTap: () {
            setState(() {
              _sortBy = value;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          sortButton('Price'),
          sortButton('Gain'),
          sortButton('Volume'),
        ],
      ),
    );
  }

  // Market stock card design matching screenshots
  Widget _buildMarketStockCard(BuildContext context, Stock stock) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pl = stock.changePercent;
    final isPositive = pl >= 0;
    final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock Emblem
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    stock.symbol,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name & Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      stock.sector.toUpperCase(),
                      style: TextStyle(color: Colors.grey[500], fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Favorite Star Toggle
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  stock.isFavorite ? Icons.star : Icons.star_border,
                  color: stock.isFavorite ? const Color(0xFFF59E0B) : Colors.grey,
                ),
                onPressed: () {
                  Provider.of<AppStateProvider>(context, listen: false).toggleWishlist(stock);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price and Sparkline Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA'
                        ? '\$${stock.price.toStringAsFixed(2)}'
                        : '₹${stock.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '$sign${pl.toStringAsFixed(2)}%',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              // Custom Premium Sparkline widget
              SizedBox(
                width: 80,
                height: 35,
                child: CustomPaint(
                  painter: SparklinePainter(
                    prices: stock.history1D,
                    lineColor: color,
                  ),
                ),
              ),
              // View Details Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StockDetailScreen(stock: stock)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB).withOpacity(0.08),
                  foregroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  children: const [
                    Text('View Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Sparkline Custom Painter
class SparklinePainter extends CustomPainter {
  final List<double> prices;
  final Color lineColor;

  SparklinePainter({required this.prices, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [lineColor.withOpacity(0.15), lineColor.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final double maxVal = prices.reduce(max);
    final double minVal = prices.reduce(min);
    final double range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final double widthSegment = size.width / (prices.length - 1);
    
    final path = Path();
    final fillPath = Path();

    // Start coordinates
    double x = 0;
    double y = size.height - ((prices[0] - minVal) / range * size.height);
    path.moveTo(x, y);
    fillPath.moveTo(x, size.height);
    fillPath.lineTo(x, y);

    for (int i = 1; i < prices.length; i++) {
      x += widthSegment;
      y = size.height - ((prices[i] - minVal) / range * size.height);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
