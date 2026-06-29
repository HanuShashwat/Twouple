import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class ImportApi {
  final ApiClient _apiClient;

  ImportApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Upload a WhatsApp chat .txt file for AI analysis.
  /// Returns a map with 'analysis', 'message_count', 'analyzed_at'.
  Future<Map<String, dynamic>> analyzeWhatsAppChat(File file) async {
    String fileName = file.path.split(Platform.pathSeparator).last;

    FormData formData = FormData.fromMap({
      'chatFile': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _apiClient.post(
      '/import/chat',
      data: formData,
    );

    return Map<String, dynamic>.from(response.data['data']);
  }
}
