import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header       cust
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF871DAD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Notification",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                ],
              ),
            ),
            
            // List of Notifications
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildDateHeader("Today"),
                  _buildNotificationCard(
                    title: "New Grades Posted",
                    description: "Your grades for the recent quiz are now available.",
                  ),
                  
                  const SizedBox(height: 24),
                  _buildDateHeader("Yesterday"),
                  _buildNotificationCard(
                    title: "Upcoming Exam",
                    description: "Your History exam is in 2 days. Time to revise!",
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationCard(
                    title: "Today's Schedule is Ready",
                    description: "Check your classes and assignments planned.",
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationCard(
                    title: "New Grades Posted",
                    description: "Your grades for the recent quiz are now available.",
                  ),

                  const SizedBox(height: 24),
                  _buildDateHeader("1 June 2025"),
                  _buildNotificationCard(
                    title: "Upcoming Exam",
                    description: "Your History exam is in 2 days. Time to revise!",
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationCard(
                    title: "Today's Schedule is Ready",
                    description: "Check your classes and assignments planned.",
                  ),

                  const SizedBox(height: 24),
                  _buildDateHeader("25 May 2025"),
                  _buildNotificationCard(
                    title: "New Grades Posted",
                    description: "Your grades for the recent quiz are now available.",
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationCard(
                    title: "Upcoming Exam",
                    description: "Your History exam is in 2 days. Time to revise!",
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 2),
      child: Text(
        date,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildNotificationCard({required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF871DAD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
