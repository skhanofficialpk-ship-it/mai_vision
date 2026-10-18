import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  static const _navItems = [
    (Icons.dashboard_rounded, 'Overview', '/admin'),
    (Icons.account_balance_rounded, 'Branches', '/admin/branches'),
    (Icons.groups_rounded, 'Batches', '/admin/batches'),
    (Icons.assignment_ind_rounded, 'Admissions', '/admin/admissions'),
    (Icons.people_alt_rounded, 'Students', '/admin/students'),
    (Icons.payments_rounded, 'Fee Management', '/admin/fee'),
    (Icons.person_search_rounded, 'Teachers', '/admin/teachers'),
    (Icons.account_balance_wallet_rounded, 'Expenses', '/admin/expenses'),
    (Icons.menu_book_rounded, 'Courses', '/admin/courses'),
    (Icons.sports_esports_rounded, 'Game Projects', '/admin/projects'),
    (Icons.workspace_premium_rounded, 'Certificates', '/admin/certificates'),
    (Icons.quiz_rounded, 'FAQ', '/admin/faq'),
    (Icons.edit_note_rounded, 'Website Content', '/admin/content'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 1100;
    final currentPath = GoRouterState.of(context).matchedLocation;
    final user = ref.watch(currentUserProvider);

    final sidebar = _Sidebar(
      currentPath: currentPath,
      items: _navItems,
      userEmail: user?.email ?? 'Admin Account',
    );

    return Scaffold(
      backgroundColor: AppColors.sectionBg,
      drawer: isMobile ? Drawer(child: sidebar) : null,
      body: Row(
        children: [
          if (!isMobile) sidebar,
          Expanded(
            child: Column(
              children: [
                _AdminAppBar(isMobile: isMobile, currentPath: currentPath),
                Expanded(
                  child: ClipRRect(
                    // Inner rounding for the content area to give it a modern "window" feel
                    borderRadius: isMobile 
                        ? BorderRadius.zero 
                        : const BorderRadius.only(topLeft: Radius.circular(32)),
                    child: Container(
                      color: AppColors.sectionBg,
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminAppBar extends StatelessWidget {
  final bool isMobile;
  final String currentPath;
  const _AdminAppBar({required this.isMobile, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isCompact = w < 480;

    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      color: isMobile ? Colors.white : AppColors.sectionBg,
      child: Row(
        children: [
          if (isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.menu_open_rounded, color: AppColors.primary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          Expanded(
            child: Text(
              _getTitle(currentPath),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w900, 
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Modern badge for "Visit Site"
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => context.go('/'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.launch_rounded, size: 14, color: AppColors.primary),
                    if (!isCompact) ...[
                      const SizedBox(width: 8),
                      const Text(
                        'View Site', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User Avatar Placeholder
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.border,
            child: Icon(Icons.person_rounded, size: 20, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _getTitle(String path) {
    if (path == '/admin') return 'Overview';
    if (path.contains('branches')) return 'Branches';
    if (path.contains('batches')) return 'Batches';
    if (path.contains('admissions')) return 'Admissions';
    if (path.contains('students')) return 'Students';
    if (path.contains('fee')) return 'Fees';
    if (path.contains('courses')) return 'Courses';
    if (path.contains('projects')) return 'Game Projects';
    if (path.contains('certificates')) return 'Certificates';
    if (path.contains('faq')) return 'FAQ';
    if (path.contains('content')) return 'Website Content';
    return 'Admin';
  }
}

class _Sidebar extends ConsumerWidget {
  final String currentPath;
  final List<(IconData, String, String)> items;
  final String userEmail;

  const _Sidebar({required this.currentPath, required this.items, required this.userEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Logo Section
          Container(
            height: 120,
            padding: const EdgeInsets.all(32),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png', 
                    height: 24, 
                    errorBuilder: (_, __, ___) => const Icon(Icons.shield, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MAI COACHING',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                    ),
                    Text(
                      'ACADEMY', 
                      style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: Material( // Wrap with Material to fix the ink splash issue
              color: Colors.transparent,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isActive = currentPath == item.$3;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                        context.go(item.$3);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isActive ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ] : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.$1, 
                              size: 20, 
                              color: isActive ? Colors.white : Colors.white60,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item.$2, 
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.white70, 
                                fontSize: 14, 
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            if (isActive) ...[
                              const Spacer(),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Bottom Section: Profile & Sign Out
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: const Icon(Icons.person_outline_rounded, size: 16, color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        userEmail, 
                        style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => ref.read(authServiceProvider).signOut(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.white70),
                    label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
