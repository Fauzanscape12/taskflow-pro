import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/task_category.dart';
import '../../core/constants/app_constants.dart';

/// Halaman Kategori - Untuk mengelola kategori tugas
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  // List kategori user (termasuk predefined + custom)
  final List<TaskCategory> _userCategories = List.from(PredefinedCategories.all);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, theme),

            // Categories Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: _userCategories.length + 1, // +1 untuk add button
                itemBuilder: (context, index) {
                  // Add new category button
                  if (index == _userCategories.length) {
                    return _buildAddCategoryCard(context, theme);
                  }
                  return _buildCategoryCard(context, theme, _userCategories[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori',
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    '${_userCategories.length} kategori',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    ThemeData theme,
    TaskCategory category,
  ) {
    return GestureDetector(
      onTap: () => _showCategoryOptions(context, category),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category.colorValue.withOpacity(0.15),
              category.colorValue.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: category.colorValue.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: category.colorValue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              category.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildAddCategoryCard(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showCreateCategoryDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.add,
                color: AppConstants.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Buat Baru',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  void _showCategoryOptions(BuildContext context, TaskCategory category) {
    final isPredefined = PredefinedCategories.all.any((c) => c.id == category.id);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category preview
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: category.colorValue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(category.icon, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isPredefined)
                        Text(
                          'Kategori bawaan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            // Options
            if (!isPredefined) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Kategori'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCategoryDialog(context, category);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
                title: Text(
                  'Hapus Kategori',
                  style: TextStyle(color: Colors.red.shade400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteCategory(context, category);
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Kategori bawaan tidak bisa dihapus'),
                subtitle: const Text('Tapi Anda bisa membuat kategori custom'),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    String name = '';
    String selectedIcon = PredefinedCategories.categoryIcons.first['emoji']!;
    String selectedColor = PredefinedCategories.categoryColors.first['color']!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Buat Kategori Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name input
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Misal: Gaming',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 20),

                // Icon picker
                const Text('Pilih Icon', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: PredefinedCategories.categoryIcons.take(24).length,
                    itemBuilder: (context, index) {
                      final icon = PredefinedCategories.categoryIcons[index];
                      final isSelected = selectedIcon == icon['emoji'];
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedIcon = icon['emoji']!),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppConstants.primaryColor.withOpacity(0.2) : null,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected ? AppConstants.primaryColor : Colors.transparent,
                            ),
                          ),
                          child: Center(child: Text(icon['emoji']!, style: const TextStyle(fontSize: 20))),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Color picker
                const Text('Pilih Warna', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: PredefinedCategories.categoryColors.length,
                    itemBuilder: (context, index) {
                      final color = PredefinedCategories.categoryColors[index];
                      final colorValue = _colorFromHex(color['color']!);
                      final isSelected = selectedColor == color['color'];
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = color['color']!),
                        child: Container(
                          width: 32,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: colorValue,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: name.trim().isEmpty
                  ? null
                  : () {
                      _addCategory(TaskCategory(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        name: name.trim(),
                        icon: selectedIcon,
                        color: selectedColor,
                      ));
                      Navigator.pop(context);
                    },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, TaskCategory category) {
    String name = category.name;
    String selectedIcon = category.icon;
    String selectedColor = category.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name input
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 20),

                // Icon picker
                const Text('Pilih Icon', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: PredefinedCategories.categoryIcons.take(24).length,
                    itemBuilder: (context, index) {
                      final icon = PredefinedCategories.categoryIcons[index];
                      final isSelected = selectedIcon == icon['emoji'];
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedIcon = icon['emoji']!),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppConstants.primaryColor.withOpacity(0.2) : null,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected ? AppConstants.primaryColor : Colors.transparent,
                            ),
                          ),
                          child: Center(child: Text(icon['emoji']!, style: const TextStyle(fontSize: 20))),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Color picker
                const Text('Pilih Warna', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: PredefinedCategories.categoryColors.length,
                    itemBuilder: (context, index) {
                      final color = PredefinedCategories.categoryColors[index];
                      final colorValue = _colorFromHex(color['color']!);
                      final isSelected = selectedColor == color['color'];
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = color['color']!),
                        child: Container(
                          width: 32,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: colorValue,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: name.trim().isEmpty
                  ? null
                  : () {
                      _updateCategory(category.copyWith(
                        name: name.trim(),
                        icon: selectedIcon,
                        color: selectedColor,
                      ));
                      Navigator.pop(context);
                    },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Kategori'),
        content: const Text(
          'Kategori membantu Anda mengelompokkan tugas berdasarkan tema atau aktivitas. '
          'Anda bisa menggunakan kategori bawaan atau membuat kategori custom sesuai kebutuhan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, TaskCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () {
              _deleteCategory(category);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _addCategory(TaskCategory category) {
    setState(() {
      _userCategories.add(category);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kategori "${category.name}" berhasil dibuat')),
    );
  }

  void _updateCategory(TaskCategory category) {
    setState(() {
      final index = _userCategories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _userCategories[index] = category;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kategori "${category.name}" berhasil diperbarui')),
    );
  }

  void _deleteCategory(TaskCategory category) {
    setState(() {
      _userCategories.removeWhere((c) => c.id == category.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kategori "${category.name}" berhasil dihapus')),
    );
  }

  Color _colorFromHex(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 7 && hexColor[0] == '#') {
      buffer.write('0xFF');
      buffer.write(hexColor.substring(1));
    } else if (hexColor.length == 6) {
      buffer.write('0xFF');
      buffer.write(hexColor);
    }
    return Color(int.parse(buffer.toString()));
  }
}
