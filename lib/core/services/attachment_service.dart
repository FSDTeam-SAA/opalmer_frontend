import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

/// Shared validation and multipart handling for native and browser pickers.
class AttachmentService {
  static const resourceExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'mp4',
    'webm',
    'mov',
    'mp3',
    'm4a',
    'wav',
    'ogg',
  ];

  static String? validate(
    PlatformFile file, {
    int maxMb = 100,
    List<String>? extensions,
  }) {
    final extension = file.name.split('.').last.toLowerCase();
    if (!(extensions ?? resourceExtensions).contains(extension)) {
      return 'Unsupported file format. Choose ${(extensions ?? resourceExtensions).join(', ')}.';
    }
    if (file.size <= 0) {
      return 'This file is empty. Choose another file.';
    }
    if (file.size > maxMb * 1024 * 1024) {
      return '${file.name} must be $maxMb MB or smaller.';
    }
    return null;
  }

  static Future<MultipartFile> multipart(
    PlatformFile file, {
    int maxMb = 100,
    List<String>? extensions,
  }) async {
    final error = validate(file, maxMb: maxMb, extensions: extensions);
    if (error != null) throw FormatException(error);
    if (file.bytes != null) {
      return MultipartFile.fromBytes(file.bytes!, filename: file.name);
    }
    if (file.path == null || file.path!.isEmpty) {
      throw const FormatException(
        'The selected file cannot be read. Please select it again.',
      );
    }
    return MultipartFile.fromFile(file.path!, filename: file.name);
  }

  static String errorMessage(Object error) {
    if (error is FormatException) return error.message;
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map && body['message'] is String) return body['message'];
      if (error.response?.statusCode == 413) {
        return 'This file is too large. Choose a smaller attachment.';
      }
      if (error.response?.statusCode == 401) {
        return 'Your session has expired. Please sign in again.';
      }
      if ([
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.connectionTimeout,
      ].contains(error.type)) {
        return 'The upload timed out. Check your connection and try a smaller file.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to connect. Check your internet connection and retry.';
      }
    }
    return 'Unable to save. Please try again.';
  }

  static Options get uploadOptions => Options(
    sendTimeout: const Duration(minutes: 3),
    receiveTimeout: const Duration(minutes: 3),
  );
}
