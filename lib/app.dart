import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'routing/app_routing.dart';

/// Root application widget configuring theme, AuthProvider, and named routing.
class RickMortyLogApp extends StatelessWidget {
  const RickMortyLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Rick & Morty Log',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouting.onGenerateRoute,
      ),
    );
  }
}
