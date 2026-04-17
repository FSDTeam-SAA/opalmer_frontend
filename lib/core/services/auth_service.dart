import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:opalmer_education/core/constants/api_constants.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/services/api_client.dart';
import 'package:opalmer_education/core/services/secure_storage_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  Future<LoginResponse?> login(String id, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'Id': id,
          'password': password,
        },
      );

      final dataMap = UserModel.recursiveSafeMap(response.data);
      
      if (response.statusCode == 200 && dataMap['success'] == true) {
        final loginResponse = LoginResponse.fromJson(dataMap);
        
        // Save token and user data
        await _storage.saveToken(loginResponse.token);
        await _storage.saveUserData(jsonEncode(loginResponse.user.toJson()));
        
        return loginResponse;
      }
      return null;
    } on DioException catch (e) {
      final errorData = UserModel.recursiveSafeMap(e.response?.data);
      final message = errorData['message']?.toString() ?? 'Login failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<UserModel?> getCurrentUser() async {
    final userData = await _storage.getUserData();
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }
}
