import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:one_and_done_breath/main.dart';

/// Walks Home → Session → Settings on a real device/simulator and captures
/// a screenshot of each — build order step 5. Run with:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/screens_test.dart -d `<device>`
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Staggered entrances run on wall-clock timers; give them time to land.
  Future<void> settle(WidgetTester tester, {int frames = 8}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets('home, session, settings render', (tester) async {
    await tester.pumpWidget(const OneAndDoneBreathApp());
    // The aurora backdrop animates forever, so pumpAndSettle would never
    // return — pump fixed durations instead.
    await settle(tester);
    await binding.convertFlutterSurfaceToImage();
    await settle(tester, frames: 2);
    await binding.takeScreenshot('home');

    await tester.tap(find.text('Begin'));
    await settle(tester);
    expect(find.text('Breathe in'), findsOneWidget);
    await binding.takeScreenshot('session');

    await tester.tap(find.text('Pause'));
    await settle(tester, frames: 3);
    expect(find.text('Resume'), findsOneWidget);
    await binding.takeScreenshot('session_paused');

    await tester.tap(find.byTooltip('End session'));
    await settle(tester, frames: 4);
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    expect(find.text('One purchase, nothing else'), findsOneWidget);
    await binding.takeScreenshot('settings');
  });
}
