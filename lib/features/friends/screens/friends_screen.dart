import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../data/friends_repository.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';
import '../providers/friends_providers.dart';
import '../widgets/friend_card_widget.dart';
import '../widgets/pending_request_card.dart';
import 'compare_games_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  List<UserSearchResult> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    setState(() => _query = q);
    if (q.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final repo = ref.read(friendsRepositoryProvider);
      if (repo == null) return;
      final results = await repo.searchUsers(q.trim());
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _sendRequest(UserSearchResult target) async {
    final repo = ref.read(friendsRepositoryProvider);
    if (repo == null) return;
    try {
      await repo.sendRequest(target);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Solicitud enviada a ${target.displayName}'),
        backgroundColor: AppColors.statusCompleted,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _accept(FriendRequestModel request) async {
    final repo = ref.read(friendsRepositoryProvider);
    if (repo == null) return;
    try {
      await repo.acceptRequest(request);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('¡Ahora son amigos!'),
        backgroundColor: AppColors.statusCompleted,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _reject(String requestId) async {
    final repo = ref.read(friendsRepositoryProvider);
    await repo?.rejectRequest(requestId);
  }

  Future<void> _removeFriend(FriendModel friend) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar amigo'),
        content: Text('¿Eliminar a ${friend.displayName} de tus amigos?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Eliminar', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm != true) return;
    final repo = ref.read(friendsRepositoryProvider);
    await repo?.removeFriend(friend.uid);
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsStreamProvider);
    final requestsAsync = ref.watch(incomingRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Amigos',
          style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // Search
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre de usuario...',
              prefixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary)),
                    )
                  : const Icon(Icons.search_rounded, color: AppColors.textMuted),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {
                          _query = '';
                          _results = [];
                        });
                      },
                    )
                  : null,
            ),
            onChanged: _search,
          ),
          const SizedBox(height: 16),

          // Search results
          if (_query.isNotEmpty) ...[
            _SectionHeader(label: 'Resultados (${_results.length})'),
            const SizedBox(height: 8),
            if (_results.isEmpty && !_searching)
              _EmptyHint(text: 'No se encontró "$_query"')
            else
              ..._results.map((u) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SearchResultCard(
                        result: u,
                        onAdd: () => _sendRequest(u)),
                  )),
            const SizedBox(height: 16),
          ],

          // Incoming requests
          requestsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (requests) {
              if (requests.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                      label: 'Solicitudes pendientes (${requests.length})'),
                  const SizedBox(height: 8),
                  ...requests.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PendingRequestCard(
                          request: r,
                          onAccept: () => _accept(r),
                          onReject: () => _reject(r.id),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),

          // Friends list
          friendsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Text(e.toString()),
            data: (friends) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(label: 'Mis amigos (${friends.length})'),
                const SizedBox(height: 8),
                if (friends.isEmpty)
                  _EmptyHint(text: 'Aún no tienes amigos. ¡Busca a alguien!')
                else
                  ...friends.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FriendCardWidget(
                          friend: f,
                          onTap: () => Navigator.push(
                            context,
                            _route(CompareGamesScreen(friend: f)),
                          ),
                          onRemove: () => _removeFriend(f),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Route<T> _route<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 220),
    );

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.nunitoSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
          letterSpacing: 0.8),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text,
          style: GoogleFonts.nunitoSans(fontSize: 13, color: AppColors.textMuted)),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final UserSearchResult result;
  final VoidCallback onAdd;

  const _SearchResultCard({required this.result, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final bytes = ImageUtils.decodeBase64(result.photoBase64);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceElevated,
            backgroundImage: bytes != null ? MemoryImage(bytes) : null,
            child: bytes == null
                ? const Icon(Icons.person_rounded,
                    color: AppColors.textMuted, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              result.displayName,
              style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_outlined, size: 16),
            label: const Text('Agregar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              textStyle:
                  GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
