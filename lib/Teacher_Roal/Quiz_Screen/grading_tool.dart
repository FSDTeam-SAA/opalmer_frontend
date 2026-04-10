import 'package:flutter/material.dart';

class GradingToolScreen extends StatefulWidget {
  const GradingToolScreen({Key? key}) : super(key: key);

  @override
  State<GradingToolScreen> createState() => _GradingToolScreenState();
}

class _GradingToolScreenState extends State<GradingToolScreen> {
  bool _isDraftTab = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Tab Switcher
          const SizedBox(height: 24),
          _buildTabSwitcher(),
          
          // Grading List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: 10, // Mock data count
              itemBuilder: (context, index) {
                final isEven = index % 2 == 0;
                return _buildGradingItem(
                  title: isEven ? "Fractions and Decimals" : "Mean and Median",
                  questions: "10 Questions",
                  time: "5 min",
                  status: _isDraftTab ? "Draft" : "Published",
                  imageUrl: isEven 
                    ? "https://img.freepik.com/free-photo/view-planet-earth-from-space_23-2148705432.jpg"
                    : "https://img.freepik.com/free-photo/businessman-working-laptop-office_23-2148817045.jpg",
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Home_dashboard_header.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Grading Tool",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (!_isDraftTab)
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.filter_center_focus_outlined,
                color: Color(0xFF871DAD),
                size: 22,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0F0).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isDraftTab = true),
              child: Container(
                decoration: BoxDecoration(
                  color: _isDraftTab ? const Color(0xFF871DAD) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Draft",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isDraftTab ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isDraftTab = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !_isDraftTab ? const Color(0xFF871DAD) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Publish",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: !_isDraftTab ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingItem({
    required String title,
    required String questions,
    required String time,
    required String status,
    required String imageUrl,
  }) {
    final bool isDraft = status == "Draft";
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 76,
              height: 76,
              fit: BoxFit.cover,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$questions · $time",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDraft ? const Color(0xFFFFCC33).withOpacity(0.2) : const Color(0xFF4FA0F3).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDraft ? const Color(0xFFF39C12) : const Color(0xFF007AFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
