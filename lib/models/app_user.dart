/// Struktur data di Realtime Database: users/{userId}
/// {
///   "name": "Sahat Sinaga",
///   "username": "sahat.sinaga",
///   "password": "rahasia123",
///   "role": "client" | "admin",
///   "category": "Floring & Wall" | null (null kalau admin),
///   "status": "active" | "idle"
/// }
class AppUser {
  final String id;
  final String name;
  final String username;
  final String password;
  final String role;
  final String? category;
  final String status;

  AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    this.category,
    required this.status,
  });

  factory AppUser.fromMap(String id, Map<dynamic, dynamic> map) {
    return AppUser(
      id: id,
      name: (map['name'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      password: (map['password'] ?? '').toString(),
      role: (map['role'] ?? 'client').toString(),
      category: map['category']?.toString(),
      status: (map['status'] ?? 'idle').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'category': role == 'admin' ? null : category,
      'status': status,
    };
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String get categoryLabel =>
      role == 'admin' ? 'Admin · semua kategori' : (category ?? '-');

  bool get isActive => status == 'active';
}
