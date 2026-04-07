import 'package:flutter/material.dart';
import '../User_Roal_Screen/user_roal_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "text": "Growth",
      "image": "assets/images/onbording_background_image/onbording_background_image_1.jpg",
      "bgColor": const Color(0xFF9E92C4), // Fallback if the JPG doesn't cover
    },
    {
      "text": "Learning",
      "image": "assets/images/onbording_background_image/onbording_background_image_2.png",
      "bgColor": const Color(0xFF094988),
    },
    {
      "text": "Real Success",
      "image": "assets/images/onbording_background_image/onbording_background_image_3.png",
      "bgColor": const Color(0xFFFFBE02),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return Container(
                color: onboardingData[index]["bgColor"],
                child: Stack(
                  children: [
                    // Background Image
                    Positioned(
                      bottom: 250,
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Image.asset(
                        onboardingData[index]["image"]!,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    
                    // Rotated Text
                    Positioned(
                      top: 200,
                      right: -30,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          onboardingData[index]["text"]!,
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Top Logo
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/onbording_logo.png',
                width: 60,
                height: 60,
              ),
            ),
          ),
          
          // Bottom Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Empower Learning",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Manage classes, track progress, and stay\nconnected all in one powerful platform.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const UserRoleScreen(),
                            ),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF871DAD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == onboardingData.length - 1
                            ? "GET STARTED"
                            : "CONTINUE",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF871DAD) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
