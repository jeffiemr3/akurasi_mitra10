/// Model penugasan kategori (misi) ke seorang auditor.
/// Sesuai struktur node `categories/{id}` di Realtime Database.
class CategoryAssignment {
  final String id;
  final String categoryName;
  final String? assignedUsername;
  final String status; // 'available' | 'locked'
  final int itemCount;

  const CategoryAssignment({
    required this.id,
    required this.categoryName,
    this.assignedUsername,
    required this.status,
    required this.itemCount,
  });

  factory CategoryAssignment.fromMap(String id, Map<dynamic, dynamic> map) {
    return CategoryAssignment(
      id: id,
      categoryName: (map['categoryName'] ?? '').toString(),
      assignedUsername: map['assignedUsername']?.toString(),
      status: (map['status'] ?? 'available').toString(),
      itemCount: (map['itemCount'] is num) ? (map['itemCount'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryName': categoryName,
      'assignedUsername': assignedUsername,
      'status': status,
      'itemCount': itemCount,
    };
  }

  CategoryAssignment copyWith({
    String? categoryName,
    String? assignedUsername,
    bool clearAssignedUsername = false,
    String? status,
    int? itemCount,
  }) {
    return CategoryAssignment(
      id: id,
      categoryName: categoryName ?? this.categoryName,
      assignedUsername:
          clearAssignedUsername ? null : (assignedUsername ?? this.assignedUsername),
      status: status ?? this.status,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}

/// Satu baris item audit stok (hasil upload data).
class AuditItem {
  final String id;
  final String name;
  final String codeWms;
  final String codeNav;
  final num wmsStock;
  final num navStock;
  final String status; // 'HIT' | 'MISS' | 'OVER'

  const AuditItem({
    required this.id,
    required this.name,
    required this.codeWms,
    required this.codeNav,
    required this.wmsStock,
    required this.navStock,
    required this.status,
  });

  factory AuditItem.fromMap(Map<dynamic, dynamic> map) {
    return AuditItem(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      codeWms: (map['codeWms'] ?? '').toString(),
      codeNav: (map['codeNav'] ?? '').toString(),
      wmsStock: (map['wmsStock'] is num) ? map['wmsStock'] as num : 0,
      navStock: (map['navStock'] is num) ? map['navStock'] as num : 0,
      status: (map['status'] ?? 'HIT').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'codeWms': codeWms,
      'codeNav': codeNav,
      'wmsStock': wmsStock,
      'navStock': navStock,
      'status': status,
    };
  }
}

/// Nama kategori "sampah" yang harus difilter (bawaan dari file WMS/NAV
/// mentah, bukan kategori barang sungguhan) — dipindahkan dari mockData.ts.
bool isInvalidCategoryName(String name) {
  final upper = name.trim().toUpperCase();
  if (upper.isEmpty) return true;
  const bannedKeywords = [
    'WAREHOUSE',
    'LOCATION',
    '70004',
    'REPORTSTOCK',
    'TANPA KATEGORI',
  ];
  return bannedKeywords.any((k) => upper.contains(k));
}
