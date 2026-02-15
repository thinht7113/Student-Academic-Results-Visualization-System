import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/student_data.dart';
import '../utils/app_theme.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({super.key});

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  String _selectedSemester = 'Tất cả';
  bool _failOnly = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AcademicResult> _filter(List<AcademicResult> items) {
    var filtered = items.toList();

    if (_selectedSemester != 'Tất cả') {
      final sem = _selectedSemester.replaceAll('Học kỳ ', '');
      filtered = filtered.where((r) => r.hocKy == sem).toList();
    }

    if (_failOnly) {
      filtered = filtered
          .where((r) => r.diemHe10 != null && r.diemHe10! < 4.0)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (r) =>
                (r.maHP?.toLowerCase().contains(q) ?? false) ||
                (r.tenHP?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    return filtered;
  }

  double _weightedGPA(List<AcademicResult> items) {
    double sum = 0;
    int credits = 0;
    for (var r in items) {
      if (r.diemHe10 != null && r.soTinChi > 0) {
        sum += r.diemHe10! * r.soTinChi;
        credits += r.soTinChi;
      }
    }
    return credits == 0 ? 0 : sum / credits;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final data = provider.studentData;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final semesters = data.semesters;
        final allItems = _filter(data.ketQuaHocTap);
        final grouped = <int, List<AcademicResult>>{};
        for (var r in allItems) {
          final hk = int.tryParse(r.hocKy ?? '');
          if (hk != null) {
            grouped.putIfAbsent(hk, () => []).add(r);
          }
        }
        final sortedKeys = grouped.keys.toList()..sort();

        final totalCredits = allItems.fold<int>(0, (s, r) => s + r.soTinChi);
        final overallGPA = _weightedGPA(allItems);

        return Column(
          children: [
            _buildFilterBar(semesters),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<StudentProvider>().loadData(),
                child: allItems.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'Không tìm thấy kết quả',
                                style: AppTheme.bodySmall.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: sortedKeys.length,
                        itemBuilder: (context, index) {
                          final hk = sortedKeys[index];
                          final items = grouped[hk]!;
                          return _buildSemesterGroup(hk, items);
                        },
                      ),
              ),
            ),
            _buildFooter(overallGPA, totalCredits),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(List<int> semesters) {
    return Container(
      color: context.cardColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.scaffoldColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSemester,
                    isDense: true,
                    style: AppTheme.bodySmall.copyWith(
                      color: context.textPrimary,
                    ),
                    dropdownColor: context.cardColor,
                    items: [
                      const DropdownMenuItem(
                        value: 'Tất cả',
                        child: Text('Tất cả'),
                      ),
                      ...semesters.map(
                        (s) => DropdownMenuItem(
                          value: 'Học kỳ $s',
                          child: Text('HK $s'),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedSemester = v!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(
                  'Chưa đạt',
                  style: AppTheme.caption.copyWith(
                    color: _failOnly ? Colors.white : context.textSecondary,
                  ),
                ),
                selected: _failOnly,
                onSelected: (v) => setState(() => _failOnly = v),
                selectedColor: AppTheme.error,
                checkmarkColor: Colors.white,
                backgroundColor: context.scaffoldColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _searchCtrl,
                    style: AppTheme.bodySmall.copyWith(
                      color: context.textPrimary,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      prefixIconConstraints: const BoxConstraints(minWidth: 32),
                      hintText: 'Tìm...',
                      hintStyle: AppTheme.caption.copyWith(
                        color: context.textMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.borderColor),
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
        ],
      ),
    );
  }

  Widget _buildSemesterGroup(int semester, List<AcademicResult> items) {
    final semGPA = _weightedGPA(items);
    final semCredits = items.fold<int>(0, (s, r) => s + r.soTinChi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.accentBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'HỌC KỲ $semester',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                'GPA: ${semGPA.toStringAsFixed(2)} · $semCredits TC',
                style: AppTheme.caption.copyWith(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ...items.map((r) => _buildGradeRow(r)),
      ],
    );
  }

  Widget _buildGradeRow(AcademicResult r) {
    final isPassed = r.isPassed;
    final isFailed = r.isFailed;
    final bgColor = isFailed
        ? (context.isDark
              ? AppTheme.error.withValues(alpha: 0.15)
              : AppTheme.errorLight)
        : isPassed
        ? (context.isDark
              ? AppTheme.success.withValues(alpha: 0.1)
              : AppTheme.successLight)
        : context.cardColor;
    final scoreColor = isFailed
        ? AppTheme.error
        : isPassed
        ? (context.isDark ? AppTheme.success : AppTheme.successDark)
        : context.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.tenHP ?? '',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${r.maHP ?? ''} · ${r.soTinChi} TC',
                  style: AppTheme.caption.copyWith(color: context.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  r.diemHe10?.toStringAsFixed(1) ?? '—',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  'Hệ 10',
                  style: AppTheme.caption.copyWith(
                    fontSize: 9,
                    color: context.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Text(
                  r.diemHe4?.toStringAsFixed(1) ?? '—',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
                Text(
                  'Hệ 4',
                  style: AppTheme.caption.copyWith(
                    fontSize: 9,
                    color: context.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              r.diemChu ?? '—',
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double gpa, int totalCredits) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'GPA (10): ',
            style: AppTheme.bodySmall.copyWith(color: context.textSecondary),
          ),
          Text(
            gpa.toStringAsFixed(2),
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Tổng tín chỉ: ',
            style: AppTheme.bodySmall.copyWith(color: context.textSecondary),
          ),
          Text(
            '$totalCredits',
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
