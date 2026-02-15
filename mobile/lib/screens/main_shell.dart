import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'overview_screen.dart';
import 'transcript_screen.dart';
import 'curriculum_screen.dart';
import 'analytics_screen.dart';
import 'simulator_screen.dart';
import 'advisor_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabInfo('Tổng quan', Icons.dashboard_rounded, Icons.dashboard_outlined),
    _TabInfo('Bảng điểm', Icons.assignment_rounded, Icons.assignment_outlined),
    _TabInfo('CTĐT', Icons.menu_book_rounded, Icons.menu_book_outlined),
    _TabInfo('Phân tích', Icons.analytics_rounded, Icons.analytics_outlined),
    _TabInfo('Mô phỏng', Icons.science_rounded, Icons.science_outlined),
  ];

  final _screens = const [
    OverviewScreen(),
    TranscriptScreen(),
    CurriculumScreen(),
    AnalyticsScreen(),
    SimulatorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton:
          _currentIndex !=
              5 // Don't show on profile
          ? FloatingActionButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AdvisorScreen())),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
              tooltip: 'AI Cố vấn',
            )
          : null,
    );
  }

  AppBar _buildAppBar() {
    final titles = [
      'Tổng quan',
      'Bảng điểm',
      'Chương trình đào tạo',
      'Phân tích học tập',
      'Mô phỏng GPA',
    ];
    return AppBar(
      title: Text(titles[_currentIndex]),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          icon: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 18, color: Colors.white),
          ),
          tooltip: 'Hồ sơ',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isActive = _currentIndex == i;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _currentIndex = i),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primaryColor.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          size: 22,
                          color: isActive
                              ? AppTheme.primaryColor
                              : context.textMuted,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isActive
                                ? AppTheme.primaryColor
                                : context.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  final String label;
  final IconData activeIcon;
  final IconData icon;
  const _TabInfo(this.label, this.activeIcon, this.icon);
}
