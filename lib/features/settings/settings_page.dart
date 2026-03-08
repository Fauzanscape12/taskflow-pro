import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/theme_provider.dart';

/// Settings Page
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeMode = themeProvider.themeMode;
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.settings,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengaturan',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Kustomisasi aplikasi Anda',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Settings Sections
            SliverList(
              delegate: SliverChildListDelegate([
                // Appearance Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Tampilan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),

                // Theme Selector
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.palette_outlined, size: 20, color: AppConstants.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Tema',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // System
                          Expanded(
                            child: _ThemeOption(
                              icon: Icons.brightness_auto,
                              label: 'Sistem',
                              isSelected: themeMode == ThemeMode.system,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Light
                          Expanded(
                            child: _ThemeOption(
                              icon: Icons.light_mode,
                              label: 'Terang',
                              isSelected: themeMode == ThemeMode.light,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dark
                          Expanded(
                            child: _ThemeOption(
                              icon: Icons.dark_mode,
                              label: 'Gelap',
                              isSelected: themeMode == ThemeMode.dark,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                ListTile(
                  leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  title: const Text('Mode Gelap'),
                  subtitle: Text(isDark ? 'Mode gelap aktif' : 'Mode terang aktif'),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      if (value) {
                        themeProvider.setThemeMode(ThemeMode.dark);
                      } else {
                        themeProvider.setThemeMode(ThemeMode.light);
                      }
                      setState(() {});
                    },
                  ),
                ),

                const Divider(height: 32),

                // Notifications Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifikasi'),
                  subtitle: const Text('Ingatkan tentang tugas'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.volume_up_outlined),
                  title: const Text('Suara'),
                  subtitle: const Text('Suara notifikasi'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.vibration_outlined),
                  title: const Text('Getaran'),
                  subtitle: const Text('Getaran saat interaksi'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                    },
                  ),
                ),

                const Divider(height: 32),

                // Pomodoro Settings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Pomodoro',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Durasi Kerja'),
                  subtitle: Text('${AppConstants.pomodoroWorkMinutes} menit'),
                  trailing: Text('${AppConstants.pomodoroWorkMinutes} min'),
                ),
                ListTile(
                  leading: const Icon(Icons.coffee_outlined),
                  title: const Text('Istirahat Pendek'),
                  subtitle: Text('${AppConstants.pomodoroShortBreakMinutes} menit'),
                  trailing: Text('${AppConstants.pomodoroShortBreakMinutes} min'),
                ),
                ListTile(
                  leading: const Icon(Icons.weekend_outlined),
                  title: const Text('Istirahat Panjang'),
                  subtitle: Text('${AppConstants.pomodoroLongBreakMinutes} menit'),
                  trailing: Text('${AppConstants.pomodoroLongBreakMinutes} min'),
                ),

                const Divider(height: 32),

                // Productivity Features
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Fitur Produktivitas',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                _NavigationTile(
                  icon: Icons.timer_outlined,
                  title: 'Pomodoro Timer',
                  subtitle: 'Teknik fokus 25 menit',
                  route: '/timer',
                ),
                _NavigationTile(
                  icon: Icons.mic_outlined,
                  title: 'Perintah Suara',
                  subtitle: 'Tambah tugas dengan suara',
                  route: '/voice',
                ),
                _NavigationTile(
                  icon: Icons.category,
                  title: 'Kategori',
                  subtitle: 'Kelola kategori tugas',
                  route: '/categories',
                ),
                _NavigationTile(
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Template Proyek',
                  subtitle: 'Mulai proyek dengan template',
                  route: '/projects/templates',
                ),
                _NavigationTile(
                  icon: Icons.account_tree_outlined,
                  title: 'Ketergantungan Tugas',
                  subtitle: 'Atur hubungan antar tugas',
                  route: '/projects/dependencies',
                ),

                const Divider(height: 32),

                // Data Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Data & Sync',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined),
                  title: const Text('Backup Data'),
                  subtitle: const Text('Sinkronkan ke cloud (coming soon)'),
                  trailing: const Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined),
                  title: const Text('Restore Data'),
                  subtitle: const Text('Pulihkan dari backup (coming soon)'),
                  trailing: const Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: AppConstants.errorColor),
                  title: const Text('Hapus Semua Data'),
                  subtitle: const Text('Hapus semua tugas dan proyek'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Show confirmation dialog
                  },
                ),

                const Divider(height: 32),

                // About Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Tentang',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Versi'),
                  subtitle: Text(AppConstants.appVersion),
                  trailing: const Text('v1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.star_outline),
                  title: const Text('Beri Rating'),
                  subtitle: const Text('Beri rating di Play Store'),
                  trailing: const Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Kebijakan Privasi'),
                  trailing: const Icon(Icons.chevron_right),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryColor
              : AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppConstants.primaryColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppConstants.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(route);
      },
    );
  }
}
