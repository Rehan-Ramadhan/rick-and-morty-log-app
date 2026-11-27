import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_log_app/app.dart';
import 'package:rick_morty_log_app/models/user_model.dart';
import 'package:rick_morty_log_app/providers/auth_provider.dart';
import 'package:rick_morty_log_app/services/api_service.dart';
import 'package:rick_morty_log_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthService extends AuthService {
  _FakeAuthService({required this.onFetchUser});

  final Future<UserModel> Function() onFetchUser;
  int fetchCalls = 0;

  @override
  Future<UserModel> fetchCurrentUser() {
    fetchCalls++;
    return onFetchUser();
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ApiService.instance.clearToken();
  });

  testWidgets(
    'SplashScreen routes directly to LoginPage when no token exists (without calling GET /user)',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final fakeAuth = _FakeAuthService(
        onFetchUser: () async => const UserModel(
          id: 1,
          name: 'Rick Sanchez',
          email: 'rick@citadel.org',
        ),
      );
      final provider = AuthProvider(authService: fakeAuth);

      await tester.pumpWidget(RickMortyLogApp(authProvider: provider));
      expect(find.text('RICK & MORTY LOG'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeAuth.fetchCalls, 0);
      expect(find.text('Portal Access'), findsOneWidget);
    },
  );

  testWidgets(
    'SplashScreen validates token via GET /user and routes to MainNavigationShell when valid',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'sanctum_auth_token': 'valid-sanctum-token',
      });
      final fakeAuth = _FakeAuthService(
        onFetchUser: () async => const UserModel(
          id: 1,
          name: 'Rick Sanchez',
          email: 'rick@citadel.org',
        ),
      );
      final provider = AuthProvider(authService: fakeAuth);

      await tester.pumpWidget(RickMortyLogApp(authProvider: provider));
      expect(find.text('RICK & MORTY LOG'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump(const Duration(milliseconds: 300));

      // SplashScreen triggers 1 GET /user check; MainNavigationShell also mounts ProfileAboutPage.
      expect(fakeAuth.fetchCalls, greaterThanOrEqualTo(1));
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.user?.name, 'Rick Sanchez');
      expect(find.text('Explore Multiverse'), findsOneWidget);
    },
  );

  testWidgets(
    'SplashScreen clears invalid 401 token and routes to LoginPage with message',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'sanctum_auth_token': 'expired-sanctum-token',
      });
      final fakeAuth = _FakeAuthService(
        onFetchUser: () async => throw ApiException(
          'Unauthenticated.',
          statusCode: 401,
        ),
      );
      final provider = AuthProvider(authService: fakeAuth);

      await tester.pumpWidget(RickMortyLogApp(authProvider: provider));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 550));
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeAuth.fetchCalls, 1);
      expect(await ApiService.instance.getToken(), isNull);
      expect(find.text('Portal Access'), findsOneWidget);
      expect(
        find.text(
          'Your session has expired or is invalid. Please sign in again.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'SplashScreen keeps token and shows retry UI on network error',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'sanctum_auth_token': 'offline-valid-token',
      });
      final fakeAuth = _FakeAuthService(
        onFetchUser: () async => throw ApiException(
          'Unable to reach server. Make sure backend & internet are active.',
        ),
      );
      final provider = AuthProvider(authService: fakeAuth);

      await tester.pumpWidget(RickMortyLogApp(authProvider: provider));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeAuth.fetchCalls, 1);
      expect(await ApiService.instance.getToken(), 'offline-valid-token');
      expect(find.text('RETRY CONNECTION'), findsOneWidget);
      expect(find.text('GO TO LOGIN'), findsOneWidget);
      expect(find.text('Explore Multiverse'), findsNothing);
    },
  );
}
