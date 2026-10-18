import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/branch_model.dart';

final branchServiceProvider = Provider<BranchService>((ref) => BranchService());

class BranchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _branches =>
      _db.collection('branches');

  Stream<List<BranchModel>> getBranches() {
    return _branches.snapshots().map((snap) =>
        snap.docs.map((d) => BranchModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addBranch(BranchModel branch) async {
    await _branches.doc(branch.id).set(branch.toMap());
  }

  Future<void> updateBranch(String id, Map<String, dynamic> data) async {
    await _branches.doc(id).update(data);
  }

  Future<void> seedInitialBranches() async {
    final snap = await _branches.get();
    if (snap.docs.isEmpty) {
      await addBranch(const BranchModel(
        id: 'charbagh',
        name: 'Charbagh',
        location: 'School Colony Charbagh Swat',
        isActive: true,
        isMainBranch: true,
        phone: '03298681641',
        branchType: 'coaching',
      ));
      await addBranch(const BranchModel(
        id: 'manglor',
        name: 'MAI Gaming Studio',
        location: 'Manglor, Swat, Pakistan',
        isActive: true,
        isMainBranch: false,
        phone: '03298681641',
        branchType: 'gaming_studio',
      ));
    }
  }
}
