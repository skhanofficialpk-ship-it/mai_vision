import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../services/fee_service.dart';
import '../services/admin_dashboard_service.dart'; // New
import '../models/student_model.dart';
import '../models/payment_model.dart';

/// Provides command center statistics for the dashboard.
final commandCenterStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, branchId) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getCommandCenterStats(branchId: branchId);
});

/// Stream of raw fee payments.
final paymentsStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, branchId) {
  return ref.watch(adminDashboardServiceProvider).getPaymentsStream(branchId: branchId);
});

/// Stream of raw expenses.
final expensesStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, branchId) {
  return ref.watch(adminDashboardServiceProvider).getExpensesStream(branchId: branchId);
});

/// Provides combined financial activity (Fees + Expenses).
final financialActivityProvider = Provider.family<AsyncValue<List<Map<String, dynamic>>>, String>((ref, branchId) {
  final pay = ref.watch(paymentsStreamProvider(branchId));
  final exp = ref.watch(expensesStreamProvider(branchId));

  return pay.when(
    data: (pList) => exp.when(
      data: (eList) {
        final list = [...pList, ...eList];
        list.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        return AsyncValue.data(list.take(10).toList());
      },
      loading: () => const AsyncValue.loading(),
      error: (err, st) => AsyncValue.error(err, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (err, st) => AsyncValue.error(err, st),
  );
});

/// Provides dashboard statistics for a given branchId.
final dashboardStatsProvider = FutureProvider.family<Map<String, int>, String>((ref, branchId) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getDashboardStats(branchId: branchId);
});

/// Provides financial statistics for a given branchId.
final feeStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, branchId) async {
  final service = ref.watch(feeServiceProvider);
  // Keep alive for 5 minutes to avoid frequent expensive fetches
  final link = ref.keepAlive();
  Future.delayed(const Duration(minutes: 5), () => link.close());
  return service.getDashboardStats(branchId: branchId);
});

/// Provides overdue students for the fee dashboard.
final overdueStudentsProvider = FutureProvider<List<StudentModel>>((ref) async {
  final service = ref.watch(feeServiceProvider);
  return service.getOverdueStudents();
});

/// Provides a list of recent payments across the whole institute.
final recentPaymentsProvider = StreamProvider<List<PaymentModel>>((ref) {
  final service = ref.watch(feeServiceProvider);
  return service.getAllPayments();
});

