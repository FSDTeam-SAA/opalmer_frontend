import 'package:flutter/material.dart';

class UserRoleScreen extends StatefulWidget {
  const UserRoleScreen({Key? key}) : super(key: key);

  @override
  State<UserRoleScreen> createState() => _UserRoleScreenState();
}

class _UserRoleScreenState extends State<UserRoleScreen> {
  String selectedRole = 'Teacher';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white background
      body: Stack(
        children: [
          // Background Waves
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: CustomPaint(
                painter: _WavePainter(),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // Header Texts
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Account Type",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Choose your role to access the right\nfeatures.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                
                const SizedBox(height: 80),
                
                // Role Items
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildRoleCard(
                          role: "Teacher",
                          emoji: "👩‍🏫",
                        ),
                        const SizedBox(height: 16),
                        _buildRoleCard(
                          role: "Parent",
                          emoji: "👨‍👩‍👧",
                        ),
                        const SizedBox(height: 16),
                        _buildRoleCard(
                          role: "Student",
                          emoji: "👨‍🎓",
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // User proceeds to next step
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF871DAD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // less rounded than onboarding
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "CONTINUE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({required String role, required String emoji}) {
    bool isSelected = selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isSelected ? const Color(0xFF871DAD) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFEBE0F5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 20),
            // Role Text
            Expanded(
              child: Text(
                role,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            // Checkmark
            if (isSelected)
              const Icon(
                Icons.check,
                color: Color(0xFF871DAD),
                size: 32,
              )
            else
              const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for the purple waves
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 3 overlapping waves with different opacity
    final paint1 = Paint()
      ..color = const Color(0xFF871DAD).withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    final paint2 = Paint()
      ..color = const Color(0xFF871DAD).withOpacity(0.6)
      ..style = PaintingStyle.fill;
      
    final paint3 = Paint()
      ..color = const Color(0xFF871DAD)
      ..style = PaintingStyle.fill;

    // Draw bottom most wave (lightest)
    var path1 = Path();
    path1.lineTo(0, size.height * 0.8);
    path1.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height * 0.85);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.7, size.width, size.height * 0.9);
    path1.lineTo(size.width, 0);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Draw middle wave
    var path2 = Path();
    path2.lineTo(0, size.height * 0.6);
    path2.quadraticBezierTo(size.width * 0.2, size.height * 0.8, size.width * 0.5, size.height * 0.75);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.7, size.width, size.height * 0.6);
    path2.lineTo(size.width, 0);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Draw top most wave (darkest)
    var path3 = Path();
    path3.lineTo(0, size.height * 0.7);
    path3.quadraticBezierTo(size.width * 0.25, size.height * 0.9, size.width * 0.5, size.height * 0.65);
    path3.quadraticBezierTo(size.width * 0.75, size.height * 0.4, size.width, size.height * 0.5);
    path3.lineTo(size.width, 0);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
