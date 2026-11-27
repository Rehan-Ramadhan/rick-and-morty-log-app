import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'routing/app_routing.dart';

/// Root application widget configuring theme, AuthProvider, and named routing.
class RickMortyLogApp extends StatelessWidget {
  const RickMortyLogApp({
    super.key,
    this.authProvider,
  });

  final AuthProvider? authProvider;

  @override
  Widget build(BuildContext context) {
    final materialApp = MaterialApp(
      title: 'Rick & Morty Log',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouting.onGenerateRoute,
    );

    if (authProvider != null) {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider!,
        child: materialApp,
      );
    }

    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: materialApp,
    );
  }
}
