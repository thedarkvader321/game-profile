import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String id;
  final String senderId;
  final String senderDisplayName;
  final String? senderPhotoBase64;
  final String receiverId;
  final String receiverDisplayName;
  final String status;
  final DateTime createdAt;

  const FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderDisplayName,
    this.senderPhotoBase64,
    required this.receiverId,
    required this.receiverDisplayName,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequestModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderDisplayName: data['senderDisplayName'] as String? ?? 'Usuario',
      senderPhotoBase64: data['senderPhotoBase64'] as String?,
      receiverId: data['receiverId'] as String? ?? '',
      receiverDisplayName: data['receiverDisplayName'] as String? ?? 'Usuario',
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
