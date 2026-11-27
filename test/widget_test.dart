import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_log_app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'RickMortyLogApp renders splash screen and routes to login without token',
    (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const RickMortyLogApp());
      expect(find.text('RICK & MORTY LOG'), findsOneWidget);

      // Advance past the two splash Future.delayed calls and microtasks.
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Portal Access'), findsOneWidget);
    },
  );
}
