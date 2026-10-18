import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/stats_provider.dart';
import '../../providers/auth_provider.dart';

class AdminOverviewPage extends ConsumerStatefulWidget {
  const AdminOverviewPage({super.key});

  @override
  ConsumerState<AdminOverviewPage> createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends ConsumerState<AdminOverviewPage> {
  String _selectedBranchId = 'all';

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(commandCenterStatsProvider(_selectedBranchId));
    final activityAsync = ref.watch(financialActivityProvider(_selectedBranchId));
    final user = ref.watch(currentUserProvider);
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;
    
    return Scaffold(
      backgroundColor: AppColors.sectionBg,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP ADMIN WELCOME BANNER
            _WelcomeBanner(
              adminName: user?.displayName ?? AppConstants.adminDisplayName,
              isMobile: isMobile,
              statsAsync: statsAsync,
            ),
            const SizedBox(height: 32),

            // 2. MAIN STATISTICS GRIDS
            const Text('Administrative Command Center', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            
            statsAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
              error: (err, _) => Center(child: Text('Error loading stats: $err')),
              data: (stats) => Column(
                children: [
                  _StatsGrid(stats: stats, isMobile: isMobile),
                  const SizedBox(height: 32),
                  
                  // 3. FINANCIAL SUMMARY BAR
                  _FinancialSummaryBar(stats: stats, isMobile: isMobile),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // 4. ADMINISTRATIVE COMMAND DOCK
            const Text('Administrative Command Dock', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            _CommandDock(isMobile: isMobile),

            const SizedBox(height: 48),

            // 5. RECENT FINANCIAL ACTIVITY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Financial Activity', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -0.5)),
                TextButton(onPressed: () => context.go('/admin/fee'), child: const Text('View All Activity')),
              ],
            ),
            const SizedBox(height: 20),
            activityAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
              data: (list) => _RecentActivityList(list: list, isMobile: isMobile),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final String adminName;
  final bool isMobile;
  final AsyncValue<Map<String, dynamic>> statsAsync;

  const _WelcomeBanner({required this.adminName, required this.isMobile, required this.statsAsync});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20, top: -20,
            child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.05)),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            child: isMobile 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeft(),
                    const SizedBox(height: 32),
                    _buildRight(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildLeft()),
                    _buildRight(),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeft() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 32,
          backgroundColor: Colors.white24,
          child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(20)),
                child: const Text('SYSTEM ADMINISTRATOR', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              Text('${_getGreeting()}, $adminName', 
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              statsAsync.maybeWhen(
                data: (s) => Text(
                  '${s['activeStudents']} Students • ${s['teachersCount']} Faculty • Account Active',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRight() {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(DateFormat('EEEE, MMMM dd').format(now), 
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(DateFormat('hh:mm a').format(now), 
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isMobile;
  const _StatsGrid({required this.stats, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w < 500 ? 1 : (w < 900 ? 2 : 3);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 2.2,
      children: [
        _StatCard(
          label: 'TOTAL ACTIVE STUDENTS',
          value: '${stats['activeStudents']}',
          sub: '${stats['courseStudents']} Course / ${stats['tuitionStudents']} Tuition',
          icon: Icons.people_rounded,
          color: AppColors.primary,
        ),
        _StatCard(
          label: 'COURSE STUDENTS',
          value: '${stats['courseStudents']}',
          sub: 'Enrolled in academy courses',
          icon: Icons.school_rounded,
          color: AppColors.secondary,
        ),
        _StatCard(
          label: 'TUITION STUDENTS',
          value: '${stats['tuitionStudents']}',
          sub: 'Enrolled in tuition classes',
          icon: Icons.history_edu_rounded,
          color: AppColors.accent,
        ),
        _StatCard(
          label: "TODAY'S FEE COLLECTION",
          value: 'PKR ${NumberFormat('#,##0').format(stats['todayCollection'])}',
          sub: 'Daily cash & online inflows',
          icon: Icons.payments_rounded,
          color: AppColors.success,
        ),
        _StatCard(
          label: 'PENDING DUES (RECEIVABLES)',
          value: 'PKR ${NumberFormat('#,##0').format(stats['pendingDues'])}',
          sub: 'Total outstanding student fees',
          icon: Icons.money_off_rounded,
          color: AppColors.error,
        ),
        _StatCard(
          label: 'TEACHERS / FACULTY',
          value: '${stats['teachersCount']}',
          sub: 'Active academic staff members',
          icon: Icons.person_search_rounded,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.sub, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textLight, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textLight), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialSummaryBar extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isMobile;
  const _FinancialSummaryBar({required this.stats, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: isMobile 
        ? Column(children: _buildItems())
        : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _buildItems()),
    );
  }

  List<Widget> _buildItems() {
    final fmt = NumberFormat('#,##0');
    return [
      _summaryItem('MONTH COLLECTIONS', 'PKR ${fmt.format(stats['monthlyCollection'])}', AppColors.success),
      if (isMobile) const Divider(height: 24),
      _summaryItem('MONTH EXPENSES', 'PKR ${fmt.format(stats['monthlyExpenses'])}', AppColors.error),
      if (isMobile) const Divider(height: 24),
      _summaryItem('NET OPERATING CASH', 'PKR ${fmt.format(stats['netCash'])}', AppColors.primary),
      if (isMobile) const Divider(height: 24),
      _summaryItem('TOTAL ADMISSIONS', '${stats['totalAdmissions']}', AppColors.secondary),
    ];
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textLight, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

class _CommandDock extends StatelessWidget {
  final bool isMobile;
  const _CommandDock({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16, runSpacing: 16,
      children: [
        _DockButton(icon: Icons.person_add_alt_1, label: 'Add Admission', onTap: () => context.go('/admin/admissions')),
        _DockButton(icon: Icons.people_outline, label: 'Manage Students', onTap: () => context.go('/admin/students')),
        _DockButton(icon: Icons.payment, label: 'Collect Fee', onTap: () => context.go('/admin/fee')),
        _DockButton(icon: Icons.library_books, label: 'Manage Courses', onTap: () => context.go('/admin/courses')),
        _DockButton(icon: Icons.person_search_rounded, label: 'Manage Teachers', onTap: () => context.go('/admin/teachers')),
        _DockButton(icon: Icons.account_balance, label: 'Add Expense', onTap: () => context.go('/admin/expenses')),
      ],
    );
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DockButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> list;
  final bool isMobile;
  const _RecentActivityList({required this.list, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: const Center(child: Text('No financial activity recorded yet.', style: TextStyle(color: AppColors.textLight))),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = list[i];
          final positive = item['isPositive'] as bool;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: (positive ? AppColors.success : AppColors.error).withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(positive ? Icons.add : Icons.remove, color: positive ? AppColors.success : AppColors.error, size: 18),
            ),
            title: Text(item['particulars'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: Text('${item['reference']} • ${DateFormat('dd MMM yyyy').format(item['date'])} • ${item['method']}', style: const TextStyle(fontSize: 12)),
            trailing: Text('${positive ? "+" : "-"} PKR ${NumberFormat('#,##0').format(item['amount'])}', 
              style: TextStyle(fontWeight: FontWeight.w900, color: positive ? AppColors.success : AppColors.error, fontSize: 15)),
          );
        },
      ),
    );
  }
}
