import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'home/home_screen.dart';
import 'placeholder_screen.dart';

/// Shell navigasi utama aplikasi AgroPlan yang membungkus 5 tab utama.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Daftar layar untuk masing-masing tab
  final List<Widget> _screens = const [
    HomeScreen(),
    PlaceholderScreen(
      title: 'Manajemen Lahan',
      subtitle: 'Modul 1: FR-01 s/d FR-04 (Kelola data lahan pertanian Anda).',
      icon: Icons.yard_outlined,
    ),
    PlaceholderScreen(
      title: 'Siklus Tanam',
      subtitle: 'Modul 1: FR-05 & FR-06 (Perencanaan tanggal tanam dan pengingat).',
      icon: Icons.calendar_month_outlined,
    ),
    PlaceholderScreen(
      title: 'Pusat Notifikasi',
      subtitle: 'Notifikasi pengingat rencana tanam, peringatan risiko, dan jatuh tempo perawatan.',
      icon: Icons.notifications_active_outlined,
    ),
    PlaceholderScreen(
      title: 'Profil Petani',
      subtitle: 'Informasi akun pengguna dan pengaturan aplikasi AgroPlan.',
      icon: Icons.person_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: AppSpacing.bottomNavHeight + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.primaryNav,
          unselectedItemColor: AppColors.iconMuted,
          selectedLabelStyle: AppTextStyles.bottomNavLabel.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryNav,
          ),
          unselectedLabelStyle: AppTextStyles.bottomNavLabel.copyWith(
            color: AppColors.iconMuted,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.yard_outlined),
              activeIcon: Icon(Icons.yard),
              label: 'Lahan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Tanam',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_outlined),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.badgeRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              activeIcon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.badgeRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              label: 'Notifikasi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
