import 'package:flutter_test/flutter_test.dart';
import 'package:finder/main.dart';

void main() {
  testWidgets('Spotzy app renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FinderApp());

    // Verify the app title is displayed
    expect(find.text('Spotzy'), findsOneWidget);

    // Verify the subtitle is displayed
    expect(find.text('Discover what matters'), findsOneWidget);

    // Verify search bar is present
    expect(find.text('Search anything...'), findsOneWidget);

    // Verify bottom navigation items
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
