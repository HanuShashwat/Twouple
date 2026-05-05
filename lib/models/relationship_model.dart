import 'user_model.dart';

class RelationshipModel {
  final String id;
  final String status;
  final String? userOneId;
  final String? userTwoId;
  final UserModel? partnerOne;
  final UserModel? partnerTwo;
  final int? compositeScore;
  final DateTime? establishedAt;

  RelationshipModel({
    required this.id,
    required this.status,
    this.userOneId,
    this.userTwoId,
    this.partnerOne,
    this.partnerTwo,
    this.compositeScore,
    this.establishedAt,
  });

  factory RelationshipModel.fromJson(Map<String, dynamic> json) {
    return RelationshipModel(
      id: json['id'] as String,
      status: json['status'] as String,
      userOneId: json['user_one_id'] as String?,
      userTwoId: json['user_two_id'] as String?,
      partnerOne: json['PartnerOne'] != null ? UserModel.fromJson(json['PartnerOne']) : null,
      partnerTwo: json['PartnerTwo'] != null ? UserModel.fromJson(json['PartnerTwo']) : null,
      compositeScore: json['composite_score'] as int?,
      establishedAt: json['established_at'] != null ? DateTime.parse(json['established_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'user_one_id': userOneId,
      'user_two_id': userTwoId,
      'PartnerOne': partnerOne?.toJson(),
      'PartnerTwo': partnerTwo?.toJson(),
      'composite_score': compositeScore,
      'established_at': establishedAt?.toIso8601String(),
    };
  }
}
