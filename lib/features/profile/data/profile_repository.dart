import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../../auth/providers/auth_providers.dart';

class ProfileRepository {
  final FirebaseFirestore _db;
  final String _uid;

  ProfileRepository(this._db, this._uid);

  Stream<UserModel?> watch() => _db
      .collection('users')
      .doc(_uid)
      .snapshots()
      .map((s) => s.exists ? UserModel.fromFirestore(s) : null);

  Future<void> update({
    required String displayName,
    required String photoBase64,
  }) =>
      _db.collection('users').doc(_uid).update({
        'displayName': displayName,
        'photoBase64': photoBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}

final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ProfileRepository(FirebaseFirestore.instance, user.uid);
});

final profileStreamProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watch();
});
