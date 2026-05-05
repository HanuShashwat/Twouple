class UserModel {
  final String id;
  final String phoneNumber;
  final String? fullName;
  final String? dob;
  final String? timeOfBirth;
  final String? placeOfBirth;
  final String? zodiacSign;
  final bool isPremium;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    this.dob,
    this.timeOfBirth,
    this.placeOfBirth,
    this.zodiacSign,
    required this.isPremium,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      fullName: json['full_name'] as String?,
      dob: json['dob'] as String?,
      timeOfBirth: json['time_of_birth'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      zodiacSign: json['zodiac_sign'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'dob': dob,
      'time_of_birth': timeOfBirth,
      'place_of_birth': placeOfBirth,
      'zodiac_sign': zodiacSign,
      'is_premium': isPremium,
    };
  }
}
