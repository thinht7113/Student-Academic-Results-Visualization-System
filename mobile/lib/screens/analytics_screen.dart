import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/student_provider.dart';
import '../models/student_data.dart';
import '../utils/app_theme.dart';
import '../widgets/kpi_card.dart';
import '../widgets/section_header.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedSem = 'Tất cả';
  bool _accOnly = true;

  List<AcademicResult> _filter(List<AcademicResult> items) {
    var filtered = items.toList();
    if (_selectedSem != 'Tất cả') {
      final sem = _selectedSem.replaceAll('Học kỳ ', '');
      filtered = filtered.where((r) => r.hocKy == sem).toList();
    }
    if (_accOnly) {
      filtered = filtered.where((r) => r.tinhDiemTichLuy ?? true).toList();
    }
    return filtered;
  }

  double _gpa10(List<AcademicResult> items) {
    double s = 0;
    int c = 0;
    for (var r in items) {
      if (r.diemHe10 != null && r.soTinChi > 0) {
        s += r.diemHe10! * r.soTinChi;
        c += r.soTinChi;
      }
    }
    return c == 0 ? 0 : s / c;
  }

  double _gpa4(List<AcademicResult> items) {
    double s = 0;
    int c = 0;
    for (var r in items) {
      if (r.diemHe4 != null && r.soTinChi > 0) {
        s += r.diemHe4! * r.soTinChi;
        c += r.soTinChi;
      }
    }
    return c == 0 ? 0 : s / c;
  }

  double _passRate(List<AcademicResult> items) {
    final valid = items.where((r) => r.diemHe10 != null).toList();
    if (valid.isEmpty) return 0;
    return valid.where((r) => r.diemHe10! >= 4.0).length * 100 / valid.length;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final data = provider.studentData;
        if (data == null)
          return const Center(child: CircularProgressIndicator());

        final items = _filter(data.ketQuaHocTap);
        final semesters = data.semesters;

        return RefreshIndicator(
          onRefresh: () => context.read<StudentProvider>().loadData(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _buildFilterBar(semesters),
              const SizedBox(height: 16),
              _buildKPIRow(items),
              const SizedBox(height: 20),
              SectionHeader(title: 'Xu hướng CPA', icon: Icons.show_chart),
              const SizedBox(height: 8),
              _buildTrajectoryChart(items),
              const SizedBox(height: 20),
              SectionHeader(title: 'Phân bố điểm hệ 10', icon: Icons.bar_chart),
              const SizedBox(height: 8),
              _buildHistogram(items),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Tín chỉ vs. Điểm',
                icon: Icons.scatter_plot,
              ),
              const SizedBox(height: 8),
              _buildScatter(items),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Môn kéo tụt CPA',
                icon: Icons.trending_down,
              ),
              const SizedBox(height: 8),
              _buildImpactTable(items),
            ],
          ),
        );
      },
    );
  }

  Color get _gridColor =>
      context.isDark ? Colors.grey.shade800 : Colors.grey.shade200;

  Widget _buildFilterBar(List<int> semesters) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: context.cardShadow,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSem,
              style: AppTheme.bodySmall.copyWith(color: context.textPrimary),
              dropdownColor: context.cardColor,
              items: [
                const DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả')),
                ...semesters.map(
                  (s) => DropdownMenuItem(
                    value: 'Học kỳ $s',
                    child: Text('Học kỳ $s'),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _selectedSem = v!),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilterChip(
          label: Text(
            'Chỉ môn tích lũy',
            style: AppTheme.caption.copyWith(
              color: _accOnly ? Colors.white : context.textSecondary,
            ),
          ),
          selected: _accOnly,
          onSelected: (v) => setState(() => _accOnly = v),
          selectedColor: AppTheme.primaryColor,
          checkmarkColor: Colors.white,
          backgroundColor: context.cardColor,
        ),
      ],
    );
  }

  Widget _buildKPIRow(List<AcademicResult> items) {
    final totalTC = items.fold<int>(0, (s, r) => s + r.soTinChi);
    return Row(
      children: [
        Expanded(
          child: KpiCard(
            title: 'CPA (10)',
            value: _gpa10(items).toStringAsFixed(2),
            color: AppTheme.primaryColor,
            icon: Icons.stars,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: KpiCard(
            title: 'CPA (4)',
            value: _gpa4(items).toStringAsFixed(2),
            color: AppTheme.secondaryColor,
            icon: Icons.grade,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: KpiCard(
            title: 'Tổng TC',
            value: '$totalTC',
            color: AppTheme.success,
            icon: Icons.credit_card,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: KpiCard(
            title: 'Qua (%)',
            value: '${_passRate(items).toStringAsFixed(0)}%',
            color: AppTheme.warning,
            icon: Icons.percent,
          ),
        ),
      ],
    );
  }

  Widget _buildTrajectoryChart(List<AcademicResult> items) {
    final map = <int, List<AcademicResult>>{};
    for (var r in items) {
      final hk = int.tryParse(r.hocKy ?? '');
      if (hk == null) continue;
      map.putIfAbsent(hk, () => []).add(r);
    }
    final keys = map.keys.toList()..sort();
    if (keys.isEmpty) return _emptyChart('Chưa có dữ liệu kỳ');

    final spots10 = <FlSpot>[];
    final spots4 = <FlSpot>[];
    for (int i = 0; i < keys.length; i++) {
      spots10.add(FlSpot(i.toDouble(), _gpa10(map[keys[i]]!)));
      final g4 = _gpa4(map[keys[i]]!);
      if (g4 > 0) spots4.add(FlSpot(i.toDouble(), g4));
    }

    return _chartContainer(
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (v) => FlLine(color: _gridColor),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= keys.length) return const SizedBox();
                  return Text(
                    'HK${keys[i]}',
                    style: AppTheme.caption.copyWith(
                      fontSize: 10,
                      color: context.textMuted,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 2,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: AppTheme.caption.copyWith(
                    fontSize: 10,
                    color: context.textMuted,
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots10,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (s, d, b, i) => FlDotCirclePainter(
                  radius: 4,
                  color: context.cardColor,
                  strokeWidth: 2,
                  strokeColor: AppTheme.primaryColor,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
              ),
            ),
            if (spots4.isNotEmpty)
              LineChartBarData(
                spots: spots4,
                isCurved: true,
                color: AppTheme.warning,
                barWidth: 2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (s, d, b, i) => FlDotCirclePainter(
                    radius: 3,
                    color: context.cardColor,
                    strokeWidth: 2,
                    strokeColor: AppTheme.warning,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistogram(List<AcademicResult> items) {
    final scores = items
        .where((r) => r.diemHe10 != null)
        .map((r) => r.diemHe10!)
        .toList();
    if (scores.isEmpty) return _emptyChart('Chưa có dữ liệu điểm');

    final bins = List<int>.filled(10, 0);
    for (var s in scores) {
      bins[s.floor().clamp(0, 9)]++;
    }
    final maxCount = bins.reduce(max);

    return _chartContainer(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxCount.toDouble() + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: _gridColor),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: AppTheme.caption.copyWith(
                    fontSize: 10,
                    color: context.textMuted,
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: AppTheme.caption.copyWith(
                    fontSize: 10,
                    color: context.textMuted,
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            10,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: bins[i].toDouble(),
                  width: 18,
                  color: i < 4
                      ? AppTheme.error.withValues(alpha: 0.8)
                      : AppTheme.primaryColor.withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScatter(List<AcademicResult> items) {
    final valid = items
        .where((r) => r.diemHe10 != null && r.soTinChi > 0)
        .toList();
    if (valid.isEmpty) return _emptyChart('Chưa có dữ liệu');

    return _chartContainer(
      height: 240,
      child: ScatterChart(
        ScatterChartData(
          minX: 0,
          maxX: 8,
          minY: 0,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (v) => FlLine(color: _gridColor),
            getDrawingVerticalLine: (v) => FlLine(color: _gridColor),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: AppTheme.caption.copyWith(
                    fontSize: 10,
                    color: context.textMuted,
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: AppTheme.caption.copyWith(
                    fontSize: 10,
                    color: context.textMuted,
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          scatterSpots: valid.map((r) {
            return ScatterSpot(
              r.soTinChi.toDouble(),
              r.diemHe10!,
              dotPainter: FlDotCirclePainter(
                radius: 5,
                color: r.diemHe10! >= 4.0
                    ? AppTheme.primaryColor.withValues(alpha: 0.7)
                    : AppTheme.error.withValues(alpha: 0.7),
                strokeWidth: 0,
              ),
            );
          }).toList(),
          scatterLabelSettings: ScatterLabelSettings(showLabel: false),
        ),
      ),
    );
  }

  Widget _buildImpactTable(List<AcademicResult> items) {
    final valid = items
        .where((r) => r.diemHe10 != null && r.soTinChi > 0)
        .toList();
    if (valid.isEmpty) return _emptyChart('Chưa có dữ liệu');

    final avg = _gpa10(valid);
    final impactItems = valid.map((r) {
      return _ImpactRow(r, (avg - r.diemHe10!) * r.soTinChi);
    }).toList()..sort((a, b) => b.impact.compareTo(a.impact));

    final top8 = impactItems.take(8).toList();

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.scaffoldColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Học phần',
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Tác động ↓',
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textMuted,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Điểm · TC',
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textMuted,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          ...top8.map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      '${item.r.maHP ?? ''} — ${item.r.tenHP ?? ''}',
                      style: AppTheme.bodySmall.copyWith(
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.impact.toStringAsFixed(2),
                      style: AppTheme.bodySmall.copyWith(
                        color: item.impact > 0
                            ? AppTheme.error
                            : AppTheme.success,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.r.diemHe10?.toStringAsFixed(1)}/10 · ${item.r.soTinChi} TC',
                      style: AppTheme.caption.copyWith(
                        color: context.textMuted,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartContainer({required Widget child, double height = 220}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: child,
    );
  }

  Widget _emptyChart(String msg) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
      ),
      alignment: Alignment.center,
      child: Text(
        msg,
        style: AppTheme.bodySmall.copyWith(color: context.textSecondary),
      ),
    );
  }
}

class _ImpactRow {
  final AcademicResult r;
  final double impact;
  _ImpactRow(this.r, this.impact);
}
