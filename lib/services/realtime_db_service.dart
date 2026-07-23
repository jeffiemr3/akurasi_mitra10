import 'package:firebase_database/firebase_database.dart';

import '../models/app_user.dart';
import '../models/category_assignment.dart';

/// Semua akses ke Firebase Realtime Database dikumpulkan di satu tempat
/// supaya screen-screen tidak perlu tahu detail path/struktur data.
///
/// Struktur data:
/// ```
/// users/{userId}       -> AppUser.toMap()
/// categories/{catId}   -> CategoryAssignment.toMap()
/// itemsMap/{catKey}    -> { categoryName, items: [AuditItem.toMap(), ...] }
/// meta/lastUploadAt    -> "22/07/2026 07:57 WIB"
/// ```
class RealtimeDbService {
  RealtimeDbService._();
  static final RealtimeDbService instance = RealtimeDbService._();

  final DatabaseReference _root = FirebaseDatabase.instance.ref();

  DatabaseReference get _usersRef => _root.child('users');
  DatabaseReference get _categoriesRef => _root.child('categories');
  DatabaseReference get _itemsMapRef => _root.child('itemsMap');
  DatabaseReference get _metaRef => _root.child('meta');

  // ---------------------------------------------------------------------
  // Seed data awal (dipanggil sekali saat aplikasi start)
  // ---------------------------------------------------------------------
  Future<void> seedInitialAdminIfEmpty() async {
    final snapshot = await _usersRef.get();
    if (!snapshot.exists || snapshot.children.isEmpty) {
      final ref = _usersRef.push();
      await ref.set({
        'name': 'Administrator',
        'username': 'admin',
        'password': 'admin123',
        'role': 'admin',
        'category': null,
        'status': 'active',
      });
    }
  }

  // ---------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------
  Stream<List<AppUser>> watchUsers() {
    return _usersRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return <AppUser>[];
      return data.entries
          .map((e) => AppUser.fromMap(e.key.toString(), e.value as Map))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  Future<List<AppUser>> fetchUsersOnce() async {
    final snapshot = await _usersRef.get();
    final data = snapshot.value;
    if (data is! Map) return <AppUser>[];
    return data.entries
        .map((e) => AppUser.fromMap(e.key.toString(), e.value as Map))
        .toList();
  }

  Future<void> addUser(AppUser user) async {
    final ref = _usersRef.push();
    await ref.set(user.toMap());
  }

  Future<void> updateUser(String userId, Map<String, dynamic> patch) async {
    await _usersRef.child(userId).update(patch);
  }

  Future<void> deleteUser(String userId) async {
    await _usersRef.child(userId).remove();
  }

  // ---------------------------------------------------------------------
  // Categories (penugasan misi)
  // ---------------------------------------------------------------------
  Stream<List<CategoryAssignment>> watchCategories() {
    return _categoriesRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return <CategoryAssignment>[];
      return data.entries
          .map((e) =>
              CategoryAssignment.fromMap(e.key.toString(), e.value as Map))
          .where((c) => !isInvalidCategoryName(c.categoryName))
          .toList();
    });
  }

  Future<void> upsertCategory(CategoryAssignment category) async {
    await _categoriesRef.child(category.id).set(category.toMap());
  }

  Future<void> saveCategories(List<CategoryAssignment> categories) async {
    final updates = <String, dynamic>{};
    for (final c in categories) {
      updates[c.id] = c.toMap();
    }
    if (updates.isNotEmpty) {
      await _categoriesRef.update(updates);
    }
  }

  Future<void> assignCategoryToUser(String categoryId, String? username) async {
    await _categoriesRef.child(categoryId).update({
      'assignedUsername': username,
    });
  }

  // ---------------------------------------------------------------------
  // Items map (hasil upload data stok WMS vs NAV)
  // ---------------------------------------------------------------------
  Future<void> saveItemsForCategory(
    String categoryName,
    List<AuditItem> items,
  ) async {
    final key = _sanitizeKey(categoryName);
    await _itemsMapRef.child(key).set({
      'categoryName': categoryName,
      'items': items.map((i) => i.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  String _sanitizeKey(String raw) =>
      raw.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

  // ---------------------------------------------------------------------
  // Meta (waktu upload terakhir)
  // ---------------------------------------------------------------------
  Stream<String?> watchLastUploadAt() {
    return _metaRef.child('lastUploadAt').onValue.map((event) {
      final v = event.snapshot.value;
      return v?.toString();
    });
  }

  Future<void> saveLastUploadAt(String timestamp) async {
    await _metaRef.child('lastUploadAt').set(timestamp);
  }
}
