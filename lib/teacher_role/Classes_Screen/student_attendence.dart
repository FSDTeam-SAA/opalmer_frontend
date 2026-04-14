import 'package:flutter/material.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Attendance",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Table Area ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
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
                              width: 90,
                              child: Row(
                                children: const [
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "Students Name",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 80,
                              child: Text(
                                "Status",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table Body
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(top: 8, bottom: 20),
                          children: [
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.absent,
                            ),
                            _buildRow("06-03-25", "Mia Johnson", _Status.tardy),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.absent,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                            _buildRow(
                              "06-03-25",
                              "Mia Johnson",
                              _Status.present,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String date, String name, _Status status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              date,
              style: const TextStyle(color: Color(0xFF444444), fontSize: 13),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                name,
                style: const TextStyle(color: Color(0xFF444444), fontSize: 14),
              ),
            ),
          ),
          SizedBox(width: 86, child: _buildStatusDropdown(status)),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(_Status status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case _Status.present:
        bgColor = const Color(0xFFCBEAD7);
        textColor = const Color(0xFF388D5E);
        text = "Present";
        break;
      case _Status.absent:
        bgColor = const Color(0xFFF7CFD1); // Light pink
        textColor = const Color(0xFFC04345); // Dark red
        text = "Absent";
        break;
      case _Status.tardy:
        bgColor = const Color(0xFFCFE1EB); // Light blue
        textColor = const Color(0xFF4C7B90); // Dark grayish blue
        text = "Tardy";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: textColor, size: 16),
        ],
      ),
    );
  }
}

enum _Status { present, absent, tardy }
