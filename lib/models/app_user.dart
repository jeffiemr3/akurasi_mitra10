/// Model data user, sesuai struktur node `users/{id}` di Realtime Database.
class AppUser {
  final String id;
  final String name;
  final String username;
  final String password;
  final String role; // 'admin' | 'client'
  final String? category; // null kalau role admin
  final String status; // 'active' | 'idle'

  const AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    this.category,
    required this.status,
  });

  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'active';

  factory AppUser.fromMap(String id, Map<dynamic, dynamic> map) {
    return AppUser(
      id: id,
      name: (map['name'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      password: (map['password'] ?? '').toString(),
      role: (map['role'] ?? 'client').toString(),
      category: map['category']?.toString(),
      status: (map['status'] ?? 'active').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'category': category,
      'status': status,
    };
  }

  AppUser copyWith({
    String? name,
    String? username,
    String? password,
    String? role,
    String? category,
    String? status,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      category: category ?? this.category,
      status: status ?? this.status,
    );
  }
}
