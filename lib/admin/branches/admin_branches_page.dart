import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/branch_model.dart';
import '../../services/branch_service.dart';

class AdminBranchesPage extends ConsumerWidget {
  const AdminBranchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesStream = ref.watch(branchServiceProvider).getBranches();

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
                Text('Branch Management',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
                SizedBox(height: 6),
                Text('Manage institute physical locations and status.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 14)),
              ],
            );
            
            final action = ElevatedButton.icon(
              onPressed: () => _showBranchDialog(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Branch'),
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
          StreamBuilder<List<BranchModel>>(
            stream: branchesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator()));
              }
              final branches = snapshot.data ?? [];
              
              if (branches.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(60),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('No branches added yet.', style: TextStyle(color: AppColors.textLight)),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return _BranchCard(branch: branch);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBranchDialog(BuildContext context, WidgetRef ref, {BranchModel? branch}) {
    final nameController = TextEditingController(text: branch?.name);
    final locationController = TextEditingController(text: branch?.location);
    bool isActive = branch?.isActive ?? true;
    bool isMain = branch?.isMainBranch ?? false;
    String branchType = branch?.branchType ?? 'coaching';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(branch == null ? 'Add Branch' : 'Edit Branch'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Branch Name',
                    hintText: 'e.g. Charbagh or MAI Gaming Studio',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: branchType,
                  decoration: const InputDecoration(labelText: 'Branch Type'),
                  items: const [
                    DropdownMenuItem(value: 'coaching', child: Text('Coaching Branch')),
                    DropdownMenuItem(value: 'gaming_studio', child: Text('Gaming Studio')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => branchType = val);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Is Active'),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                ),
                SwitchListTile(
                  title: const Text('Is Main Branch'),
                  value: isMain,
                  onChanged: (val) => setState(() => isMain = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final id = branch?.id ?? name.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');

                final newBranch = BranchModel(
                  id: id,
                  name: name,
                  location: locationController.text.trim(),
                  isActive: isActive,
                  isMainBranch: isMain,
                  branchType: branchType,
                );
                await ref.read(branchServiceProvider).addBranch(newBranch);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchCard extends ConsumerWidget {
  final BranchModel branch;
  const _BranchCard({required this.branch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGaming = branch.isGamingStudio;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isGaming 
                ? Colors.purple.withOpacity(0.1)
                : branch.isActive 
                    ? AppColors.success.withOpacity(0.1) 
                    : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isGaming 
                ? Icons.sports_esports_rounded 
                : branch.isMainBranch ? Icons.star_rounded : Icons.location_on_rounded,
            color: isGaming 
                ? Colors.purple 
                : branch.isActive ? AppColors.success : AppColors.error,
          ),
        ),
        title: Row(
          children: [
            Text(branch.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.text)),
            if (isGaming) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('GAMING STUDIO', style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        subtitle: Text(branch.location, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textLight)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: branch.isActive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                branch.isActive ? 'ACTIVE' : 'PAUSED',
                style: TextStyle(color: branch.isActive ? AppColors.success : AppColors.error, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Branch')),
                const PopupMenuItem(value: 'status', child: Text('Toggle Status')),
              ],
              onSelected: (val) {
                if (val == 'edit') {
                  const AdminBranchesPage()._showBranchDialog(context, ref, branch: branch);
                } else if (val == 'status') {
                  ref.read(branchServiceProvider).updateBranch(branch.id, {'isActive': !branch.isActive});
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
}
