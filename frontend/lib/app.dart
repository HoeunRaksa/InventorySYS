import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/app_theme.dart';
import 'package:frontend/config/app_routes.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/products/presentation/screens/product_list_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/core/localization/locale_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Inventory Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('km'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const ProductListScreen();
          }
          return const LoginScreen();
        },
      ),
      routes: AppRoutes.routes,
    );
  }
}
