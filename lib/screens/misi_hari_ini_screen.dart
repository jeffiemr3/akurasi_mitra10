import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/audit_item.dart';
import '../theme/app_colors.dart';

class MisiHariIniScreen extends StatefulWidget {
  final String category;
  final String username;

  const MisiHariIniScreen({
    super.key,
    required this.category,
    required this.username,
  });

  @override
  State<MisiHariIniScreen> createState() => _MisiHariIniScreenState();
}

class _MisiHariIniScreenState extends State<MisiHariIniScreen> {
  late final List<AuditItem> _items;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _items = dummyAuditItems(widget.category);
  }

  int get _total => _items.length;
  int get _hitCount => _items.where((i) => i.status == AuditStatus.hit).length;
  int get _missCount => _items.where((i) => i.status == AuditStatus.miss).length;
  int get _overCount => _items.where((i) => i.status == AuditStatus.over).length;
  int get _needRecheck => _missCount + _overCount;
  double get _accuracy => _total == 0 ? 0 : (_hitCount / _total) * 100;

  Future<void> _kirimReport() async {
    setState(() => _sending = true);
    try {
      final ref = FirebaseDatabase.instance.ref('reports').push();
      await ref.set({
        'category': widget.category,
        'username': widget.username,
        'total': _total,
        'hit': _hitCount,
        'miss': _missCount,
        'over': _overCount,
        'accuracy': _accuracy,
        'items': _items.map((e) => e.toMap()).toList(),
        'sentAt': ServerValue.timestamp,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report berhasil dikirim')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal mengirim report: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MISI HARI INI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    children: [
                      const Text(
                        'MISI HARI INI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppColors.amber,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kategori ${widget.category}',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.fieldFill,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CustomPaint(
                                painter: _DonutPainter(
                                  hit: _hitCount,
                                  miss: _missCount,
                                  over: _overCount,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_accuracy.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const Text(
                                        'AKURASI',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6,
                                          color: AppColors.inkSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_total item',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _LegendRow(color: AppColors.tealMid, label: '$_hitCount hit'),
                                  const SizedBox(height: 4),
                                  _LegendRow(color: AppColors.coral, label: '$_missCount miss'),
                                  const SizedBox(height: 4),
                                  _LegendRow(color: AppColors.gold, label: '$_overCount over'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.grayChip,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.assignment_outlined, size: 16, color: AppColors.inkSoft),
                            const SizedBox(width: 8),
                            Text(
                              '$_needRecheck item perlu dicek ulang',
                              style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ItemCard(item: item),
                          )),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : _kirimReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    icon: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(_sending ? 'Mengirim...' : 'Kirim report',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.ink)),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final AuditItem item;

  const _ItemCard({required this.item});

  Color get _badgeBg {
    switch (item.status) {
      case AuditStatus.hit:
        return AppColors.tealBg;
      case AuditStatus.miss:
        return AppColors.coralBg;
      case AuditStatus.over:
        return AppColors.amberBg;
    }
  }

  Color get _badgeText {
    switch (item.status) {
      case AuditStatus.hit:
        return AppColors.teal;
      case AuditStatus.miss:
        return AppColors.coral;
      case AuditStatus.over:
        return AppColors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.codeWms} · ${item.codeNav}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.inkSoft,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'WMS ${item.wmsStock} · NAV ${item.navStock}',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.status.label,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: _badgeText),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int hit;
  final int miss;
  final int over;

  _DonutPainter({required this.hit, required this.miss, required this.over});

  @override
  void paint(Canvas canvas, Size size) {
    final total = hit + miss + over;
    if (total == 0) return;

    final strokeWidth = size.width * 0.16;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - strokeWidth) / 2;

    final basePaint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, basePaint);

    double start = -math.pi / 2;
    final segments = [
      [hit, AppColors.tealMid],
      [over, AppColors.gold],
      [miss, AppColors.coral],
    ];

    for (final seg in segments) {
      final value = seg[0] as int;
      final color = seg[1] as Color;
      if (value == 0) continue;
      final sweep = (value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.hit != hit || oldDelegate.miss != miss || oldDelegate.over != over;
  }
}
