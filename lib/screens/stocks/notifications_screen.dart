import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = appState.isDarkMode;

    final mockNotifications = [
      {
        'title': 'Daily Reward Available! 🎁',
        'body': 'Your daily virtual reward of ₹1,00,000.00 is ready to be claimed in the Dashboard.',
        'time': 'Just now',
        'icon': FontAwesomeIcons.gift,
        'color': const Color(0xFF10B981),
        'category': 'REWARD',
      },
      {
        'title': 'Price Alert Triggered: TCS 📈',
        'body': 'TCS has crossed above your alert threshold of ₹3,550.00 (Current: ₹3,552.50).',
        'time': '1 hour ago',
        'icon': FontAwesomeIcons.bell,
        'color': const Color(0xFFF59E0B),
        'category': 'ALERT',
      },
      {
        'title': 'Course Unlocked: Diagnostic Precision',
        'body': 'You have successfully enrolled in "Diagnostic Precision in Modern Oncology". Start learning now!',
        'time': '2 hours ago',
        'icon': FontAwesomeIcons.graduationCap,
        'color': const Color(0xFF2563EB),
        'category': 'ACADEMY',
      },
      {
        'title': 'Wallet Top-up Successful ✅',
        'body': 'Successfully added ₹50,000.00 virtual money to your wallet via UPI.',
        'time': '1 day ago',
        'icon': FontAwesomeIcons.wallet,
        'color': const Color(0xFF10B981),
        'category': 'WALLET',
      },
      {
        'title': 'Welcome to StockLearn! 🚀',
        'body': 'Start exploring the stock simulator with your free ₹1,00,000.00 virtual cash balance.',
        'time': '3 days ago',
        'icon': FontAwesomeIcons.circleUser,
        'color': const Color(0xFF8B5CF6),
        'category': 'SYSTEM',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: mockNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.bellSlash,
                    size: 64,
                    color: isDark ? const Color(0xFF1E293B) : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All Caught Up!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No new alerts or notifications at this time.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: mockNotifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = mockNotifications[index];
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF151D30) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: !isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (notification['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          notification['icon'] as FaIconData,
                          size: 18,
                          color: notification['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (notification['color'] as Color).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    notification['category'] as String,
                                    style: TextStyle(
                                      color: notification['color'] as Color,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  notification['time'] as String,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification['body'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
