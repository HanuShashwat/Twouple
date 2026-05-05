import '../core/network/api_client.dart';
import '../core/auth/token_manager.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Request an OTP to the given phone number
  Future<bool> requestOtp(String phoneNumber) async {
    final response = await _apiClient.post(
      '/auth/request-otp',
      data: {'phone_number': phoneNumber},
    );
    
    return response.data['success'] == true;
  }

  /// Verify OTP and login or register the user
  /// Returns a map containing the token, user info, and whether it's a new user
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final response = await _apiClient.post(
      '/auth/verify-otp',
      data: {
        'phone_number': phoneNumber,
        'otp': otp,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      final token = data['token'];
      
      // Save token securely
      if (token != null) {
        await TokenManager.saveToken(token);
      }
      
      return {
        'token': token,
        'isNewUser': data['isNewUser'] ?? false,
        'user': UserModel.fromJson(data['user']),
      };
    }
    
    throw Exception('Authentication failed');
  }

  /// Log out the current user
  Future<void> logout() async {
    await TokenManager.deleteToken();
  }
}
