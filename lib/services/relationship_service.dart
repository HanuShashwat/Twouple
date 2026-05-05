import '../core/network/api_client.dart';
import '../models/relationship_model.dart';

class RelationshipService {
  final ApiClient _apiClient;

  RelationshipService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Invite a partner by their phone number
  Future<RelationshipModel> invitePartner(String partnerPhone) async {
    final response = await _apiClient.post(
      '/relationships/invite',
      data: {'partner_phone': partnerPhone},
    );
    return RelationshipModel.fromJson(response.data['data']);
  }

  /// Get the current relationship status
  Future<Map<String, dynamic>> getRelationshipStatus() async {
    final response = await _apiClient.get('/relationships/status');
    
    final String status = response.data['data']['status'];
    
    if (status == 'none') {
      return {'status': status, 'data': null};
    }
    
    return {
      'status': status,
      'data': RelationshipModel.fromJson(response.data['data']['data']),
    };
  }

  /// Accept a pending invitation
  Future<RelationshipModel> acceptInvitation() async {
    final response = await _apiClient.post('/relationships/accept');
    return RelationshipModel.fromJson(response.data['data']);
  }
}
