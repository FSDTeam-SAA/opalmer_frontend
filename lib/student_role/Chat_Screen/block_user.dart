import 'package:flutter/material.dart';

class BlockUserScreen extends StatefulWidget {
  final String userName;

  const BlockUserScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<BlockUserScreen> createState() => _BlockUserScreenState();
}

class _BlockUserScreenState extends State<BlockUserScreen> {
  String _selectedReason = "Other";
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF871DAD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        title: const Text(
          "Block",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "The ${widget.userName} will not be able to message or call you anymore.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text(
              "Reason For Blocking",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
            ),
            const SizedBox(height: 16),
            _buildRadioOption("Harassment"),
            _buildRadioOption("Spam"),
            _buildRadioOption("Mis-Tagged Items"),
            _buildRadioOption("Other"),
            const SizedBox(height: 32),
            const Text(
              "Reason( Optional)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _reasonController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Additional Information",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF871DAD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  "BLOCK",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    bool isSelected = _selectedReason == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = title),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF871DAD), width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(color: Color(0xFF871DAD), shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
