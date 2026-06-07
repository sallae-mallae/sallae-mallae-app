import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sallae_mallae_app/app/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SallaeMallaeApp()));

    expect(find.byType(SallaeMallaeApp), findsOneWidget);
  });
}
