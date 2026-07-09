import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/top_up_log.dart';

/// Screen that simulates virtual wallet top-ups.
///
/// Allows the user to pick preset or custom amounts to top up their virtual
/// wallet balance, showing a simulated transaction cost.
class TopUpScreen extends StatefulWidget {
  /// Creates a [TopUpScreen] widget.
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _amountController = TextEditingController(text: '50000');
  double _amount = 50000.0;
  String _selectedMethod = 'UPI';

  final List<double> _predefinedAmounts = [10000.0, 25000.0, 50000.0, 100000.0];
  final List<String> _paymentMethods = ['UPI', 'Credit/Debit Card', 'Net Banking'];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateAmount);
  }

  void _updateAmount() {
    final parsed = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _amount = parsed;
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateAmount);
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Simulated charge: 0.1% of virtual amount added
    final realMoneyCharge = _amount * 0.001;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top up Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Under Development / Simulation Alert Notice
                  _buildWarningBanner(isDark),
                  const SizedBox(height: 16),

                  // 1. Current Wallet Status Card
                  _buildBalanceCard(appState, isDark),
                  const SizedBox(height: 20),

                  // 2. Select Predefined Amounts Row
                  const Text('Select Predefined Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 10),
                  _buildPredefinedAmountsList(isDark),
                  const SizedBox(height: 16),

                  // 3. Amount input field
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Custom Virtual Amount',
                      hintText: 'Enter amount to top up',
                      prefixText: '₹',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Payment Method dropdown selector
                  const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 10),
                  _buildPaymentMethodDropdown(isDark),
                  const SizedBox(height: 20),

                  // 5. Cost Details Box
                  _buildCostDetailsBox(realMoneyCharge, isDark),
                  const SizedBox(height: 24),

                  // 6. Top-Up transaction logs history
                  Text(
                    'TOP-UP HISTORY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTopUpLogsList(appState.topUpLogs, isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Confirm Top Up Button
            _buildConfirmButton(appState, realMoneyCharge),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(AppStateProvider appState, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Current Simulator Balance:', style: TextStyle(fontWeight: FontWeight.w600)),
          Text(
            '₹${appState.walletBalance.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  Widget _buildPredefinedAmountsList(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _predefinedAmounts.map((amt) {
        final isSelected = _amount == amt;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () {
                _amountController.text = amt.toStringAsFixed(0);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E3A8A)
                      : (isDark ? const Color(0xFF151D30) : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Text(
                  '₹${(amt / 1000).toStringAsFixed(0)}K',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : (isDark ? Colors.grey[350] : Colors.black87),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMethod,
          isExpanded: true,
          items: _paymentMethods.map((m) {
            return DropdownMenuItem(value: m, child: Text(m));
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedMethod = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildCostDetailsBox(double charge, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Virtual Fund Amount', style: TextStyle(fontSize: 13, color: Colors.grey)),
              Text('₹${_amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Real Money Processing Fee (0.1%)', style: TextStyle(fontSize: 13, color: Colors.grey)),
              Text('₹${charge.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Actual Real Cost Charged', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('₹${charge.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpLogsList(List<TopUpLog> logs, bool isDark) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text('No previous top-up logs available.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final log = logs[index];
        final dateStr = '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year}';
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151D30) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Added ₹${log.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('${log.paymentMethod} • $dateStr', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Charge: ₹${log.charge.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEF4444))),
                  const SizedBox(height: 2),
                  const Text('Success', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton(AppStateProvider appState, double realMoneyCharge) {
    final isInputValid = _amount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: ElevatedButton(
        onPressed: !isInputValid
            ? null
            : () {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) => _buildPaymentSimulationSheet(appState, realMoneyCharge),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Proceed to Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  // Bottom sheet simulator for UPI/card payment details
  Widget _buildPaymentSimulationSheet(AppStateProvider appState, double charge) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.payment, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Simulated Payment Gateway',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'You are authorizing a simulated real charge of ₹${charge.toStringAsFixed(2)} to credit your simulator wallet with ₹${_amount.toStringAsFixed(0)} virtual funds.',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 10),
          Text(
            'Simulated Method: $_selectedMethod',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () {
              _showDevelopmentNotice(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simulate Successful Pay', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment simulation cancelled by user.')),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel Payment'),
          ),
        ],
      ),
    );
  }

  /// Builds a modern warning banner indicating this is a simulated payment/top-up.
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
                  'Payment and top-up features are under active development. No real money or charges are processed during this simulated flow.',
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

  /// Displays a polished alert dialog informing the user that wallet top-up is under development.
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
          'Wallet top-up is currently under active development for our production release.\n\nThis app is currently in view-only learning mode. Adding real or virtual currency is disabled at this time.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // close bottom sheet/modal
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
