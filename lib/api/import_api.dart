import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class ImportApi {
  final ApiClient _apiClient;

  ImportApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Upload a chat export file to the backend
  Future<bool> uploadChatExport(File file) async {
    try {
      String fileName = file.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      // Assuming the endpoint is /import/chat
      final response = await _apiClient.post(
        '/import/chat',
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to upload chat export: $e');
    }
  }
}
