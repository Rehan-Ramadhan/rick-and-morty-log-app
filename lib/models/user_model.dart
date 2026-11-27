/// Authenticated user model matching Laravel `/user`, `/login`, and `/register` responses.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final DateTime? createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}
