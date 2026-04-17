import 'package:flutter/material.dart';

// --- Data Models for later API integration ---
class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime? date;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    this.date,
  });
}

class NotificationGroup {
  final String header;
  final List<NotificationItem> items;

  NotificationGroup({required this.header, required this.items});
}

// --- Reusable Notification Card Widget ---
class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                  notification.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
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

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Demo Data replacing the static widgets
  // Easily replaceable with a FutureBuilder or Riverpod fetching from an API
  final List<NotificationGroup> demoNotifications = [
    NotificationGroup(
      header: "Today",
      items: [
        NotificationItem(
          id: '1',
          title: "New Grades Posted",
          description: "Your grades for the recent quiz are now available.",
        ),
      ],
    ),
    NotificationGroup(
      header: "Yesterday",
      items: [
        NotificationItem(
          id: '2',
          title: "Upcoming Exam",
          description: "Your History exam is in 2 days. Time to revise!",
        ),
        NotificationItem(
          id: '3',
          title: "Today's Schedule is Ready",
          description: "Check your classes and assignments planned.",
        ),
        NotificationItem(
          id: '4',
          title: "New Grades Posted",
          description: "Your grades for the recent quiz are now available.",
        ),
      ],
    ),
    NotificationGroup(
      header: "1 June 2025",
      items: [
        NotificationItem(
          id: '5',
          title: "Upcoming Exam",
          description: "Your History exam is in 2 days. Time to revise!",
        ),
        NotificationItem(
          id: '6',
          title: "Today's Schedule is Ready",
          description: "Check your classes and assignments planned.",
        ),
      ],
    ),
    NotificationGroup(
      header: "25 May 2025",
      items: [
        NotificationItem(
          id: '7',
          title: "New Grades Posted",
          description: "Your grades for the recent quiz are now available.",
        ),
        NotificationItem(
          id: '8',
          title: "Upcoming Exam",
          description: "Your History exam is in 2 days. Time to revise!",
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
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

            // List of Notifications Built dynamically
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: demoNotifications.length,
                itemBuilder: (context, index) {
                  final group = demoNotifications[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 12,
                          left: 2,
                          top: index == 0 ? 0 : 12,
                        ),
                        child: Text(
                          group.header,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      ...group.items
                          .map((item) => NotificationCard(notification: item))
                          .toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
