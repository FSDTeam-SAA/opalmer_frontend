import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ScanDocumentScreen extends StatefulWidget {
  const ScanDocumentScreen({Key? key}) : super(key: key);

  @override
  State<ScanDocumentScreen> createState() => _ScanDocumentScreenState();
}

class _ScanDocumentScreenState extends State<ScanDocumentScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isInit = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _setCamera(_selectedCameraIndex);
      } else {
        debugPrint("No cameras available.");
      }
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  void _setCamera(int index) async {
    final camera = cameras![index];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    
    await _controller!.initialize();
    
    if (mounted) {
      setState(() {
        _isInit = true;
      });
    }
  }

  void _switchCamera() async {
    if (cameras == null || cameras!.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras!.length;
    setState(() {
      _isInit = false;
    });
    _setCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "Scan Document",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera feed Background
                    if (_isInit && _controller != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CameraPreview(_controller!),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFF871DAD)),
                        ),
                      ),
                      
                    // Custom Scanner Overlay
                    CustomPaint(
                      painter: ScannerOverlayPainter(
                        color: const Color(0xFF871DAD),
                        cornerLength: 30,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              height: 140, // Tall bottom section
              padding: const EdgeInsets.only(bottom: 20), // Compensate for safe area manually
              decoration: const BoxDecoration(
                color: Color(0xFF871DAD),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      // Gallery Action
                    },
                    icon: const Icon(Icons.insert_photo_outlined, color: Colors.white, size: 30),
                  ),
                  
                  GestureDetector(
                    onTap: () async {
                      if (_controller != null && _controller!.value.isInitialized) {
                        try {
                          final image = await _controller!.takePicture();
                          debugPrint("Image captured: ${image.path}");
                          // Handle image review or upload
                        } catch (e) {
                          debugPrint("Error taking picture: $e");
                        }
                      }
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  IconButton(
                    onPressed: _switchCamera,
                    icon: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  ScannerOverlayPainter({
    required this.color,
    this.cornerLength = 30.0,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-Left corner
    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerLength), paint);

    // Top-Right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left corner
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);

    // Bottom-Right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
