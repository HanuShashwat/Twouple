import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  /// Save JWT token securely
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get the saved JWT token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete the saved JWT token (logout)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if a valid (non-expired) token exists
  static Future<bool> hasValidToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }
    
    // Check if token is expired
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      // If there's an error decoding, consider it invalid
      return false;
    }
  }
  
  /// Get user ID from the token payload
  static Future<String?> getUserIdFromToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;
    
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['id'] as String?;
    } catch (e) {
      return null;
    }
  }
}
