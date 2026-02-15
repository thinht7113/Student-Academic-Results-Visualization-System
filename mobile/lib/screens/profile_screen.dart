import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/student_provider.dart';
import '../providers/theme_provider.dart';
import '../models/student_data.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          final data = provider.studentData;
          if (data == null)
            return const Center(child: CircularProgressIndicator());

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // Avatar + Name
              _buildProfileHeader(context, data),
              const SizedBox(height: 20),

              // Info card
              _buildInfoCard(context, data),
              const SizedBox(height: 16),

              // Academic summary
              _buildAcademicSummary(context, data),
              const SizedBox(height: 16),

              // Dark mode toggle
              _buildThemeToggle(context),
              const SizedBox(height: 24),

              // Logout button
              _buildLogoutButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, StudentData data) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                data.hoTen.isNotEmpty ? data.hoTen[0].toUpperCase() : '?',
                style: AppTheme.headingLarge.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.hoTen,
            style: AppTheme.headingMedium.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            data.maSV,
            style: AppTheme.bodySmall.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, StudentData data) {
    final fields = [
      ('Mã SV', data.maSV, Icons.badge_outlined),
      ('Họ tên', data.hoTen, Icons.person_outline),
      ('Lớp', data.lop, Icons.group_outlined),
      ('Ngành', data.nganh, Icons.school_outlined),
      ('Khoa', data.khoa, Icons.business_outlined),
      ('Email', data.email, Icons.email_outlined),
    ];

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Hồ sơ sinh viên',
              style: AppTheme.headingSmall.copyWith(color: context.textPrimary),
            ),
          ),
          const Divider(height: 1),
          ...fields.map((f) => _infoRow(context, f.$1, f.$2, f.$3)),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String? value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(color: context.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSummary(BuildContext context, StudentData data) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan học tập',
            style: AppTheme.headingSmall.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryItem(
                context,
                'CPA (10)',
                data.currentGPA10.toStringAsFixed(2),
                AppTheme.primaryColor,
                Icons.stars,
              ),
              const SizedBox(width: 12),
              _summaryItem(
                context,
                'TC đạt',
                '${data.creditsPassed}',
                AppTheme.success,
                Icons.check_circle_outline,
              ),
              const SizedBox(width: 12),
              _summaryItem(
                context,
                'TC nợ',
                '${data.creditsDebt}',
                data.creditsDebt > 0 ? AppTheme.error : context.textMuted,
                Icons.warning_amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: AppTheme.headingSmall.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTheme.caption.copyWith(color: context.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system && context.isDark);

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
      ),
      child: ListTile(
        leading: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: AppTheme.primaryColor,
        ),
        title: Text(
          'Chế độ tối',
          style: AppTheme.bodyMedium.copyWith(color: context.textPrimary),
        ),
        subtitle: Text(
          isDark ? 'Đang bật' : 'Đang tắt',
          style: AppTheme.caption.copyWith(color: context.textSecondary),
        ),
        trailing: Switch(
          value: isDark,
          onChanged: (_) => themeProvider.toggle(),
          activeTrackColor: AppTheme.primaryColor,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final auth = context.read<AuthProvider>();
          final student = context.read<StudentProvider>();
          await auth.logout();
          student.clear();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, color: AppTheme.error),
        label: Text(
          'Đăng xuất',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.error),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: AppTheme.error.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
