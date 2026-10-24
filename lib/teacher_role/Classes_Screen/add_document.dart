import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:ui' as ui;

import '../../core/providers/teacher_provider.dart';
import '../../core/services/attachment_service.dart';

class AddDocumentScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String? classId;
  const AddDocumentScreen({super.key, required this.studentId, this.classId});

  @override
  ConsumerState<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends ConsumerState<AddDocumentScreen> {
  static const int _maxPdfSizeBytes = 10 * 1024 * 1024;

  PlatformFile? _selectedFile;
  String? _selectedClassId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.classId;
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        if (pickedFile.size > _maxPdfSizeBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("PDF must be 10 MB or smaller."),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error picking file: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a class and a PDF file."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedFile!.size > _maxPdfSizeBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PDF must be 10 MB or smaller."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final classes = await ref.read(
        studentTeacherClassesProvider(widget.studentId).future,
      );
      if (!classes.any((cls) => cls.id == _selectedClassId)) {
        throw const FormatException(
          'Select a class in which this student is enrolled.',
        );
      }

      final formData = FormData.fromMap({
        "studentId": widget.studentId,
        "classId": _selectedClassId,
        "title": _selectedFile!.name,
        "document": await AttachmentService.multipart(
          _selectedFile!,
          maxMb: 10,
          extensions: ['pdf'],
        ),
      });

      final response = await apiClient.post(
        '/academicDocument/create',
        data: formData,
        options: AttachmentService.uploadOptions,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.invalidate(studentAcademicDocumentsProvider(widget.studentId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Document uploaded successfully"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(
          response.data?['message'] ?? 'Failed to upload document',
        );
      }
    } catch (e) {
      final errorMessage = AttachmentService.errorMessage(e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $errorMessage"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
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
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ),
        title: const Text(
          "Add New Document",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upload new academic document here",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              ref
                  .watch(studentTeacherClassesProvider(widget.studentId))
                  .when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => TextButton(
                      onPressed: () => ref.invalidate(
                        studentTeacherClassesProvider(widget.studentId),
                      ),
                      child: const Text('Unable to load classes. Retry'),
                    ),
                    data: (classes) => classes.isEmpty
                        ? const Text(
                            'This student is not enrolled in one of your classes.',
                          )
                        : DropdownButtonFormField<String>(
                            initialValue:
                                classes.any((cls) => cls.id == _selectedClassId)
                                ? _selectedClassId
                                : null,
                            isExpanded: true,
                            menuMaxHeight: 300,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF871DAD),
                            ),
                            hint: const Text('Select student class'),
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 14,
                            ),
                            selectedItemBuilder: (context) => classes
                                .map(
                                  (cls) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Grade ${cls.grade} - ${cls.subject}${cls.section?.isNotEmpty == true ? ' (Section ${cls.section})' : ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            decoration: InputDecoration(
                              labelText: 'Student class',
                            ),
                            items: classes
                                .map(
                                  (cls) => DropdownMenuItem(
                                    value: cls.id,
                                    child: Text(
                                      'Grade ${cls.grade} - ${cls.subject}${cls.section?.isNotEmpty == true ? ' (Section ${cls.section})' : ''}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: _isLoading
                                ? null
                                : (value) =>
                                      setState(() => _selectedClassId = value),
                          ),
                  ),
              const SizedBox(height: 24),
              // Dashed Upload Area
              GestureDetector(
                onTap: _pickFile,
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: const Color(0xFF871DAD),
                    strokeWidth: 1.5,
                    gap: 6.0,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 56,
                          color: Color(0xFF871DAD),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Tap to choose a PDF (up to 10 MB)",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF871DAD)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "UPLOAD PDF",
                            style: TextStyle(
                              color: Color(0xFF871DAD),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Uploaded files list
              if (_selectedFile != null) ...[
                _buildUploadedFile(_selectedFile!.name),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF871DAD),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "ADD",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedFile(String fileName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Color(0xFF871DAD), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedFile = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.grey.shade600, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path();
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    var rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    path.addRRect(rrect);

    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + gap),
          paint,
        );
        distance += gap * 2;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
