import 'package:cloud_firestore/cloud_firestore.dart';
import '../../games/models/game_model.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';

enum FriendStatus { none, requestSent, friends }

class UserSearchResult {
  final String uid;
  final String displayName;
  final String? photoBase64;

  const UserSearchResult({
    required this.uid,
    required this.displayName,
    this.photoBase64,
  });
}

class FriendsRepository {
  final FirebaseFirestore _db;
  final String _uid;
  final String _displayName;
  final String? _photoBase64;

  FriendsRepository({
    required FirebaseFirestore db,
    required String uid,
    required String displayName,
    String? photoBase64,
  })  : _db = db,
        _uid = uid,
        _displayName = displayName,
        _photoBase64 = photoBase64;

  Future<List<UserSearchResult>> searchUsers(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final snap = await _db
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: q)
        .where('displayName', isLessThanOrEqualTo: '$q')
        .limit(15)
        .get();
    return snap.docs
        .where((d) => d.id != _uid)
        .map((d) {
          final data = d.data();
          return UserSearchResult(
            uid: d.id,
            displayName: data['displayName'] as String? ?? 'Usuario',
            photoBase64: data['photoBase64'] as String?,
          );
        })
        .toList();
  }

  Future<void> sendRequest(UserSearchResult target) async {
    final friendDoc = await _db
        .collection('users')
        .doc(_uid)
        .collection('friends')
        .doc(target.uid)
        .get();
    if (friendDoc.exists) throw 'Ya eres amigo de ${target.displayName}';

    final existing = await _db
        .collection('friendRequests')
        .where('senderId', isEqualTo: _uid)
        .get();
    final alreadySent = existing.docs
        .any((d) => d.data()['receiverId'] == target.uid && d.data()['status'] == 'pending');
    if (alreadySent) throw 'Ya enviaste una solicitud a ${target.displayName}';

    await _db.collection('friendRequests').add({
      'senderId': _uid,
      'senderDisplayName': _displayName,
      'senderPhotoBase64': _photoBase64,
      'receiverId': target.uid,
      'receiverDisplayName': target.displayName,
      'receiverPhotoBase64': target.photoBase64,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptRequest(FriendRequestModel request) async {
    final batch = _db.batch();
    batch.update(
      _db.collection('friendRequests').doc(request.id),
      {'status': 'accepted'},
    );
    batch.set(
      _db.collection('users').doc(_uid).collection('friends').doc(request.senderId),
      {
        'displayName': request.senderDisplayName,
        'photoBase64': request.senderPhotoBase64,
        'addedAt': FieldValue.serverTimestamp(),
      },
    );
    batch.set(
      _db.collection('users').doc(request.senderId).collection('friends').doc(_uid),
      {
        'displayName': _displayName,
        'photoBase64': _photoBase64,
        'addedAt': FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();
  }

  Future<void> rejectRequest(String requestId) async {
    await _db
        .collection('friendRequests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }

  Future<void> removeFriend(String friendUid) async {
    final batch = _db.batch();
    batch.delete(
        _db.collection('users').doc(_uid).collection('friends').doc(friendUid));
    batch.delete(
        _db.collection('users').doc(friendUid).collection('friends').doc(_uid));
    await batch.commit();
  }

  Stream<List<FriendModel>> watchFriends() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('friends')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(FriendModel.fromDoc).toList());
  }

  // Filter status in-app to avoid composite index requirement
  Stream<List<FriendRequestModel>> watchIncomingRequests() {
    return _db
        .collection('friendRequests')
        .where('receiverId', isEqualTo: _uid)
        .snapshots()
        .map((s) => s.docs
            .map(FriendRequestModel.fromDoc)
            .where((r) => r.status == 'pending')
            .toList());
  }

  Stream<List<GameModel>> watchFriendGames(String friendUid) {
    return _db
        .collection('users')
        .doc(friendUid)
        .collection('juegos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(GameModel.fromFirestore).toList());
  }
}
