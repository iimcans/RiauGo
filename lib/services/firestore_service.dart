import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> simpanUser({
    required String uid,
    required String nama,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'nama': nama,
      'email': email,
      'createdAt': Timestamp.now(),
    });
  }
}