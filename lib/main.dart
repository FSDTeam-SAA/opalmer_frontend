import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat/widgets/app_call_listener.dart';
import 'core/navigation/app_navigator.dart';
import 'core/navigation/role_navigation.dart';
import 'splash_screen/splash_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.statusBarStyle);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      navigatorObservers: [roleNavigation],
      title: 'AchieverPlus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.statusBarStyle,
          child: AppCallListener(child: child ?? const SizedBox.shrink()),
        );
      },
      home: const SplashScreen(),
    );
  }
}
