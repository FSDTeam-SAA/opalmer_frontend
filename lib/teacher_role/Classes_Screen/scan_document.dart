import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanDocumentScreen extends StatefulWidget {
  const ScanDocumentScreen({super.key});

  @override
  State<ScanDocumentScreen> createState() => _ScanDocumentScreenState();
}

class _ScanDocumentScreenState extends State<ScanDocumentScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCameras() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _startCamera(0);
    }
  }

  Future<void> _startCamera(int index) async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    
    _controller = CameraController(_cameras[index], ResolutionPreset.high, enableAudio: false);
    
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _cameraIndex = index;
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _onCapture() async {
    if (!_isCameraInitialized || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final image = await _controller!.takePicture();
      await _processImage(image.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Capture failed: $e")));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onGallery() async {
    if (_isProcessing) return;
    
    debugPrint("ScanDoc: _onGallery using FilePicker.custom to avoid PHPicker hang");
    
    // 1. Fully release camera hardware
    setState(() => _isCameraInitialized = false);
    await _controller?.dispose();
    _controller = null;

    // 2. Short safety delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Use custom extensions to FORCE iOS to use the Files Browser (stable)
      // instead of the Photos Picker (unstable on simulator)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'heic'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _processImage(result.files.single.path!);
      }
    } catch (e) {
      debugPrint("ScanDoc: Picker error: $e");
    } finally {
      // 3. Re-init camera after picker closes
      _initCameras();
    }
  }

  Future<void> _processImage(String path) async {
    if (!mounted) return;
    setState(() => _isProcessing = true);
    
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(path);
      final recognizedText = await textRecognizer.processImage(inputImage);
      if (mounted) {
        _showResultSheet(path, recognizedText.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OCR failed: $e")));
      }
    } finally {
      textRecognizer.close();
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showResultSheet(String path, String text) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Scan Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(path), height: 150, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(child: SelectableText(text.isEmpty ? "No text detected." : text)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF871DAD))),
                    child: const Text("COPY", style: TextStyle(color: Color(0xFF871DAD))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF871DAD)),
                    child: const Text("DONE", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF871DAD)),
        ),
        title: const Text("Scan Document", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _isCameraInitialized && _controller != null
                        ? CameraPreview(_controller!)
                        : Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
                  ),
                  if (_isProcessing) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(color: Color(0xFF871DAD), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed: _onGallery, icon: const Icon(Icons.photo_library, color: Colors.white, size: 30)),
                GestureDetector(
                  onTap: _onCapture,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                    child: Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  ),
                ),
                IconButton(
                  onPressed: () => _startCamera((_cameraIndex + 1) % _cameras.length),
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
