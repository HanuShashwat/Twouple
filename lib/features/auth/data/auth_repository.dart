import '../../../../models/user_model.dart';
import '../../../../api/auth_api.dart';

class AuthRepository {
  final AuthApi _authApi;

  AuthRepository({AuthApi? authApi}) : _authApi = authApi ?? AuthApi();

  Future<void> sendOtp(String phone) async {
    final success = await _authApi.requestOtp(phone);
    if (!success) {
      throw Exception('Failed to send OTP');
    }
  }

  Future<UserModel> verifyOtp(String phone, String otp) async {
    final result = await _authApi.verifyOtp(phone, otp);
    return result['user'] as UserModel;
  }
}
