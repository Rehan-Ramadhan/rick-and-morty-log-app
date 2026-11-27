import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/register_page.dart';
import '../screens/explore/explore_detail_page.dart';
import '../screens/splash/splash_screen.dart';
import '../widgets/bottom_navigation.dart';

/// Centralized named route definitions and route argument parsing.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String exploreDetail = '/explore/detail';
  static const String collection = '/collection';
  static const String profile = '/profile';
}

class AppRouting {
  AppRouting._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case AppRoutes.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginPage(),
        );
      case AppRoutes.register:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterPage(),
        );
      case AppRoutes.home:
        final initialIndex = settings.arguments is int
            ? settings.arguments as int
            : 0;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MainNavigationShell(initialIndex: initialIndex),
        );
      case AppRoutes.explore:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainNavigationShell(initialIndex: 0),
        );
      case AppRoutes.collection:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainNavigationShell(initialIndex: 1),
        );
      case AppRoutes.profile:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainNavigationShell(initialIndex: 2),
        );
      case AppRoutes.exploreDetail:
        final args = settings.arguments;
        CharacterModel? character;
        int? characterId;
        if (args is CharacterModel) {
          character = args;
        } else if (args is int) {
          characterId = args;
        } else if (args is Map<String, dynamic>) {
          if (args['character'] is CharacterModel) {
            character = args['character'] as CharacterModel;
          } else if (args['id'] is int) {
            characterId = args['id'] as int;
          }
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ExploreDetailPage(
            character: character,
            characterId: characterId,
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
    }
  }
}
