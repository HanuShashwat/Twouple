import '../core/network/api_client.dart';
import '../models/user_model.dart';

class UserService {
  final ApiClient _apiClient;

  UserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch the authenticated user's profile
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/users/me');
    return UserModel.fromJson(response.data['data']);
  }

  /// Update the authenticated user's profile
  Future<UserModel> updateProfile(Map<String, dynamic> updateData) async {
    final response = await _apiClient.put(
      '/users/me',
      data: updateData,
    );
    return UserModel.fromJson(response.data['data']);
  }

  /// Permanently delete the authenticated user's account
  Future<bool> deleteAccount() async {
    final response = await _apiClient.delete('/users/me');
    return response.data['success'] == true;
  }
}
