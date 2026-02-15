import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/student_data.dart';
import '../utils/app_theme.dart';
import '../widgets/section_header.dart';

class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final data = provider.studentData;
        if (data == null)
          return const Center(child: CircularProgressIndicator());

        final passedCodes = <String>{};
        final failedCodes = <String>{};
        for (var r in data.ketQuaHocTap) {
          if (r.maHP == null) continue;
          if (r.diemHe10 != null && r.diemHe10! >= 4.0) {
            passedCodes.add(r.maHP!);
          } else if (r.diemHe10 != null && r.diemHe10! < 4.0) {
            failedCodes.add(r.maHP!);
          }
        }

        final grouped = <int, List<CurriculumItem>>{};
        for (var item in data.chuongTrinhDaoTao) {
          final hk = item.hocKy;
          if (hk == null) continue;
          grouped.putIfAbsent(hk, () => []).add(item);
        }
        final sortedKeys = grouped.keys.toList()..sort();

        if (sortedKeys.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book, size: 48, color: context.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Chưa có dữ liệu chương trình đào tạo',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final totalItems = data.chuongTrinhDaoTao.length;
        final passedCount = data.chuongTrinhDaoTao
            .where((c) => c.maHP != null && passedCodes.contains(c.maHP!))
            .length;
        final failedCount = data.chuongTrinhDaoTao
            .where(
              (c) =>
                  c.maHP != null &&
                  failedCodes.contains(c.maHP!) &&
                  !passedCodes.contains(c.maHP!),
            )
            .length;
        final notTaken = totalItems - passedCount - failedCount;

        return RefreshIndicator(
          onRefresh: () => context.read<StudentProvider>().loadData(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _buildProgressBar(
                context,
                passedCount,
                failedCount,
                notTaken,
                totalItems,
              ),
              const SizedBox(height: 8),
              _buildLegend(context),
              const SizedBox(height: 12),
              ...sortedKeys.map((hk) {
                final items = grouped[hk]!;
                return _buildSemesterGroup(
                  context,
                  hk,
                  items,
                  passedCodes,
                  failedCodes,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    int passed,
    int failed,
    int notTaken,
    int total,
  ) {
    final pPct = total > 0 ? passed / total : 0.0;
    final fPct = total > 0 ? failed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiến trình học tập',
            style: AppTheme.headingSmall.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: (pPct * 100).round(),
                    child: Container(color: AppTheme.success),
                  ),
                  if (fPct > 0)
                    Expanded(
                      flex: (fPct * 100).round(),
                      child: Container(color: AppTheme.error),
                    ),
                  Expanded(
                    flex: (100 - (pPct * 100).round() - (fPct * 100).round())
                        .clamp(0, 100),
                    child: Container(
                      color: context.isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$passed/$total đã hoàn thành',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              Text(
                '${(pPct * 100).toStringAsFixed(0)}%',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(context, AppTheme.success, 'Đã đạt'),
        const SizedBox(width: 16),
        _legendDot(context, AppTheme.error, 'Chưa đạt'),
        const SizedBox(width: 16),
        _legendDot(
          context,
          context.isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          'Chưa học',
        ),
      ],
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.caption.copyWith(color: context.textMuted)),
      ],
    );
  }

  Widget _buildSemesterGroup(
    BuildContext context,
    int semester,
    List<CurriculumItem> items,
    Set<String> passedCodes,
    Set<String> failedCodes,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Học kỳ $semester',
            icon: Icons.school_outlined,
            trailing: Text(
              '${items.length} môn',
              style: AppTheme.caption.copyWith(color: context.textMuted),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              Color bg;
              Color fg;
              IconData? icon;
              if (item.maHP != null && passedCodes.contains(item.maHP!)) {
                bg = AppTheme.success;
                fg = Colors.white;
                icon = Icons.check_circle_outline;
              } else if (item.maHP != null &&
                  failedCodes.contains(item.maHP!) &&
                  !passedCodes.contains(item.maHP!)) {
                bg = AppTheme.error;
                fg = Colors.white;
                icon = Icons.cancel_outlined;
              } else {
                bg = context.isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300;
                fg = context.textPrimary;
                icon = null;
              }
              return _SubjectChip(item: item, bg: bg, fg: fg, icon: icon);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final CurriculumItem item;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const _SubjectChip({
    required this.item,
    required this.bg,
    required this.fg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${item.maHP ?? ''} · ${item.soTinChi} TC',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                '${item.maHP ?? ''} · ${item.tenHP ?? ''} · ${item.soTinChi} TC',
                style: AppTheme.bodySmall.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
