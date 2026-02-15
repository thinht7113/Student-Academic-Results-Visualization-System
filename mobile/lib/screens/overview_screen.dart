import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/student_provider.dart';
import '../models/student_data.dart';
import '../utils/app_theme.dart';
import '../widgets/kpi_card.dart';
import '../widgets/section_header.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = provider.studentData;
        if (data == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 48, color: context.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Không có dữ liệu',
                  style: AppTheme.bodyLarge.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => provider.loadData(),
                  child: const Text('Tải lại'),
                ),
              ],
            ),
          );
        }
        return _OverviewBody(data: data);
      },
    );
  }
}

class _OverviewBody extends StatelessWidget {
  final StudentData data;
  const _OverviewBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final gpa = data.currentGPA10;
    final letter = StudentData.letterFrom10(gpa);
    final semGPA = data.gpaBySemester;
    final topGood = data.topSubjects(5);
    final topBad = data.topSubjects(5, ascending: true);

    return RefreshIndicator(
      onRefresh: () => context.read<StudentProvider>().loadData(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Greeting
          Text(
            'Xin chào, ${data.hoTen} 👋',
            style: AppTheme.headingLarge.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Mã SV: ${data.maSV}',
            style: AppTheme.bodySmall.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 20),

          // KPI Cards
          _buildKPIRow(context, gpa, letter),
          const SizedBox(height: 12),

          // Warning
          if (data.creditsDebt > 0) ...[
            _buildWarningBanner(context),
            const SizedBox(height: 16),
          ],

          // GPA Trend
          SectionHeader(
            title: 'Xu hướng GPA theo kỳ',
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 4),
          _buildGPATrendChart(context, semGPA),
          const SizedBox(height: 24),

          // Top 5 Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTopList(
                  context,
                  '🏆 Top 5 điểm cao',
                  topGood,
                  true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTopList(
                  context,
                  '⚠️ Cần cải thiện',
                  topBad,
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPIRow(BuildContext context, double gpa, String letter) {
    return Row(
      children: [
        // GPA Donut
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: context.cardShadow,
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: gpa / 10,
                          strokeWidth: 6,
                          backgroundColor: context.isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            AppTheme.gradeColor(letter),
                          ),
                        ),
                      ),
                      Text(
                        gpa.toStringAsFixed(1),
                        style: AppTheme.headingSmall.copyWith(
                          fontSize: 15,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CPA tích lũy',
                        style: AppTheme.caption.copyWith(
                          color: context.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        letter,
                        style: AppTheme.kpiValue.copyWith(
                          color: AppTheme.gradeColor(letter),
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            title: 'TC ĐẠT',
            value: '${data.creditsPassed}',
            color: AppTheme.success,
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            title: 'TC NỢ',
            value: '${data.creditsDebt}',
            color: data.creditsDebt > 0 ? AppTheme.error : context.textMuted,
            icon: Icons.warning_amber_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBanner(BuildContext context) {
    final bgColor = context.isDark
        ? const Color(0xFF78350F).withValues(alpha: 0.3)
        : AppTheme.warningLight;
    final borderColor = AppTheme.warning.withValues(alpha: 0.4);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: context.isDark ? AppTheme.warning : const Color(0xFFB45309),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bạn đang có ${data.creditsDebt} tín chỉ nợ. Ưu tiên đăng ký các học phần cần cải thiện.',
              style: AppTheme.bodySmall.copyWith(
                color: context.isDark
                    ? AppTheme.warning
                    : const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPATrendChart(BuildContext context, List<SemesterGPA> semGPA) {
    if (semGPA.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.cardShadow,
        ),
        alignment: Alignment.center,
        child: Text(
          'Chưa có dữ liệu',
          style: AppTheme.bodySmall.copyWith(color: context.textSecondary),
        ),
      );
    }

    final gridColor = context.isDark
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: gridColor, strokeWidth: 1),
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
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= semGPA.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'HK${semGPA[i].semester}',
                      style: AppTheme.caption.copyWith(
                        fontSize: 10,
                        color: context.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTheme.caption.copyWith(
                      fontSize: 10,
                      color: context.textMuted,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                semGPA.length,
                (i) => FlSpot(i.toDouble(), semGPA[i].gpa10),
              ),
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppTheme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (s, d, bar, i) => FlDotCirclePainter(
                  radius: 4,
                  color: context.cardColor,
                  strokeWidth: 2.5,
                  strokeColor: AppTheme.primaryColor,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                return LineTooltipItem(
                  'HK${semGPA[s.spotIndex].semester}\n${s.y.toStringAsFixed(2)}',
                  AppTheme.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopList(
    BuildContext context,
    String title,
    List<AcademicResult> subjects,
    bool isGood,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headingSmall.copyWith(
              fontSize: 13,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...subjects.map((r) {
            final score = r.diemHe10 ?? 0;
            final color = isGood ? AppTheme.success : AppTheme.error;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.tenHP ?? r.maHP ?? '',
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${r.maHP ?? ''} · ${r.soTinChi} TC',
                          style: AppTheme.caption.copyWith(
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      score.toStringAsFixed(1),
                      style: AppTheme.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
