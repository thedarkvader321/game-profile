import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_model.dart';
import '../../auth/providers/auth_providers.dart';

class GamesRepository {
  final FirebaseFirestore _db;
  final String _uid;

  GamesRepository(this._db, this._uid);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('juegos');

  Stream<List<GameModel>> watch() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(GameModel.fromFirestore).toList());

  Future<void> add({
    required String nombre,
    required GameCategory categoria,
    required String imageBase64,
  }) async {
    final now = FieldValue.serverTimestamp();
    await _col.add({
      'nombre': nombre,
      'categoria': categoria.firestoreValue,
      'imageBase64': imageBase64,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> update({
    required String gameId,
    required String nombre,
    required GameCategory categoria,
    required String imageBase64,
  }) async {
    await _col.doc(gameId).update({
      'nombre': nombre,
      'categoria': categoria.firestoreValue,
      'imageBase64': imageBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String gameId) => _col.doc(gameId).delete();
}

final gamesRepositoryProvider = Provider<GamesRepository?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return GamesRepository(FirebaseFirestore.instance, user.uid);
});

final gamesStreamProvider = StreamProvider<List<GameModel>>((ref) {
  final repo = ref.watch(gamesRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watch();
});
