import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final String uid;
  final String displayName;
  final String? photoBase64;
  final DateTime addedAt;

  const FriendModel({
    required this.uid,
    required this.displayName,
    this.photoBase64,
    required this.addedAt,
  });

  factory FriendModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'Usuario',
      photoBase64: data['photoBase64'] as String?,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
