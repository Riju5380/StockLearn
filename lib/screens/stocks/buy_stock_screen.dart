import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/stock.dart';

/// Screen that allows users to place simulated buy orders for stocks.
///
/// Displays the stock current price, lets user enter quantity,
/// computes transaction cost in INR, and performs virtual checkout.
class BuyStockScreen extends StatefulWidget {
  /// The stock which the user wants to buy.
  final Stock stock;

  /// Creates a [BuyStockScreen] widget.
  const BuyStockScreen({super.key, required this.stock});

  @override
  State<BuyStockScreen> createState() => _BuyStockScreenState();
}

class _BuyStockScreenState extends State<BuyStockScreen> {
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

    // Convert US stocks price to INR for local cost calculations
    double priceInInr = dynamicStock.price;
    if (dynamicStock.symbol == 'AAPL' || dynamicStock.symbol == 'GOOGL' || dynamicStock.symbol == 'NVDA') {
      priceInInr = dynamicStock.price * AppStateProvider.usdToInr;
    }

    final estimatedSubtotal = priceInInr * _shares;
    final brokerageFee = estimatedSubtotal * 0.001; // 0.1% brokerage
    final totalPayable = estimatedSubtotal + brokerageFee;

    final canAfford = appState.walletBalance >= totalPayable;
    final isInputValid = _shares > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Stock', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
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
                    // Under Development / Simulation Alert
                    _buildWarningBanner(isDark),
                    const SizedBox(height: 16),

                    // 1. Top Stock Info Card
                    _buildStockInfoCard(dynamicStock, isDark),
                    const SizedBox(height: 16),

                    // 2. Purchase Details Input Card
                    _buildPurchaseDetailsCard(appState, priceInInr, estimatedSubtotal, brokerageFee, isDark),
                    const SizedBox(height: 16),

                    // 3. Order Summary Card
                    _buildOrderSummary(totalPayable, isDark),
                    const SizedBox(height: 16),

                    // 4. Disclaimer text matching screenshots
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'By clicking "Confirm", you are executing a simulated trade. Market orders are executed at the best available current price.',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Persistent Button
              _buildConfirmButton(appState, dynamicStock, totalPayable, isInputValid, canAfford),
            ],
          ),
        ),
      ),
    );
  }

  // Stock info card
  Widget _buildStockInfoCard(Stock stock, bool isDark) {
    final isPositive = stock.changePercent >= 0;
    final trendColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final sign = isPositive ? '+' : '';

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
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.business, color: Color(0xFF2563EB)),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA'
                    ? '\$${stock.price.toStringAsFixed(2)}'
                    : '₹${stock.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                '$sign${stock.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Purchase input details
  Widget _buildPurchaseDetailsCard(AppStateProvider appState, double priceInInr, double subtotal, double fee, bool isDark) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PURCHASE DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Text(
                    '₹${appState.walletBalance.toStringAsFixed(2)} Available',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter number of shares',
              suffixText: 'Shares',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated Cost', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Brokerage Fees (0.1%)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('₹${fee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Order summary cards
  Widget _buildOrderSummary(double totalPayable, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: const Text('MARKET ORDER', style: TextStyle(color: Color(0xFF2563EB), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Transaction Type', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('Buy / Long', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Quantity', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('${_shares.toStringAsFixed(_shares == _shares.toInt() ? 0 : 2)} Shares', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Payable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('₹${totalPayable.toStringAsFixed(2)}', style: TextStyle(color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom action execution
  Widget _buildConfirmButton(AppStateProvider appState, Stock stock, double totalPayable, bool isInputValid, bool canAfford) {
    VoidCallback? onPressed;
    String label = 'Confirm Purchase';

    if (!isInputValid) {
      onPressed = null;
      label = 'Enter Quantity';
    } else if (!canAfford) {
      onPressed = null;
      label = 'Insufficient Balance';
    } else {
      onPressed = () {
        _showDevelopmentNotice(context);
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
          backgroundColor: const Color(0xFF10B981), // Emerald green
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.shopping_cart_outlined),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  /// Builds a modern warning banner indicating this is a simulated trade.
  Widget _buildWarningBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Simulation Environment Only',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This feature is currently under development. Trades executed here use virtual money and do not involve real stocks or actual currency transactions.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Displays a polished alert dialog informing the user that live stock trading is under development.
  void _showDevelopmentNotice(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: Color(0xFFF59E0B)),
            SizedBox(width: 10),
            Text('Feature Unavailable', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Live stock purchasing is currently under active development for our production release.\n\nThis app is currently in view-only learning mode. Placing real-world or simulated trades is disabled at this time.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back to details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Understood', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
