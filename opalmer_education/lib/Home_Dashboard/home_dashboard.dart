import 'package:flutter/material.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}
class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _statsController;
  late AnimationController _quizController;
  late AnimationController _bellController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _bellShake;

  final List<AnimationController> _cardControllers = [];
  final List<Animation<double>> _cardFades = [];
  final List<Animation<Offset>> _cardSlides = [];

  final List<AnimationController> _quizCardControllers = [];
  final List<Animation<double>> _quizCardFades = [];
  final List<Animation<Offset>> _quizCardSlides = [];

  @override
  void initState() {
    super.initState();

    // Header animation
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
        );

    // Bell shake animation
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bellShake =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.08), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.08, end: -0.08), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -0.08, end: 0.08), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 0.08, end: -0.06), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -0.06, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _bellController, curve: Curves.easeInOut),
        );

    // Class stat cards staggered animation
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    for (int i = 0; i < 2; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      _cardControllers.add(controller);
      _cardFades.add(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
      _cardSlides.add(
        Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      );
    }

    // Quiz cards staggered animation
    _quizController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    for (int i = 0; i < 4; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      );
      _quizCardControllers.add(controller);
      _quizCardFades.add(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
      _quizCardSlides.add(
        Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      );
    }

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Header fades in
    _headerController.forward();

    // Bell shakes after header appears
    await Future.delayed(const Duration(milliseconds: 600));
    _bellController.forward();

    // Class cards slide in staggered
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      _cardControllers[i].forward();
    }

    // Quiz cards slide in staggered
    await Future.delayed(const Duration(milliseconds: 100));
    for (int i = 0; i < _quizCardControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _quizCardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
    _quizController.dispose();
    _bellController.dispose();
    for (final c in _cardControllers) {
      c.dispose();
    }
    for (final c in _quizCardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Stack(
              children: [
                Image.asset(
                  'assets/images/Home_dashboard_header.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Animated greeting text
                            FadeTransition(
                              opacity: _headerFade,
                              child: SlideTransition(
                                position: _headerSlide,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Hi, Olivia Carter 👋",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 0),
                                    Text(
                                      "Check your students activities",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            offset: const Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Animated bell shake
                            AnimatedBuilder(
                              animation: _bellShake,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _bellShake.value,
                                  child: child,
                                );
                              },
                              child: FadeTransition(
                                opacity: _headerFade,
                                child: Image.asset(
                                  'assets/images/home_dashboard/notification.png',
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Main Content Area (Shifted Up to overlap header) ──
            Transform.translate(
              offset: const Offset(0, -25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Class Stats Section ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Class Stats",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                        ),
                        Text(
                          "View All",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF871DAD),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Horizontal scrollable Class Stats cards
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        FadeTransition(
                          opacity: _cardFades[0],
                          child: SlideTransition(
                            position: _cardSlides[0],
                            child: _buildClassCard(
                              subject: "Grade 6 - Science",
                              days: "Mon, Wed",
                              students: "28 Students",
                              room: "6B",
                              attendance: "92%",
                              performance: "85%",
                              color: const Color(0xFF2E9B5B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        FadeTransition(
                          opacity: _cardFades[1],
                          child: SlideTransition(
                            position: _cardSlides[1],
                            child: _buildClassCard(
                              subject: "Grade 7 - Math",
                              days: "Tue, Thu",
                              students: "32 Students",
                              room: "7A",
                              attendance: "88%",
                              performance: "79%",
                              color: const Color(0xFFE8A317),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Quizzes Section ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Quizzes",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                        ),
                        Text(
                          "View All",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF871DAD),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quiz list items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        FadeTransition(
                          opacity: _quizCardFades[0],
                          child: SlideTransition(
                            position: _quizCardSlides[0],
                            child: _buildQuizCard(
                              title: "Fractions and Decimals",
                              questions: "10 Questions",
                              duration: "5 min",
                              status: "Draft",
                              statusColor: const Color(0xFFE8A317),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: _quizCardFades[1],
                          child: SlideTransition(
                            position: _quizCardSlides[1],
                            child: _buildQuizCard(
                              title: "Mean and Median",
                              questions: "10 Questions",
                              duration: "5 min",
                              status: "Published",
                              statusColor: const Color(0xFF2E9B5B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: _quizCardFades[2],
                          child: SlideTransition(
                            position: _quizCardSlides[2],
                            child: _buildQuizCard(
                              title: "Fractions and Decimals",
                              questions: "10 Questions",
                              duration: "5 min",
                              status: "Draft",
                              statusColor: const Color(0xFFE8A317),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: _quizCardFades[3],
                          child: SlideTransition(
                            position: _quizCardSlides[3],
                            child: _buildQuizCard(
                              title: "Fractions and Decimals",
                              questions: "10 Questions",
                              duration: "5 min",
                              status: "Draft",
                              statusColor: const Color(0xFFE8A317),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom nav
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard({
    required String subject,
    required String days,
    required String students,
    required String room,
    required String attendance,
    required String performance,
    required Color color,
  }) {
    return _PressableCard(
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  days,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.people_outline,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  students,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  room,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Attendance",
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      Text(
                        attendance,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Performance",
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      Text(
                        performance,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard({
    required String title,
    required String questions,
    required String duration,
    required String status,
    required Color statusColor,
  }) {
    return _PressableCard(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quiz thumbnail
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF4A3B8F),
              ),
              child: const Icon(
                Icons.quiz_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$questions · $duration",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium press/tap animation wrapper — scale down on press, bounce back on release
class _PressableCard extends StatefulWidget {
  final Widget child;
  const _PressableCard({required this.child});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
