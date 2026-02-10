import 'package:flutter/material.dart';
import 'package:job_portal_app/core/theme/app_theme.dart';
import 'package:job_portal_app/core/theme/dark_theme.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/routes/app_router.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..tryAutoLogin(),
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Portal',
      theme: AppTheme.lightTheme,
      darkTheme: getDarkTheme(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRouter.generateRoute,
      navigatorKey: NavigationService.navigatorKey,
    );
  }

}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}