import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/batch_model.dart';

final batchServiceProvider = Provider<BatchService>((ref) => BatchService());

class BatchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _batches =>
      _db.collection('batches');

  Stream<List<BatchModel>> getBatches({String? branchId, String? courseId}) {
    Query<Map<String, dynamic>> query = _batches.orderBy('createdAt', descending: true);
    if (branchId != null && branchId != 'all') query = query.where('branchId', isEqualTo: branchId);
    if (courseId != null && courseId != 'all') query = query.where('courseIds', arrayContains: courseId);
    
    return query.snapshots().map((snap) =>
        snap.docs.map((d) => BatchModel.fromMap(d.data(), d.id)).toList());
  }

  Future<String> addBatch(BatchModel batch) async {
    final ref = await _batches.add(batch.toMap());
    return ref.id;
  }

  Future<void> updateBatch(String id, Map<String, dynamic> data) async {
    await _batches.doc(id).update(data);
  }

  Future<void> deleteBatch(String id) async {
    await _batches.doc(id).delete();
  }
}
