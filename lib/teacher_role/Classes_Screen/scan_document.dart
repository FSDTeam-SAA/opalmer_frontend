import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ocr_result_screen.dart';

class ScanDocumentScreen extends StatefulWidget {
  final Future<List<CameraDescription>> Function()? loadCameras;
  const ScanDocumentScreen({super.key, this.loadCameras});

  @override
  State<ScanDocumentScreen> createState() => _ScanDocumentScreenState();
}

class _ScanDocumentScreenState extends State<ScanDocumentScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _initializingCamera = false;
  bool _pickingImage = false;
  String? _cameraError;
  int _cameraGeneration = 0;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraGeneration++;
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      unawaited(_releaseCamera());
    } else if (state == AppLifecycleState.resumed) {
      _resumeCamera();
    }
  }

  Future<void> _releaseCamera() async {
    _cameraGeneration++;
    final controller = _controller;
    _controller = null;
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
        _initializingCamera = false;
      });
    }
    await controller?.dispose();
  }

  void _resumeCamera() {
    if (mounted &&
        !_isProcessing &&
        !_pickingImage &&
        (ModalRoute.of(context)?.isCurrent ?? true)) {
      unawaited(_initializeCamera(_cameraIndex));
    }
  }

  Future<void> _initializeCamera([int index = 0]) async {
    if (!mounted || _initializingCamera || _isProcessing || _pickingImage) {
      return;
    }
    final generation = ++_cameraGeneration;
    final old = _controller;
    _controller = null;
    setState(() {
      _initializingCamera = true;
      _isCameraInitialized = false;
      _cameraError = null;
    });
    CameraController? candidate;
    try {
      await old?.dispose();
      final cameras = await (widget.loadCameras ?? availableCameras)();
      if (!mounted || generation != _cameraGeneration) return;
      _cameras = cameras;
      if (cameras.isEmpty) {
        setState(
          () => _cameraError = 'No camera available. Choose an image to scan.',
        );
        return;
      }
      final selected = index.clamp(0, cameras.length - 1);
      candidate = CameraController(
        cameras[selected],
        ResolutionPreset.high,
        enableAudio: false,
      );
      _controller = candidate;
      await candidate.initialize();
      if (!mounted || generation != _cameraGeneration) {
        await candidate.dispose();
        return;
      }
      setState(() {
        _cameraIndex = selected;
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint("Camera Error: $e");
      if (mounted && generation == _cameraGeneration) {
        _controller = null;
        await candidate?.dispose();
        if (!mounted || generation != _cameraGeneration) return;
        setState(
          () => _cameraError = e is CameraException && e.code.contains('Access')
              ? 'Camera access is unavailable. You can choose an image instead.'
              : 'Unable to start the camera. Retry or choose an image.',
        );
      }
    } finally {
      if (mounted && generation == _cameraGeneration) {
        setState(() => _initializingCamera = false);
      }
    }
  }

  Future<void> _onCapture() async {
    if (!_isCameraInitialized || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final image = await _controller!.takePicture();
      await _releaseCamera();
      await _processImage(image.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to capture the image. Please retry.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
      _resumeCamera();
    }
  }

  Future<void> _onGallery() async {
    if (_isProcessing || _pickingImage) return;
    setState(() => _pickingImage = true);
    try {
      await _releaseCamera();
      if (!mounted) return;
      // Use custom extensions to force iOS to use the Files Browser.
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open the image. Please retry.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingImage = false);
      _resumeCamera();
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
        final text = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OCRResultScreen(imagePath: path, text: recognizedText.text),
          ),
        );
        if (text != null && mounted) Navigator.pop(context, text);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to read this image. Try a clearer photo.'),
          ),
        );
      }
    } finally {
      await textRecognizer.close();
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [const AppHomeButton()],
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF871DAD)),
        ),
        title: const Text(
          "Scan Document",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
                        : Container(
                            color: Colors.black,
                            child: Center(
                              child: _cameraError == null
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _cameraError!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextButton(
                                            onPressed: () =>
                                                _initializeCamera(_cameraIndex),
                                            child: const Text(
                                              'Retry camera',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                  ),
                  if (_isProcessing)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF871DAD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: 'Choose image',
                  onPressed: _isProcessing || _pickingImage ? null : _onGallery,
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                IconButton(
                  tooltip: 'Capture document',
                  onPressed:
                      _isCameraInitialized && !_isProcessing && !_pickingImage
                      ? _onCapture
                      : null,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Switch camera',
                  onPressed:
                      _cameras.length > 1 &&
                          _isCameraInitialized &&
                          !_isProcessing &&
                          !_pickingImage
                      ? () => _initializeCamera(
                          (_cameraIndex + 1) % _cameras.length,
                        )
                      : null,
                  icon: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 30,
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
