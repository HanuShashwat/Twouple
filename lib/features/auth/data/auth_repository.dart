import 'models/user_model.dart';

class AuthRepository {
  Future<void> sendOtp(String phone) async {
    // Mock API call delay
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<UserModel> verifyOtp(String phone, String otp) async {
    // Mock API call delay
    await Future.delayed(const Duration(seconds: 1));
    if (otp == '123456') {
      return UserModel(
        id: 'user_123',
        name: 'Demo User',
        phone: phone,
      );
    } else {
      throw Exception('Invalid OTP');
    }
  }
}
