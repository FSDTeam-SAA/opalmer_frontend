import 'package:flutter/material.dart';
import 'package:opalmer_education/authentication_screen/registration_successful_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isRegistrationFlow;

  const ProfileSetupScreen({super.key, this.isRegistrationFlow = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String _selectedSubject = 'Math';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Header Area
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Wavy Header Background
                SizedBox(
                  width: double.infinity,
                  height: 350,
                  child: Image.asset(
                    'assets/images/header_design.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback just in case standard header color is needed
                      return Container(color: const Color(0xFF871DAD));
                    },
                  ),
                ),

                // Safe Area content for the top part
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Profile Setup",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF871DAD),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Complete your profile to connect with\nyour students and school.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Avatar
                Positioned(
                  top: 260,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF871DAD),
                              width: 3,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.asset(
                              'assets/images/profile/olivia.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF871DAD),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60), // Spacer below avatar

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Name"),
                  _buildTextField("Enter your name", Icons.person_outline),

                  const SizedBox(height: 20),
                  _buildLabel("Contact Number"),
                  _buildTextField(
                    "Enter your phone number",
                    Icons.phone_outlined,
                  ),

                  const SizedBox(height: 20),
                  _buildLabel("Grade Level"),
                  _buildDropdown("Select your grade level"),

                  const SizedBox(height: 20),
                  _buildLabel("State"),
                  _buildDropdown("Select your state"),

                  const SizedBox(height: 28),
                  const Text(
                    "Subjects",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildSubjectChip("Math"),
                      _buildSubjectChip("Science"),
                      _buildSubjectChip("Reading"),
                      _buildSubjectChip("History"),
                      _buildSubjectChip("Social Studies"),
                    ],
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.isRegistrationFlow) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RegistrationSuccessfulScreen(),
                            ),
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF871DAD),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "SAVE CHANGES",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, color: Color(0xFF444444)),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB485D6)), // Purple-ish border
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Icon(icon, color: Colors.grey.shade600, size: 20),
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade300),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              hint,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildSubjectChip(String label) {
    bool isSelected = _selectedSubject == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubject = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF871DAD) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF444444),
          ),
        ),
      ),
    );
  }
}
