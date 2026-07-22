/// Status hasil audit stok per item.
enum AuditStatus { hit, miss, over }

extension AuditStatusLabel on AuditStatus {
  String get label {
    switch (this) {
      case AuditStatus.hit:
        return 'Hit';
      case AuditStatus.miss:
        return 'Miss';
      case AuditStatus.over:
        return 'Over';
    }
  }
}

class AuditItem {
  final String name;
  final String codeWms;
  final String codeNav;
  final int wmsStock;
  final int navStock;
  final AuditStatus status;

  const AuditItem({
    required this.name,
    required this.codeWms,
    required this.codeNav,
    required this.wmsStock,
    required this.navStock,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'codeWms': codeWms,
      'codeNav': codeNav,
      'wmsStock': wmsStock,
      'navStock': navStock,
      'status': status.name,
    };
  }
}

/// Data contoh (dummy) untuk kategori Floring & Wall.
/// Nanti bisa diganti sumbernya dari Firebase / hasil scan barcode.
List<AuditItem> dummyAuditItems(String category) {
  return const [
    AuditItem(
      name: 'Panasonic WEJ5911N kotak inbow doos 1 gang',
      codeWms: '0700017740',
      codeNav: '2000001717057',
      wmsStock: 98,
      navStock: 96,
      status: AuditStatus.over,
    ),
    AuditItem(
      name: 'Panasonic WEJ9111W steker sktk AC 5 NP',
      codeWms: '0700026955',
      codeNav: '2100000514755',
      wmsStock: 5,
      navStock: 5,
      status: AuditStatus.hit,
    ),
    AuditItem(
      name: 'Vinyl lantai motif kayu 60x60',
      codeWms: '0700031882',
      codeNav: '2100000598211',
      wmsStock: 12,
      navStock: 14,
      status: AuditStatus.miss,
    ),
    AuditItem(
      name: 'Keramik dinding putih 25x40',
      codeWms: '0700045210',
      codeNav: '2100000622341',
      wmsStock: 210,
      navStock: 210,
      status: AuditStatus.hit,
    ),
    AuditItem(
      name: 'Wallpaper motif bunga 10m',
      codeWms: '0700052871',
      codeNav: '2100000714902',
      wmsStock: 18,
      navStock: 22,
      status: AuditStatus.miss,
    ),
    AuditItem(
      name: 'Lem keramik 40kg',
      codeWms: '0700061123',
      codeNav: '2100000833120',
      wmsStock: 76,
      navStock: 70,
      status: AuditStatus.over,
    ),
  ];
}
