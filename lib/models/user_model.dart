class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'phone': phone, 'role': role};
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      role: map['role'] ?? 'user',
    );
  }
}
