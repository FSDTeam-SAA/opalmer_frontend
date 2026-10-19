import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';

enum PolicyContentType { about, terms }

class PolicyContentDocument {
  final String html;
  final DateTime? updatedAt;
  const PolicyContentDocument({required this.html, this.updatedAt});
  factory PolicyContentDocument.fromJson(Map<String, dynamic> json) {
    final value = json['description']?.toString() ?? '';
    final html = RegExp(r'</?[a-z][^>]*>', caseSensitive: false).hasMatch(value)
        ? value
        : '<p>${value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('\n', '<br>')}</p>';
    return PolicyContentDocument(
      html: html,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class PolicyContentService {
  final Dio _dio;
  PolicyContentService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );
  Future<PolicyContentDocument?> load(PolicyContentType type) async {
    final response = await _dio.get(
      '/aboutAndTerm/${type.name}',
      options: Options(headers: {'Cache-Control': 'no-cache'}),
    );
    final body = response.data;
    if (body is! Map || body['success'] != true) {
      throw StateError('Unable to load content');
    }
    final data = body['data'];
    final records = data is List
        ? data.whereType<Map>().toList()
        : data is Map
        ? [data]
        : <Map>[];
    if (records.isEmpty) return null;
    records.sort(
      (a, b) =>
          (DateTime.tryParse(b['updatedAt']?.toString() ?? '') ??
                  DateTime(1970))
              .compareTo(
                DateTime.tryParse(a['updatedAt']?.toString() ?? '') ??
                    DateTime(1970),
              ),
    );
    return PolicyContentDocument.fromJson(
      Map<String, dynamic>.from(records.first),
    );
  }
}

final policyContentServiceProvider = Provider<PolicyContentService>(
  (ref) => PolicyContentService(),
);
final policyContentProvider = FutureProvider.autoDispose
    .family<PolicyContentDocument?, PolicyContentType>(
      (ref, type) => ref.read(policyContentServiceProvider).load(type),
    );
