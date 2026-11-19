class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isEmailVerified;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'user',
    this.isEmailVerified = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: (j['id'] ?? j['_id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        role: (j['role'] ?? 'user').toString(),
        isEmailVerified: j['isEmailVerified'] != false,
      );

  bool get isAdmin => role == 'admin';
  String get firstName => name.trim().isEmpty ? 'there' : name.trim().split(RegExp(r'\s+')).first;
  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
