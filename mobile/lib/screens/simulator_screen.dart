import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/student_data.dart';
import '../utils/app_theme.dart';
import '../widgets/kpi_card.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final Map<String, double> _simScores = {};
  final _targetCtrl = TextEditingController();
  String _filterMode = 'Tất cả';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _targetCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_SimCandidate> _buildCandidates(StudentData data) {
    final passedCodes = <String>{};
    final bestScores = <String, double>{};

    for (var r in data.ketQuaHocTap) {
      if (r.maHP == null) continue;
      final existing = bestScores[r.maHP!];
      if (r.diemHe10 != null) {
        if (existing == null || r.diemHe10! > existing) {
          bestScores[r.maHP!] = r.diemHe10!;
        }
      }
      if (r.diemHe10 != null && r.diemHe10! >= 4.0) {
        passedCodes.add(r.maHP!);
      }
    }

    final candidates = <_SimCandidate>[];
    final seen = <String>{};

    for (var r in data.ketQuaHocTap) {
      if (r.maHP == null ||
          passedCodes.contains(r.maHP!) ||
          seen.contains(r.maHP!))
        continue;
      seen.add(r.maHP!);
      final best = bestScores[r.maHP!];
      final status = (best != null && best < 4.0) ? 'Chưa đạt' : 'Chưa học';
      candidates.add(
        _SimCandidate(
          maHP: r.maHP!,
          tenHP: r.tenHP ?? r.maHP!,
          soTinChi: r.soTinChi,
          hocKy: int.tryParse(r.hocKy ?? ''),
          status: status,
          currentScore: best,
        ),
      );
    }

    for (var c in data.chuongTrinhDaoTao) {
      if (c.maHP == null ||
          passedCodes.contains(c.maHP!) ||
          seen.contains(c.maHP!))
        continue;
      seen.add(c.maHP!);
      candidates.add(
        _SimCandidate(
          maHP: c.maHP!,
          tenHP: c.tenHP ?? c.maHP!,
          soTinChi: c.soTinChi,
          hocKy: c.hocKy,
          status: 'Chưa học',
          currentScore: null,
        ),
      );
    }

    var filtered = candidates;
    if (_filterMode == 'Chưa đạt') {
      filtered = filtered.where((c) => c.status == 'Chưa đạt').toList();
    } else if (_filterMode == 'Chưa học') {
      filtered = filtered.where((c) => c.status == 'Chưa học').toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (c) =>
                c.maHP.toLowerCase().contains(q) ||
                c.tenHP.toLowerCase().contains(q),
          )
          .toList();
    }

    return filtered;
  }

  double _simulatedGPA(StudentData data) {
    final bestGrades = <String, AcademicResult>{};
    for (var r in data.ketQuaHocTap) {
      if (r.maHP == null || r.diemHe10 == null) continue;
      final existing = bestGrades[r.maHP!];
      if (existing == null || (existing.diemHe10 ?? 0) < r.diemHe10!) {
        bestGrades[r.maHP!] = r;
      }
    }

    double sum = 0;
    int credits = 0;

    for (var e in bestGrades.entries) {
      final code = e.key;
      final r = e.value;
      final simScore = _simScores[code];
      if (simScore != null && simScore > (r.diemHe10 ?? 0)) {
        sum += simScore * r.soTinChi;
      } else {
        sum += (r.diemHe10 ?? 0) * r.soTinChi;
      }
      credits += r.soTinChi;
    }

    for (var entry in _simScores.entries) {
      if (!bestGrades.containsKey(entry.key)) {
        final cur = data.chuongTrinhDaoTao.where((c) => c.maHP == entry.key);
        if (cur.isNotEmpty) {
          sum += entry.value * cur.first.soTinChi;
          credits += cur.first.soTinChi;
        }
      }
    }

    return credits == 0 ? 0 : sum / credits;
  }

  void _suggestForTarget(StudentData data) {
    final targetStr = _targetCtrl.text.trim();
    if (targetStr.isEmpty) return;
    final target = double.tryParse(targetStr);
    if (target == null) return;

    final bestGrades = <String, AcademicResult>{};
    for (var r in data.ketQuaHocTap) {
      if (r.maHP == null || r.diemHe10 == null) continue;
      final existing = bestGrades[r.maHP!];
      if (existing == null || (existing.diemHe10 ?? 0) < r.diemHe10!) {
        bestGrades[r.maHP!] = r;
      }
    }

    double doneSum = 0;
    int doneCredits = 0;
    for (var r in bestGrades.values) {
      doneSum += (r.diemHe10 ?? 0) * r.soTinChi;
      doneCredits += r.soTinChi;
    }

    int remainCredits = 0;
    final candidates = _buildCandidates(data);
    for (var c in candidates) {
      if (!bestGrades.containsKey(c.maHP)) {
        remainCredits += c.soTinChi;
      }
    }

    if (remainCredits <= 0) return;
    final totalCredits = doneCredits + remainCredits;
    final neededAvg = (target * totalCredits - doneSum) / remainCredits;
    final suggested = neededAvg.clamp(0.0, 10.0);

    setState(() {
      for (var c in candidates) {
        _simScores[c.maHP] = suggested;
      }
    });
  }

  void _reset() {
    setState(() {
      _simScores.clear();
      _targetCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final data = provider.studentData;
        if (data == null)
          return const Center(child: CircularProgressIndicator());

        final candidates = _buildCandidates(data);
        final currentGPA = data.currentGPA10;
        final simGPA = _simulatedGPA(data);
        final gap = simGPA - currentGPA;

        return Column(
          children: [
            // Tip Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nhập điểm giả định cho các môn bên dưới hoặc đặt CPA mục tiêu để tự động gợi ý.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // KPI cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'CPA HIỆN TẠI',
                      value: currentGPA.toStringAsFixed(2),
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      title: 'CPA MÔ PHỎNG',
                      value: simGPA.toStringAsFixed(2),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      title: 'THAY ĐỔI',
                      value: '${gap >= 0 ? '+' : ''}${gap.toStringAsFixed(2)}',
                      color: gap > 0
                          ? AppTheme.success
                          : gap < 0
                          ? AppTheme.error
                          : context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Target + Reset
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: context.cardShadow,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.gps_fixed,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 56,
                      height: 34,
                      child: TextField(
                        controller: _targetCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                          ),
                          hintText: 'CPA',
                          hintStyle: AppTheme.caption.copyWith(
                            color: context.textMuted,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSubmitted: (_) => _suggestForTarget(data),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _presetButton('7.0', data),
                    const SizedBox(width: 4),
                    _presetButton('8.0', data),
                    const Spacer(),
                    SizedBox(
                      height: 32,
                      child: TextButton(
                        onPressed: _reset,
                        style: TextButton.styleFrom(
                          foregroundColor: context.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Đặt lại',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Filter bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: context.scaffoldColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterMode,
                        style: AppTheme.caption.copyWith(
                          color: context.textPrimary,
                        ),
                        dropdownColor: context.cardColor,
                        items: ['Tất cả', 'Chưa đạt', 'Chưa học']
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _filterMode = v!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: TextField(
                        controller: _searchCtrl,
                        style: AppTheme.caption.copyWith(
                          color: context.textPrimary,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 16),
                          hintText: 'Tìm môn...',
                          hintStyle: AppTheme.caption.copyWith(
                            color: context.textMuted,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: context.scaffoldColor,
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Subject list
            Expanded(
              child: candidates.isEmpty
                  ? Center(
                      child: Text(
                        'Không tìm thấy môn học nào.',
                        style: AppTheme.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: candidates.length,
                      itemBuilder: (context, index) =>
                          _buildCandidateRow(candidates[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _presetButton(String val, StudentData data) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: () {
          _targetCtrl.text = val;
          _suggestForTarget(data);
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          val,
          style: AppTheme.caption.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateRow(_SimCandidate c) {
    final score = _simScores[c.maHP] ?? 8.0;
    final isFailed = c.status == 'Chưa đạt';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            width: 3,
            color: isFailed
                ? AppTheme.error
                : (context.isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.15 : 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.tenHP,
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${c.maHP} · ${c.soTinChi} TC · ${c.status}',
                  style: AppTheme.caption.copyWith(color: context.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 52,
            height: 34,
            child: TextField(
              controller: TextEditingController(text: score.toStringAsFixed(1)),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              onChanged: (v) {
                final val = double.tryParse(v);
                if (val != null) {
                  setState(() => _simScores[c.maHP] = val.clamp(0, 10));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SimCandidate {
  final String maHP;
  final String tenHP;
  final int soTinChi;
  final int? hocKy;
  final String status;
  final double? currentScore;
  _SimCandidate({
    required this.maHP,
    required this.tenHP,
    required this.soTinChi,
    this.hocKy,
    required this.status,
    this.currentScore,
  });
}
