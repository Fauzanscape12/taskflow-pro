import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:convert';

import '../tasks/bloc/task_bloc.dart';
import '../../data/datasources/local/database.dart';
import '../../core/constants/app_constants.dart';

/// Project Templates Page
class ProjectTemplatesPage extends StatefulWidget {
  const ProjectTemplatesPage({super.key});

  @override
  State<ProjectTemplatesPage> createState() => _ProjectTemplatesPageState();
}

class _ProjectTemplatesPageState extends State<ProjectTemplatesPage> {
  List<ProjectTemplate> _customTemplates = [];
  bool _isUsingTemplate = false;

  @override
  void initState() {
    super.initState();
    _loadCustomTemplates();
    context.read<TaskBloc>().add(LoadTasks());
  }

  Future<void> _loadCustomTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList('custom_templates') ?? [];
      if (mounted) {
        setState(() {
          _customTemplates = templatesJson.map((json) {
            return ProjectTemplate.fromJson(jsonDecode(json));
          }).toList();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveCustomTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = _customTemplates.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList('custom_templates', templatesJson);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _addCustomTemplate(ProjectTemplate template) async {
    setState(() {
      _customTemplates.add(template);
    });
    await _saveCustomTemplates();
  }

  Future<void> _deleteCustomTemplate(String id) async {
    setState(() {
      _customTemplates.removeWhere((t) => t.id == id);
    });
    await _saveCustomTemplates();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Proyek'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTemplateDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured Section
              Text(
                'Template Populer',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildFeaturedTemplates(context),

              const SizedBox(height: 32),

              // Categories
              Text(
                'Kategori',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildTemplateCategories(context),

              const SizedBox(height: 32),

              // Personal Templates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Template Saya',
                    style: theme.textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: () => _showManageTemplatesDialog(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Kelola'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMyTemplates(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedTemplates(BuildContext context) {
    return Column(
      children: PredefinedTemplates.featured.map((template) {
        return _buildTemplateCard(context, template: template);
      }).toList(),
    );
  }

  Widget _buildTemplateCategories(BuildContext context) {
    final categories = [
      {'name': 'Produktivitas', 'icon': '🚀', 'color': '#6366F1'},
      {'name': 'Keuangan', 'icon': '💰', 'color': '#10B981'},
      {'name': 'Hobi', 'icon': '🎨', 'color': '#EC4899'},
      {'name': 'Rumah', 'icon': '🏠', 'color': '#F59E0B'},
      {'name': 'Travel', 'icon': '✈️', 'color': '#8B5CF6'},
    ];

    return Wrap(
      spacing: 12,
      children: categories.map((cat) {
        final colorStr = cat['color'] as String;
        final color = _colorFromHex(colorStr);
        return GestureDetector(
          onTap: () => _showCategoryTemplates(context, cat['name'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cat['icon'] as String,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  cat['name']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMyTemplates(BuildContext context) {
    final theme = Theme.of(context);

    if (_customTemplates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.folder_off_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada template kustom',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _showCreateTemplateDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Buat Template'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _customTemplates.map((template) {
        return Dismissible(
          key: Key(template.id),
          onDismissed: (direction) {
            _deleteCustomTemplate(template.id);
          },
          child: _buildTemplateCard(context, template: template, isCustom: true),
        );
      }).toList(),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context, {
    required ProjectTemplate template,
    bool isCustom = false,
  }) {
    final theme = Theme.of(context);
    final templateColor = _colorFromHex(template.color);

    return GestureDetector(
      onTap: () => _showTemplateDetail(context, template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              templateColor.withOpacity(0.1),
              templateColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: templateColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  template.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: templateColor,
                        ),
                      ),
                      Text(
                        template.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCustom)
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: templateColor.withOpacity(0.7),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Tasks Preview
            Text(
              '${template.tasks.length} tugas termasuk',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 12),

            // Sample tasks
            ...template.tasks.take(3).map((task) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      task['default'] == true
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 16,
                      color: task['default'] == true
                          ? templateColor
                          : theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task['title'],
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),

            if (template.tasks.length > 3) ...[
              const SizedBox(height: 8),
              Text(
                '+${template.tasks.length - 3} lagi...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  void _showTemplateDetail(BuildContext context, ProjectTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) {
        return _buildTemplateDetailSheet(bottomContext, template);
      },
    );
  }

  Widget _buildTemplateDetailSheet(
    BuildContext context,
    ProjectTemplate template,
  ) {
    final theme = Theme.of(context);
    final templateColor = _colorFromHex(template.color);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            template.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            template.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: templateColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        template.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: template.tasks.length,
              itemBuilder: (context, index) {
                final task = template.tasks[index];
                return CheckboxListTile(
                  value: task['default'] ?? false,
                  onChanged: null,
                  activeColor: templateColor,
                  title: Text(task['title']),
                  subtitle: task['description'] != null && task['description'].toString().isNotEmpty
                      ? Text(task['description'].toString())
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),

          // Create Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: FilledButton(
              onPressed: _isUsingTemplate
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _useTemplate(context, template);
                    },
              style: FilledButton.styleFrom(
                backgroundColor: templateColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: templateColor.withOpacity(0.5),
              ),
              child: _isUsingTemplate
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Gunakan Template Ini'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryTemplates(BuildContext context, String category) {
    // Show templates for specific category from predefined
    final categoryTemplates = PredefinedTemplates.all
        .where((t) => t.category.toLowerCase() == category.toLowerCase())
        .toList();

    if (categoryTemplates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak ada template untuk kategori $category'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Template $category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: categoryTemplates.length,
                  itemBuilder: (context, index) {
                    final template = categoryTemplates[index];
                    return ListTile(
                      leading: Text(template.icon, style: const TextStyle(fontSize: 24)),
                      title: Text(template.name),
                      subtitle: Text(template.description),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(bottomContext).pop();
                        _showTemplateDetail(context, template);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showManageTemplatesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (bottomContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kelola Template',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Buat Template Baru'),
                onTap: () {
                  Navigator.of(bottomContext).pop();
                  _showCreateTemplateDialog(context);
                },
              ),
              if (_customTemplates.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.delete_sweep, color: Colors.red),
                  title: const Text('Hapus Semua Template', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(bottomContext).pop();
                    _showDeleteAllConfirmation(context);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Semua Template'),
        content: const Text('Apakah Anda yakin ingin menghapus semua template kustom?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _customTemplates.clear();
              });
              _saveCustomTemplates();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua template berhasil dihapus'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showCreateTemplateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final iconController = TextEditingController(text: '📁');
    final colorController = TextEditingController(text: '#6366F1');
    List<Map<String, dynamic>> tasks = [];
    List<TextEditingController> taskControllers = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final theme = Theme.of(context);

          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Buat Template Baru',
                          style: theme.textTheme.titleLarge,
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Template',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: iconController,
                            decoration: InputDecoration(
                              labelText: 'Icon (emoji)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: colorController,
                            decoration: InputDecoration(
                              labelText: 'Warna (#HEX)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tasks section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tugas (${tasks.length})',
                          style: theme.textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setSheetState(() {
                              tasks.add({'title': '', 'default': false});
                              taskControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ...tasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      // Ensure controller exists
                      while (taskControllers.length <= index) {
                        taskControllers.add(TextEditingController());
                      }
                      final taskController = taskControllers[index];
                      // Set initial value
                      if (taskController.text.isEmpty && task['title'] != null) {
                        taskController.text = task['title'] ?? '';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: taskController,
                                decoration: InputDecoration(
                                  hintText: 'Nama tugas',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  tasks[index]['title'] = value;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Checkbox(
                              value: task['default'] ?? false,
                              onChanged: (value) {
                                setSheetState(() {
                                  tasks[index]['default'] = value ?? false;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setSheetState(() {
                                  tasks.removeAt(index);
                                  if (index < taskControllers.length) {
                                    taskControllers.removeAt(index);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama template tidak boleh kosong'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final validTasks = tasks.where((t) => t['title'].toString().trim().isNotEmpty).toList();
                        if (validTasks.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Minimal satu tugas harus diisi'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final template = ProjectTemplate(
                          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameController.text.trim(),
                          icon: iconController.text.trim().isEmpty ? '📁' : iconController.text.trim().substring(0, 1),
                          description: descriptionController.text.trim(),
                          category: 'Custom',
                          color: colorController.text.trim().isEmpty ? '#6366F1' : colorController.text.trim(),
                          tasks: validTasks,
                        );

                        _addCustomTemplate(template).then((_) {
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Template berhasil dibuat'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan Template'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _useTemplate(BuildContext context, ProjectTemplate template) async {
    if (_isUsingTemplate) return;

    setState(() {
      _isUsingTemplate = true;
    });

    try {
      // Create tasks from template
      final now = DateTime.now();
      final taskBloc = context.read<TaskBloc>();

      for (final taskData in template.tasks) {
        final task = TasksCompanion.insert(
          title: taskData['title'],
          description: taskData['description'] != null && taskData['description'].toString().isNotEmpty
              ? drift.Value(taskData['description'])
              : const drift.Value(null),
          priority: const drift.Value(3),
          status: taskData['default'] == true ? const drift.Value(2) : const drift.Value(1),
          dueDate: drift.Value(now),
          createdAt: drift.Value(now),
          labels: drift.Value('template:${template.id}'),
        );

        taskBloc.add(AddTask(task));
      }

      // Wait a bit for tasks to be added
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${template.tasks.length} tugas dari template "${template.name}" berhasil dibuat!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Lihat',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat tugas: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUsingTemplate = false;
        });
      }
    }
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

/// Project Template Data Model
class ProjectTemplate {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String category;
  final String color;
  final List<Map<String, dynamic>> tasks;

  ProjectTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.category,
    required this.color,
    required this.tasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'category': category,
      'color': color,
      'tasks': tasks,
    };
  }

  factory ProjectTemplate.fromJson(Map<String, dynamic> json) {
    return ProjectTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Custom',
      color: json['color'] as String? ?? '#6366F1',
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }
}

/// Predefined Templates
class PredefinedTemplates {
  static List<ProjectTemplate> get featured => [
        ProjectTemplate(
          id: 'work',
          name: 'Pekerjaan',
          icon: '💼',
          description: 'Kelola tugas harian, meeting, deadline',
          category: 'Work',
          color: '#3B82F6',
          tasks: [
            {'title': 'Email & komunikasi', 'default': true},
            {'title': 'Deep work', 'default': true},
            {'title': 'Meeting harian'},
            {'title': 'Review harian'},
            {'title': 'Planning besok'},
          ],
        ),
        ProjectTemplate(
          id: 'learning',
          name: 'Belajar',
          icon: '📚',
          description: 'Track progress belajar skill baru',
          category: 'Personal',
          color: '#10B981',
          tasks: [
            {'title': 'Baca buku', 'default': true},
            {'title': 'Praktik'},
            {'title': 'Note taking'},
            {'title': 'Review'},
            {'title': 'Quiz/kuis'},
          ],
        ),
        ProjectTemplate(
          id: 'health',
          name: 'Kesehatan',
          icon: '🏃',
          description: 'Jaga kebugaran & kesehatan tubuh',
          category: 'Health',
          color: '#EF4444',
          tasks: [
            {'title': 'Olahraga pagi', 'default': true},
            {'title': 'Minum air'},
            {'title': 'Makan sehat'},
            {'title': 'Tidur cukup'},
            {'title': 'Meditasi'},
          ],
        ),
      ];

  static List<ProjectTemplate> get all => [
        ...featured,
        ProjectTemplate(
          id: 'daily',
          name: 'Daily Routine',
          icon: '📅',
          description: 'Kegiatan sehari-hari',
          category: 'Personal',
          color: '#6366F1',
          tasks: [
            {'title': 'Bangun & bersiap', 'default': true},
            {'title': 'Sarapan', 'default': true},
            {'title': 'Kerja 1'},
            {'title': 'Istirahat'},
            {'title': 'Kerja 2'},
            {'title': 'Makan siang', 'default': true},
            {'title': 'Kerja 3'},
            {'title': 'Olahraga sore', 'default': true},
            {'title': 'Makan malam'},
            {'title': 'Bersiap tidur'},
          ],
        ),
        ProjectTemplate(
          id: 'study_flutter',
          name: 'Belajar Flutter',
          icon: '🎯',
          description: 'Belajar Flutter dari dasar',
          category: 'Learning',
          color: '#42A5F5',
          tasks: [
            {'title': 'Install Flutter SDK'},
            {'title': 'Setup environment'},
            {'title': 'Belajar Widgets', 'default': true},
            {'title': 'State management'},
            {'title': 'API integration'},
            {'title': 'Deployment', 'default': true},
          ],
        ),
        ProjectTemplate(
          id: 'house_renovation',
          name: 'Renovasi Rumah',
          icon: '🏠',
          description: 'Perencana renovasi rumah',
          category: 'Home',
          color: '#F59E0B',
          tasks: [
            {'title': 'Survey & anggaran'},
            {'title': 'Desain layout'},
            {'title': 'Pilih kontraktor'},
            {'title': 'Konstruksi'},
            {'title': 'Finishing'},
          ],
        ),
        ProjectTemplate(
          id: 'vacation_planning',
          name: 'Perencanaan Liburan',
          icon: '✈️',
          description: 'Rencana liburan yang lengkap',
          category: 'Travel',
          color: '#8B5CF6',
          tasks: [
            {'title': 'Pilih destinasi'},
            {'title': 'Booking tiket'},
            {'title': 'Akomodasi'},
            {'title': 'Itinerary'},
            {'title': 'Packing list'},
            {'title': 'Dokumen perjalanan'},
          ],
        ),
      ];
}
