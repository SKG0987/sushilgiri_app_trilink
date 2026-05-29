class AppUser {
  static const _kathmanduOffset = Duration(hours: 5, minutes: 45);

  static DateTime _parseSupabaseTimestamp(String value) {
    final dt = DateTime.parse(value);
    if (!value.endsWith('Z') &&
        !value.contains('+') &&
        !value.contains('-', value.length - 6)) {
      return dt.add(_kathmanduOffset);
    }
    return dt;
  }
  final String id;
  final String name;
  final String email;
  final String? profilePic;
  final String? phoneNumber;      // Added
  final String? homeAddress;      // Added
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.profilePic,
    this.phoneNumber,
    this.homeAddress,
    required this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      profilePic: json['profile_pic'] as String?,
      phoneNumber: json['phone_number'] as String?,
      homeAddress: json['home_address'] as String?,
      createdAt: _parseSupabaseTimestamp(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? _parseSupabaseTimestamp(json['updated_at'] as String)
          : null,
    );
  }

  AppUser copyWith({
    String? name,
    String? profilePic,
    String? phoneNumber,
    String? homeAddress,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      profilePic: profilePic ?? this.profilePic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      homeAddress: homeAddress ?? this.homeAddress,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}