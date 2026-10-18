import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_project_model.dart';
import '../../models/admission_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/categorized_student_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminProjectsPage extends ConsumerStatefulWidget {
  const AdminProjectsPage({super.key});

  @override
  ConsumerState<AdminProjectsPage> createState() => _AdminProjectsPageState();
}

class _AdminProjectsPageState extends ConsumerState<AdminProjectsPage> {
  String _searchQuery = '';

  void _showProjectDialog({GameProjectModel? project}) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final approvedAdmissions = await firestoreService.getAdmissions(status: 'approved').first;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => _ProjectFormDialog(
        project: project,
        students: approvedAdmissions,
      ),
    );
  }

  void _launchUrl(String? urlStr) async {
    if (urlStr == null || urlStr.trim().isEmpty) return;
    final uri = Uri.parse(urlStr.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(msg: 'Could not launch URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 700 ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 650;
            final headerInfo = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('MAI Gaming Studio Projects',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
                SizedBox(height: 6),
                Text('Manage student-developed games and public portfolio showcase.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 14)),
              ],
            );

            final action = ElevatedButton.icon(
              onPressed: () => _showProjectDialog(),
              icon: const Icon(Icons.sports_esports_rounded, size: 18),
              label: const Text('Add Game Project'),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerInfo,
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: action),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: headerInfo),
                const SizedBox(width: 16),
                action,
              ],
            );
          }),
          const SizedBox(height: 32),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by Game Title, Developer Name, or Genre...',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          const SizedBox(height: 32),

          StreamBuilder<List<GameProjectModel>>(
            stream: firestoreService.getGameProjects(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(80), child: CircularProgressIndicator()));
              }

              var projects = snapshot.data ?? [];
              if (_searchQuery.isNotEmpty) {
                projects = projects.where((p) =>
                  p.title.toLowerCase().contains(_searchQuery) ||
                  p.studentName.toLowerCase().contains(_searchQuery) ||
                  p.genre.toLowerCase().contains(_searchQuery)
                ).toList();
              }

              if (projects.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(60),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('No game projects found. Click "Add Game Project" to add one.', style: TextStyle(color: AppColors.textLight)),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final proj = projects[index];
                  return _GameProjectCard(
                    project: proj,
                    onEdit: () => _showProjectDialog(project: proj),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Game Project?'),
                          content: Text('Are you sure you want to delete "${proj.title}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && proj.id != null) {
                        await firestoreService.deleteGameProject(proj.id!);
                        Fluttertoast.showToast(msg: 'Project deleted');
                      }
                    },
                    onTogglePublish: (val) async {
                      if (proj.id != null) {
                        await firestoreService.updateGameProject(proj.id!, {'isPublished': val});
                        Fluttertoast.showToast(msg: val ? 'Published to portfolio' : 'Unpublished');
                      }
                    },
                    onLaunchPlayStore: () => _launchUrl(proj.playStoreUrl),
                    onLaunchOtherUrl: () => _launchUrl(proj.otherUrl),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectFormDialog extends ConsumerStatefulWidget {
  final GameProjectModel? project;
  final List<AdmissionModel> students;

  const _ProjectFormDialog({this.project, required this.students});

  @override
  ConsumerState<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends ConsumerState<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _studentNameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _genreCtrl;
  late TextEditingController _techCtrl;
  late TextEditingController _periodCtrl;
  late TextEditingController _playStoreCtrl;
  late TextEditingController _otherUrlCtrl;
  late TextEditingController _imageCtrl;

  AdmissionModel? _selectedStudent;
  String _status = 'Completed';
  bool _isPublished = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _studentNameCtrl = TextEditingController(text: p?.studentName ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _genreCtrl = TextEditingController(text: p?.genre ?? 'Mobile Game');
    _techCtrl = TextEditingController(text: p?.technologies.join(', ') ?? 'Flutter, Dart, Flame');
    _periodCtrl = TextEditingController(text: p?.devPeriod ?? '2 Months');
    _playStoreCtrl = TextEditingController(text: p?.playStoreUrl ?? '');
    _otherUrlCtrl = TextEditingController(text: p?.otherUrl ?? '');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _status = p?.status ?? 'Completed';
    _isPublished = p?.isPublished ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _studentNameCtrl.dispose();
    _descCtrl.dispose();
    _genreCtrl.dispose();
    _techCtrl.dispose();
    _periodCtrl.dispose();
    _playStoreCtrl.dispose();
    _otherUrlCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);

      final techs = _techCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final model = GameProjectModel(
        id: widget.project?.id,
        studentId: _selectedStudent?.id ?? widget.project?.studentId ?? 'N/A',
        studentName: _studentNameCtrl.text.trim(),
        branchId: _selectedStudent?.branchId ?? widget.project?.branchId ?? 'manglor',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        genre: _genreCtrl.text.trim(),
        technologies: techs.isEmpty ? ['Flutter', 'Dart'] : techs,
        devPeriod: _periodCtrl.text.trim(),
        status: _status,
        playStoreUrl: _playStoreCtrl.text.trim().isEmpty ? null : _playStoreCtrl.text.trim(),
        otherUrl: _otherUrlCtrl.text.trim().isEmpty ? null : _otherUrlCtrl.text.trim(),
        imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
        isPublished: _isPublished,
        createdAt: widget.project?.createdAt ?? DateTime.now(),
      );

      if (widget.project?.id != null) {
        await firestoreService.updateGameProject(widget.project!.id!, model.toMap());
        Fluttertoast.showToast(msg: 'Game project updated');
      } else {
        await firestoreService.addGameProject(model);
        Fluttertoast.showToast(msg: 'Game project added successfully');
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error saving project: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth < 600 ? screenWidth * 0.95 : 550),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.project == null ? 'Add Student Game Project' : 'Edit Game Project',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 20),

                CategorizedStudentPicker(
                  students: widget.students,
                  selectedStudent: _selectedStudent,
                  onSelected: (v) {
                    setState(() {
                      _selectedStudent = v;
                      _studentNameCtrl.text = v.fullName;
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _studentNameCtrl,
                  decoration: const InputDecoration(labelText: 'Developer / Student Name *'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Game Title *', hintText: 'e.g. Space Defender 2D'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Short Description *', hintText: 'Brief summary of gameplay and mechanics...'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _genreCtrl,
                        decoration: const InputDecoration(labelText: 'Genre', hintText: 'e.g. 2D Platformer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: 'In Development', child: Text('In Development')),
                          DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'Published', child: Text('Published')),
                        ],
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _techCtrl,
                  decoration: const InputDecoration(labelText: 'Technologies (comma-separated)', hintText: 'Flutter, Flame, Dart'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _periodCtrl,
                  decoration: const InputDecoration(labelText: 'Development Period', hintText: 'e.g. 2 Months'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _playStoreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Play Store URL',
                    hintText: 'https://play.google.com/store/apps/details?id=...',
                    prefixIcon: Icon(Icons.shop_rounded),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _otherUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Web / Other Link (Optional)',
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Thumbnail / Image URL (Optional)',
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.image_rounded),
                  ),
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text('Publish to Public Portfolio'),
                  subtitle: const Text('Allow this game to be viewed on the public website'),
                  value: _isPublished,
                  onChanged: (v) => setState(() => _isPublished = v),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save Game Project'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameProjectCard extends StatelessWidget {
  final GameProjectModel project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onTogglePublish;
  final VoidCallback onLaunchPlayStore;
  final VoidCallback onLaunchOtherUrl;

  const _GameProjectCard({
    required this.project,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePublish,
    required this.onLaunchPlayStore,
    required this.onLaunchOtherUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sports_esports_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.text)),
                    const SizedBox(height: 4),
                    Text('Developer: ${project.studentName} • ${project.genre}',
                        style: const TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Switch(
                value: project.isPublished,
                onChanged: onTogglePublish,
                activeColor: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(project.description, style: const TextStyle(color: AppColors.text, fontSize: 14, height: 1.4)),
          const SizedBox(height: 16),

          // Tech badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: project.technologies.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sectionBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(),

          Row(
            children: [
              if (project.playStoreUrl != null) ...[
                OutlinedButton.icon(
                  onPressed: onLaunchPlayStore,
                  icon: const Icon(Icons.shop_rounded, size: 16),
                  label: const Text('Play Store'),
                ),
                const SizedBox(width: 8),
              ],
              if (project.otherUrl != null) ...[
                OutlinedButton.icon(
                  onPressed: onLaunchOtherUrl,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Web Link'),
                ),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              IconButton(icon: const Icon(Icons.edit_rounded, color: AppColors.primary), onPressed: onEdit, tooltip: 'Edit'),
              IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error), onPressed: onDelete, tooltip: 'Delete'),
            ],
          ),
        ],
      ),
    );
  }
}
