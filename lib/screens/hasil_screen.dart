import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum _MissionStatus { done, progress, waiting }

class _CategoryResult {
  final String category;
  final String assignedTo;
  final int total;
  final int hit;
  final int miss;
  final int over;
  final _MissionStatus status;

  const _CategoryResult({
    required this.category,
    required this.assignedTo,
    required this.total,
    required this.hit,
    required this.miss,
    required this.over,
    required this.status,
  });

  double get accuracy => total == 0 ? 0 : (hit / total) * 100;
}

/// Layar "Hasil" — dashboard ringkasan akurasi audit semua kategori.
/// Data masih dummy/statis (belum ditarik dari Firebase), mengikuti pola
/// yang sama seperti `dummyAuditItems` di model AuditItem. Nanti tinggal
/// ganti `_results` dengan hasil agregasi Realtime Database yang sebenarnya.
class HasilScreen extends StatelessWidget {
  const HasilScreen({super.key});

  static const _results = [
    _CategoryResult(
      category: 'Floring & Wall',
      assignedTo: 'Sahat Sinaga',
      total: 1761,
      hit: 1543,
      miss: 57,
      over: 161,
      status: _MissionStatus.done,
    ),
    _CategoryResult(
      category: 'Electrical & Lighting',
      assignedTo: 'Rina Purnama',
      total: 2140,
      hit: 2014,
      miss: 64,
      over: 62,
      status: _MissionStatus.progress,
    ),
    _CategoryResult(
      category: 'Hand Tools',
      assignedTo: 'Andi Wijaya',
      total: 980,
      hit: 889,
      miss: 41,
      over: 50,
      status: _MissionStatus.waiting,
    ),
    _CategoryResult(
      category: 'Sanitary & Plumbing',
      assignedTo: 'Sahat Sinaga',
      total: 1323,
      hit: 1212,
      miss: 50,
      over: 61,
      status: _MissionStatus.done,
    ),
  ];

  int get _totalItems => _results.fold(0, (sum, r) => sum + r.total);
  int get _totalHit => _results.fold(0, (sum, r) => sum + r.hit);
  int get _totalMiss => _results.fold(0, (sum, r) => sum + r.miss);
  int get _totalOver => _results.fold(0, (sum, r) => sum + r.over);
  double get _overallAccuracy => _totalItems == 0 ? 0 : (_totalHit / _totalItems) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Hasil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Metric cards ---
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 560;
                            final cards = [
                              _MetricCard(
                                label: 'Akurasi keseluruhan',
                                value: '${_overallAccuracy.toStringAsFixed(1)}%',
                                bg: AppColors.avatarNavyBg,
                                valueColor: AppColors.navy,
                              ),
                              _MetricCard(
                                label: 'Total item dicek',
                                value: _totalItems.toString(),
                                bg: AppColors.grayChip,
                                valueColor: AppColors.ink,
                              ),
                              _MetricCard(
                                label: 'Hit',
                                value: _totalHit.toString(),
                                bg: AppColors.tealBg,
                                valueColor: AppColors.teal,
                              ),
                              _MetricCard(
                                label: 'Miss',
                                value: _totalMiss.toString(),
                                bg: AppColors.coralBg,
                                valueColor: AppColors.coral,
                              ),
                              _MetricCard(
                                label: 'Over',
                                value: _totalOver.toString(),
                                bg: AppColors.amberBg,
                                valueColor: AppColors.amber,
                              ),
                            ];
                            return GridView.count(
                              crossAxisCount: isWide ? 5 : 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: isWide ? 1.3 : 1.6,
                              children: cards,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Per kategori',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._results.map((r) => _CategoryRow(result: r)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color valueColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.bg,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final _CategoryResult result;
  const _CategoryRow({required this.result});

  String get _statusLabel {
    switch (result.status) {
      case _MissionStatus.done:
        return 'Selesai';
      case _MissionStatus.progress:
        return 'Berjalan';
      case _MissionStatus.waiting:
        return 'Belum mulai';
    }
  }

  Color get _statusBg {
    switch (result.status) {
      case _MissionStatus.done:
        return AppColors.tealBg;
      case _MissionStatus.progress:
        return AppColors.avatarNavyBg;
      case _MissionStatus.waiting:
        return AppColors.grayChip;
    }
  }

  Color get _statusColor {
    switch (result.status) {
      case _MissionStatus.done:
        return AppColors.teal;
      case _MissionStatus.progress:
        return AppColors.navy;
      case _MissionStatus.waiting:
        return AppColors.inkSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F5),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.category,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  _statusLabel,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: _statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Ditugaskan ke ${result.assignedTo}',
            style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: result.accuracy / 100,
                    minHeight: 5,
                    backgroundColor: AppColors.grayChip,
                    valueColor: const AlwaysStoppedAnimation(AppColors.tealMid),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${result.accuracy.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _StatDot(color: AppColors.tealMid, label: '${result.hit} hit'),
              _StatDot(color: AppColors.coral, label: '${result.miss} miss'),
              _StatDot(color: AppColors.amber, label: '${result.over} over'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatDot extends StatelessWidget {
  final Color color;
  final String label;
  const _StatDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
          color: AppColors.card,
        ),
        child: Icon(icon, size: 15, color: AppColors.ink),
      ),
    );
  }
}
