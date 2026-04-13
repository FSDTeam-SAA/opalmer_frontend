import 'package:flutter/material.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildTableHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                children: [
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Absent"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "left classroom"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Absent"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                  _buildAttendanceRow("06-03-25", "Mia Johnson", "Present"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryMid,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
      title: const Text(
        "Attendance",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFEBD43),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Row(
              children: const [
                Text(
                  "Date",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(width: 4),
                Icon(Icons.calendar_month_outlined, color: Colors.white, size: 14),
              ],
            ),
          ),
          const Expanded(
            child: Text(
              "Students Name",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(
            width: 90,
            child: Text(
              "Status",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(String date, String name, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              date,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 90,
            child: Center(child: _buildStatusBadge(status)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case "present":
        bgColor = const Color(0xFFCBEAD7);
        textColor = const Color(0xFF388D5E);
        break;
      case "absent":
        bgColor = const Color(0xFFF7CFD1);
        textColor = const Color(0xFFC04345);
        break;
      default: // left classroom
        bgColor = const Color(0xFFCFE1EB);
        textColor = const Color(0xFF4C7B90);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
