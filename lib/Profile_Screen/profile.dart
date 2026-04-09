import 'package:flutter/material.dart';
import 'profile_setup.dart';
import 'notification_setting.dart';
import 'about_us.dart';
import 'terms_condition.dart';
import 'disput_center.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Image and Avatar
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Header Background
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/Home_dashboard_header.png',
                        fit: BoxFit.cover,
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Profile",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none_outlined,
                                  color: Color(0xFF871DAD),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Avatar Picture
                Positioned(
                  top: 130, // Positioning to overlap the header boundary
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/profile /olivia.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Name and Email
            const SizedBox(height: 60), // Spacer for the overlapping avatar
            const Text(
              "Olivia Carter",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "oliviacarter@gmail.com",
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 32),

            // Menu Items List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuTile(
                    "Edit Profile",
                    Icons.person_outline,
                    const ProfileSetupScreen(),
                  ),
                  _buildMenuTile(
                    "Notifications Settings",
                    Icons.notifications_none_outlined,
                    const NotificationSettingScreen(),
                  ),
                  _buildMenuTile("Block list", Icons.block_outlined),
                  _buildMenuTile(
                    "Two-Factor Authentication",
                    Icons.verified_user_outlined,
                  ),
                  _buildMenuTile("Language", Icons.language_outlined),
                  _buildMenuTile("About Us", Icons.help_outline, const AboutUsScreen()),
                  _buildMenuTile(
                    "Terms and Conditions",
                    Icons.description_outlined,
                    const TermsConditionScreen(),
                  ),
                  _buildMenuTile("Dispute Center", Icons.chat_outlined, const DisputCenterScreen()),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 40),
                    child: InkWell(
                      onTap: () {
                        // Logout action
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.logout,
                              color: Color(0xFFFF6B6B),
                              size: 24,
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFF6B6B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60), // Padding for the bottom nav bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, [Widget? destination]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: const Color(0xFF444444), size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF444444),
          size: 16,
        ),
        onTap: () {
          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => destination),
            );
          }
        },
      ),
    );
  }
}
