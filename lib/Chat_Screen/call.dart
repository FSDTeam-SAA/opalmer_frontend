import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final String imageUrl;

  const CallScreen({
    Key? key,
    required this.name,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, color: Colors.white70, size: 14),
                const SizedBox(width: 8),
                const Text(
                  "End-to-end encrypted",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "02.32",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const Spacer(flex: 2),
            
            // Central Avatar
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 8),
              ),
              child: ClipOval(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const Spacer(flex: 3),
            
            // Bottom Controls
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildControlIconAsset('assets/images/call/message.png'),
                  _buildControlIconAsset('assets/images/call/volume.png'),
                  _buildControlIconAsset('assets/images/call/mute_unmute.png'),
                  _buildEndCallButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlIconAsset(String assetPath) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFF444444), // Darker charcoal grey
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(assetPath, width: 24, height: 24, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildEndCallButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFFEA4335), // Red background
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset('assets/images/call/end_call.png', width: 28, height: 28, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
