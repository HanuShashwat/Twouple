import 'user_model.dart';

class ChatMessageModel {
  final String id;
  final String? relationshipId;
  final String? senderId;
  final String messageBody;
  final bool isAi;
  final DateTime createdAt;
  final UserModel? sender;

  ChatMessageModel({
    required this.id,
    this.relationshipId,
    this.senderId,
    required this.messageBody,
    required this.isAi,
    required this.createdAt,
    this.sender,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      relationshipId: json['relationship_id'] as String?,
      senderId: json['sender_id'] as String?,
      messageBody: json['message_body'] as String,
      isAi: json['is_ai'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sender: json['Sender'] != null ? UserModel.fromJson(json['Sender']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relationship_id': relationshipId,
      'sender_id': senderId,
      'message_body': messageBody,
      'is_ai': isAi,
      'createdAt': createdAt.toIso8601String(),
      'Sender': sender?.toJson(),
    };
  }
}
