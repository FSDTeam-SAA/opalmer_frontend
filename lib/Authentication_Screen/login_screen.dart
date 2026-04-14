import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/authentication_screen/otp_screen.dart';
import 'package:opalmer_education/core/providers/role_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/core/widgets/primary_button.dart';
import 'package:opalmer_education/custom_bottom_navigation_bar/main_shell.dart';
import 'package:opalmer_education/parent_role/parent_main_shell.dart';
import 'package:opalmer_education/student_role/student_main_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool isRegistrationFlow;

  const LoginScreen({super.key, this.isRegistrationFlow = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _schoolIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _formController;
  late AnimationController _imageController;

  // Header animations
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerFade;

  // Image animation
  late Animation<double> _imageScale;
  late Animation<double> _imageFade;

  // Form field animations
  late Animation<Offset> _schoolIdSlide;
  late Animation<double> _schoolIdFade;
  late Animation<Offset> _passwordSlide;
  late Animation<double> _passwordFade;
  late Animation<Offset> _rememberSlide;
  late Animation<double> _rememberFade;

  // Button animation
  late Animation<Offset> _buttonSlide;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    // Header controller (fast)
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Image controller
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Form controller (staggered)
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Header: slide down + fade
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
        );

    _headerFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeIn));

    // Image: scale up + fade
    _imageScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.elasticOut),
    );
    _imageFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _imageController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // School ID field: slide up + fade (0% – 45%)
    _schoolIdSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formController,
            curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
          ),
        );
    _schoolIdFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    // Password field: slide up + fade (25% – 70%)
    _passwordSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formController,
            curve: const Interval(0.25, 0.70, curve: Curves.easeOut),
          ),
        );
    _passwordFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.25, 0.70, curve: Curves.easeIn),
      ),
    );

    // Remember me: slide + fade (50% – 85%)
    _rememberSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formController,
            curve: const Interval(0.50, 0.85, curve: Curves.easeOut),
          ),
        );
    _rememberFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.50, 0.85, curve: Curves.easeIn),
      ),
    );

    // Button: slide + fade (70% – 100%)
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _formController,
            curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
          ),
        );
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animations in sequence
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _imageController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _formController.forward();
  }

  void _onButtonTap() {
    if (widget.isRegistrationFlow) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const OtpScreen(isRegistrationFlow: true),
        ),
      );
      return;
    }

    _routeToDashboard(ref.read(roleProvider));
  }

  void _routeToDashboard(UserRole role) {
    if (role == UserRole.parent) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ParentMainShell()),
        (route) => false,
      );
    } else if (role == UserRole.student) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StudentMainShell()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _schoolIdController.dispose();
    _passwordController.dispose();
    _headerController.dispose();
    _imageController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header with background image ──
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: Stack(
                  children: [
                    // Header background image
                    Image.asset(
                      'assets/images/header_design.png',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),

                    // Title & Subtitle over header
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            // Top row: Title + Back button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                // Back button
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Experience a better learning\nenvironment",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Login Illustration ──
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: FadeTransition(
                  opacity: _imageFade,
                  child: ScaleTransition(
                    scale: _imageScale,
                    child: Image.asset(
                      'assets/images/Login_images/login_image.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // ── Form Fields ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // School ID Label + Field
                  FadeTransition(
                    opacity: _schoolIdFade,
                    child: SlideTransition(
                      position: _schoolIdSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "School ID",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _schoolIdController,
                            decoration: InputDecoration(
                              hintText: "Enter your school ID",
                              prefixIcon: Icon(
                                Icons.check_box_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              suffixIcon: const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryMid,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password Label + Field
                  FadeTransition(
                    opacity: _passwordFade,
                    child: SlideTransition(
                      position: _passwordSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: "Password",
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade400,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Remember Me
                  FadeTransition(
                    opacity: _rememberFade,
                    child: SlideTransition(
                      position: _rememberSlide,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (val) {
                                setState(() {
                                  _rememberMe = val ?? false;
                                });
                              },
                              activeColor: AppColors.primaryMid,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Remember Me",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // LOG IN NOW Button
                  FadeTransition(
                    opacity: _buttonFade,
                    child: SlideTransition(
                      position: _buttonSlide,
                      child: PrimaryButton(
                        text: "LOG IN NOW",
                        onPressed: _onButtonTap,
                        isGradient:
                            false, // Login screen used solid purple in my original check
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
