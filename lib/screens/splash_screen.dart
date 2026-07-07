import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/logo_widget.dart';
import 'auth_screen.dart';
import 'main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => appState.isLoggedIn ? const MainLayout() : const AuthScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withOpacity(0.06),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                  child: AscendingTrendProgress(),
                ),
                const SizedBox(height: 24),
                Text(
                  'STOCKLEARN SIMULATOR',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'VIRTUAL STOCK MARKET SIMULATOR',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AscendingTrendProgress extends StatefulWidget {
  const AscendingTrendProgress({super.key});

  @override
  State<AscendingTrendProgress> createState() => _AscendingTrendProgressState();
}

class _AscendingTrendProgressState extends State<AscendingTrendProgress> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _trendProgress;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _trendProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(80, 30),
          painter: SplashTrendPainter(progress: _trendProgress.value),
        );
      },
    );
  }
}

class SplashTrendPainter extends CustomPainter {
  final double progress;

  SplashTrendPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    final points = [
      Offset(0, size.height * 0.85),
      Offset(size.width * 0.25, size.height * 0.55),
      Offset(size.width * 0.5, size.height * 0.7),
      Offset(size.width * 0.75, size.height * 0.3),
      Offset(size.width, size.height * 0.1),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    
    double totalWidth = size.width;
    double currentMaxX = totalWidth * progress;

    for (int i = 1; i < points.length; i++) {
      if (points[i].dx <= currentMaxX) {
        path.lineTo(points[i].dx, points[i].dy);
      } else {
        double prevX = points[i-1].dx;
        double prevY = points[i-1].dy;
        double nextX = points[i].dx;
        double nextY = points[i].dy;
        double ratio = (currentMaxX - prevX) / (nextX - prevX);
        if (ratio > 0) {
          double interX = prevX + (nextX - prevX) * ratio;
          double interY = prevY + (nextY - prevY) * ratio;
          path.lineTo(interX, interY);
        }
        break;
      }
    }

    canvas.drawPath(path, paint);

    if (progress > 0) {
      double currentX = currentMaxX;
      double currentY = points[0].dy;
      
      for (int i = 1; i < points.length; i++) {
        if (currentX <= points[i].dx) {
          double prevX = points[i-1].dx;
          double prevY = points[i-1].dy;
          double nextX = points[i].dx;
          double nextY = points[i].dy;
          double ratio = (currentX - prevX) / (nextX - prevX);
          currentY = prevY + (nextY - prevY) * ratio;
          break;
        }
      }
      
      final dotPaint = Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, currentY), 4.5, dotPaint);

      final glowPaint = Paint()
        ..color = const Color(0xFF10B981).withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, currentY), 9.0, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SplashTrendPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
