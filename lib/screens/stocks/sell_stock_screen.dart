import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/stock.dart';

class SellStockScreen extends StatefulWidget {
  final Stock stock;

  const SellStockScreen({super.key, required this.stock});

  @override
  State<SellStockScreen> createState() => _SellStockScreenState();
}

class _SellStockScreenState extends State<SellStockScreen> {
  final _quantityController = TextEditingController();
  double _shares = 0.0;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_updateShares);
  }

  void _updateShares() {
    final parsed = double.tryParse(_quantityController.text) ?? 0.0;
    setState(() {
      _shares = parsed;
    });
  }

  @override
  void dispose() {
    _quantityController.removeListener(_updateShares);
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final dynamicStock = appState.stocks.firstWhere(
      (s) => s.symbol == widget.stock.symbol,
      orElse: () => widget.stock,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // User Holdings information
    final ownedShares = appState.holdings[dynamicStock.symbol] ?? 0.0;
    final avgPrice = appState.avgPurchasePrices[dynamicStock.symbol] ?? 0.0;

    // Currency Symbol and price converter check
    final isUsStock = dynamicStock.symbol == 'AAPL' || dynamicStock.symbol == 'GOOGL' || dynamicStock.symbol == 'NVDA';
    final currencySymbol = isUsStock ? '\$' : '₹';
    double priceInInr = dynamicStock.price;
    double avgPriceInInr = avgPrice;
    
    if (isUsStock) {
      priceInInr = dynamicStock.price * AppStateProvider.usdToInr;
      avgPriceInInr = avgPrice * AppStateProvider.usdToInr;
    }

    final totalPL = ownedShares * (priceInInr - avgPriceInInr);
    final isPLPositive = totalPL >= 0;
    final plColor = isPLPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final plSign = isPLPositive ? '+' : '';

    // Calculations for Selling Portion
    final investedAmountToSell = avgPrice * _shares;
    final marketValueToSell = dynamicStock.price * _shares;
    final estimatedProfitToSell = (dynamicStock.price - avgPrice) * _shares;
    final isProfitPositive = estimatedProfitToSell >= 0;

    final isInputValid = _shares > 0;
    final hasEnoughShares = _shares <= ownedShares;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Stock', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // 1. Stock Title Info Header
                    _buildStockHeaderCard(dynamicStock, isDark),
                    const SizedBox(height: 16),

                    // 2. Statistics Grid (Owned, Prices, P/L)
                    _buildOwnedStatsGrid(ownedShares, dynamicStock.price, avgPrice, totalPL, isUsStock, currencySymbol, plColor, plSign, isDark),
                    const SizedBox(height: 16),

                    // 3. Amount to Sell Input Card
                    _buildAmountToSellCard(ownedShares, isDark),
                    const SizedBox(height: 16),

                    // 4. Transaction Summary Card
                    _buildTransactionSummary(investedAmountToSell, marketValueToSell, estimatedProfitToSell, isProfitPositive, currencySymbol, isDark),
                  ],
                ),
              ),

              // Bottom Confirm Button
              _buildConfirmButton(appState, dynamicStock, _shares, isInputValid, hasEnoughShares, marketValueToSell, isUsStock),
            ],
          ),
        ),
      ),
    );
  }

  // Header card matching screenshots
  Widget _buildStockHeaderCard(Stock stock, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.trending_down, color: Color(0xFFEF4444)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.symbol,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                ),
                Text(
                  stock.name,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Owned stats grid
  Widget _buildOwnedStatsGrid(
      double ownedShares,
      double currentPrice,
      double avgPrice,
      double totalPL,
      bool isUsStock,
      String currencySymbol,
      Color plColor,
      String plSign,
      bool isDark) {
    
    Widget statBox(String label, String value, [Color? valueColor]) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: valueColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    // Convert P/L back to original currency if USD stock
    double displayPL = totalPL;
    if (isUsStock) {
      displayPL = totalPL / AppStateProvider.usdToInr;
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        statBox('Shares Owned', ownedShares.toStringAsFixed(ownedShares == ownedShares.toInt() ? 0 : 3)),
        statBox('Current Price', '$currencySymbol${currentPrice.toStringAsFixed(2)}'),
        statBox('Avg. Purchase Price', '$currencySymbol${avgPrice.toStringAsFixed(2)}'),
        statBox('Total P/L', '$plSign$currencySymbol${displayPL.toStringAsFixed(2)}', plColor),
      ],
    );
  }

  // Amount to sell selectors matching screenshots
  Widget _buildAmountToSellCard(double ownedShares, bool isDark) {
    Widget percentButton(double fraction, String label) {
      return Expanded(
        child: OutlinedButton(
          onPressed: ownedShares == 0
              ? null
              : () {
                  final calculated = ownedShares * fraction;
                  _quantityController.text = calculated.toStringAsFixed(calculated == calculated.toInt() ? 0 : 2);
                },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Amount to Sell', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextButton(
                onPressed: ownedShares == 0
                    ? null
                    : () {
                        _quantityController.text = ownedShares.toStringAsFixed(ownedShares == ownedShares.toInt() ? 0 : 3);
                      },
                child: const Text(
                  'SELL MAX',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 14),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              percentButton(0.25, '25%'),
              const SizedBox(width: 8),
              percentButton(0.50, '50%'),
              const SizedBox(width: 8),
              percentButton(0.75, '75%'),
              const SizedBox(width: 8),
              percentButton(1.00, '100%'),
            ],
          ),
        ],
      ),
    );
  }

  // Summary box matching screenshots
  Widget _buildTransactionSummary(double invested, double marketValue, double profit, bool isProfitPositive, String currencySymbol, bool isDark) {
    final profitColor = isProfitPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final sign = isProfitPositive ? '+' : '';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFEF4444).withOpacity(0.08),
            child: const Text(
              'TRANSACTION SUMMARY',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Invested Amount', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('$currencySymbol${invested.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Market Value', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('$currencySymbol${marketValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated Profit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('$sign$currencySymbol${profit.toStringAsFixed(2)}', style: TextStyle(color: profitColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Red button execution matching screenshots
  Widget _buildConfirmButton(
      AppStateProvider appState,
      Stock stock,
      double sellShares,
      bool isInputValid,
      bool hasEnoughShares,
      double marketValueOriginal,
      bool isUsStock) {
    
    VoidCallback? onPressed;
    String label = 'Confirm Sell';

    if (!isInputValid) {
      onPressed = null;
      label = 'Enter Quantity';
    } else if (!hasEnoughShares) {
      onPressed = null;
      label = 'Insufficient Shares';
    } else {
      onPressed = () async {
        final success = await appState.sellStock(stock, sellShares);
        if (!mounted) return;
        if (success) {
          // Calculate display text in appropriate currency
          double totalProceeds = marketValueOriginal;
          String proceedsStr = isUsStock ? '\$${totalProceeds.toStringAsFixed(2)}' : '₹${totalProceeds.toStringAsFixed(2)}';
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF10B981)),
                  SizedBox(width: 8),
                  Text('Order Executed'),
                ],
              ),
              content: Text('Successfully sold ${sellShares.toStringAsFixed(sellShares == sellShares.toInt() ? 0 : 2)} shares of ${stock.symbol} for a total of $proceedsStr.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction failed. Please try again.')),
          );
        }
      };
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444), // Rose red
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.sell_outlined),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
