import 'package:dio/dio.dart';
import 'package:opalmer_education/core/constants/api_constants.dart';
import 'package:opalmer_education/core/services/api_client.dart';

String downloadFileName(String url) {
  final uri = Uri.tryParse(url);
  final publicId = uri?.queryParameters['public_id'];
  return publicId?.split('/').last ??
      (uri?.pathSegments.isNotEmpty == true
          ? uri!.pathSegments.last
          : 'document');
}

Dio dioForDownloadUrl(String url) {
  final uri = Uri.tryParse(url);
  final apiUri = Uri.parse(ApiConstants.apiOrigin);
  final isExternalUrl =
      uri != null &&
      uri.hasScheme &&
      uri.host.isNotEmpty &&
      uri.host != apiUri.host;

  return isExternalUrl ? Dio() : ApiClient().dio;
}
