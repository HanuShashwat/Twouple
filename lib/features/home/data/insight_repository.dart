import '../../../../api/insight_api.dart';

class InsightRepository {
  final InsightApi _insightApi;

  InsightRepository({InsightApi? insightApi}) : _insightApi = insightApi ?? InsightApi();

  Future<Map<String, dynamic>> getDailyData(String date) async {
    final data = await _insightApi.getDailyInsight(date);
    return data.toJson();
  }

  Future<void> toggleTask(String taskId) async {
    await _insightApi.toggleTaskCompletion(taskId);
  }
}
