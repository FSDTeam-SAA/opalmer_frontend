import 'dart:async';
import '../core/widgets/brand_logo.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/services/secure_storage_service.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import '../onboarding_screen/onboarding_screen.dart';
import '../parent_role/parent_main_shell.dart';
import '../student_role/student_main_shell.dart';
import '../custom_bottom_navigation_bar/main_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navigationTimer;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation: logo zooms in from small
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Fade animation: logo fades in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Pulse animation: gentle breathing effect after entry
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start entry animations
    _fadeController.forward();
    _scaleController.forward();

    // Navigate after 3 seconds, evaluating persistent login state
    _navigationTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final storage = SecureStorageService();
      final token = await storage.getToken();
      final userDataStr = await storage.getUserData();

      if (token != null && userDataStr != null && mounted) {
        try {
          final userData = jsonDecode(userDataStr);

          // Populate the authStateProvider so other screens know the user is logged in
          final user = UserModel.fromJson(userData);
          ref.read(authStateProvider.notifier).state = user;

          final roleType = userData['type'];

          Widget targetScreen;
          if (roleType == 'parent') {
            targetScreen = const ParentMainShell();
          } else if (roleType == 'student') {
            targetScreen = const StudentMainShell();
          } else if (roleType == 'teacher') {
            targetScreen = const MainShell();
          } else {
            targetScreen = const OnboardingScreen();
          }

          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => targetScreen));
        } catch (_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
        }
      } else if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _scaleController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    child: BrandLogo(
                      size: MediaQuery.sizeOf(context).height * 0.55,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
