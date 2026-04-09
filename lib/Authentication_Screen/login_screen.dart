import 'package:flutter/material.dart';
import 'package:opalmer_education/Custom_Bottom_Navigation_Bar/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _schoolIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _formController;
  late AnimationController _imageController;
  late AnimationController _buttonController;

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
  late Animation<double> _buttonScale;

  bool _isButtonPressed = false;

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

    // Button controller
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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

    // Button press scale
    _buttonScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
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

  Future<void> _onButtonTap() async {
    setState(() => _isButtonPressed = true);
    await _buttonController.forward();
    await _buttonController.reverse();
    setState(() => _isButtonPressed = false);
    // Navigate to main dashboard
    if (mounted) {
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
    _buttonController.dispose();
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
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
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
                                color: Colors.white.withOpacity(0.9),
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
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: _schoolIdController,
                              decoration: InputDecoration(
                                hintText: "Enter your school ID",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.check_box_outlined,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                                suffixIcon: const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF871DAD),
                                  size: 22,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
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
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
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
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
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
                              activeColor: const Color(0xFF871DAD),
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
                              color: Color(0xFF666666),
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
                      child: ScaleTransition(
                        scale: _buttonScale,
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _onButtonTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF871DAD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "LOG IN NOW",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
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
