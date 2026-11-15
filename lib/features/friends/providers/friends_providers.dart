import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../../profile/data/profile_repository.dart';
import '../data/friends_repository.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';

final friendsRepositoryProvider = Provider<FriendsRepository?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final profile = ref.watch(profileStreamProvider).value;
  return FriendsRepository(
    db: FirebaseFirestore.instance,
    uid: user.uid,
    displayName: profile?.displayName ?? user.displayName ?? 'Usuario',
    photoBase64: profile?.photoBase64,
  );
});

final friendsStreamProvider = StreamProvider<List<FriendModel>>((ref) {
  final repo = ref.watch(friendsRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchFriends();
});

final incomingRequestsProvider = StreamProvider<List<FriendRequestModel>>((ref) {
  final repo = ref.watch(friendsRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchIncomingRequests();
});
