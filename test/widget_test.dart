import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stock_market_game_app/main.dart';
import 'package:stock_market_game_app/providers/app_state_provider.dart';
import 'package:stock_market_game_app/screens/splash_screen.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    final provider = AppStateProvider();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MyApp(),
      ),
    );

    // Verify that the SplashScreen is rendered.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Let the navigation timers settle and navigate
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Dispose the provider to clean up any pending price simulation timers
    provider.dispose();
  });
}
