import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../games/models/game_model.dart';
import '../../games/data/games_repository.dart';
import '../models/friend_model.dart';
import '../providers/friends_providers.dart';

class CompareGamesScreen extends ConsumerStatefulWidget {
  final FriendModel friend;

  const CompareGamesScreen({super.key, required this.friend});

  @override
  ConsumerState<CompareGamesScreen> createState() => _CompareGamesScreenState();
}

class _CompareGamesScreenState extends ConsumerState<CompareGamesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myGamesAsync = ref.watch(gamesStreamProvider);
    final friendGamesAsync = ref.watch(_friendGamesProvider(widget.friend.uid));

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
        title: Row(
          children: [
            Text(
              'vs ',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              widget.friend.displayName,
              style: GoogleFonts.orbitron(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Jugando'),
            Tab(text: 'Pendientes'),
            Tab(text: 'Completado'),
          ],
        ),
      ),
      body: myGamesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (myGames) => friendGamesAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (friendGames) => Column(
            children: [
              _StatsCompare(myGames: myGames, friendGames: friendGames, friend: widget.friend),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _GamesCompareTab(
                        my: myGames,
                        theirs: friendGames,
                        friend: widget.friend),
                    _GamesCompareTab(
                        my: myGames.where((g) => g.categoria == GameCategory.inProgress).toList(),
                        theirs: friendGames.where((g) => g.categoria == GameCategory.inProgress).toList(),
                        friend: widget.friend),
                    _GamesCompareTab(
                        my: myGames.where((g) => g.categoria == GameCategory.toPlay).toList(),
                        theirs: friendGames.where((g) => g.categoria == GameCategory.toPlay).toList(),
                        friend: widget.friend),
                    _GamesCompareTab(
                        my: myGames.where((g) => g.categoria == GameCategory.completed).toList(),
                        theirs: friendGames.where((g) => g.categoria == GameCategory.completed).toList(),
                        friend: widget.friend),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _friendGamesProvider =
    StreamProvider.autoDispose.family<List<GameModel>, String>((ref, friendUid) {
  final repo = ref.watch(friendsRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchFriendGames(friendUid);
});

class _StatsCompare extends StatelessWidget {
  final List<GameModel> myGames;
  final List<GameModel> friendGames;
  final FriendModel friend;

  const _StatsCompare(
      {required this.myGames, required this.friendGames, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _StatCol(games: myGames, label: 'Tú')),
          Container(width: 1, height: 60, color: AppColors.border),
          Expanded(child: _StatCol(games: friendGames, label: friend.displayName)),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final List<GameModel> games;
  final String label;

  const _StatCol({required this.games, required this.label});

  @override
  Widget build(BuildContext context) {
    final playing = games.where((g) => g.categoria == GameCategory.inProgress).length;
    final pending = games.where((g) => g.categoria == GameCategory.toPlay).length;
    final done = games.where((g) => g.categoria == GameCategory.completed).length;
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.nunitoSans(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Num(n: games.length, color: AppColors.primary, sub: 'Total'),
            _Num(n: playing, color: AppColors.statusPlaying, sub: 'Jugando'),
            _Num(n: pending, color: AppColors.statusPending, sub: 'Pend.'),
            _Num(n: done, color: AppColors.statusCompleted, sub: 'Comp.'),
          ],
        ),
      ],
    );
  }
}

class _Num extends StatelessWidget {
  final int n;
  final Color color;
  final String sub;

  const _Num({required this.n, required this.color, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$n',
            style: GoogleFonts.orbitron(
                fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(sub,
            style: GoogleFonts.nunitoSans(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}

class _GamesCompareTab extends StatelessWidget {
  final List<GameModel> my;
  final List<GameModel> theirs;
  final FriendModel friend;

  const _GamesCompareTab(
      {required this.my, required this.theirs, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _GameColumn(games: my, label: 'Tú')),
        Container(width: 1, color: AppColors.border),
        Expanded(child: _GameColumn(games: theirs, label: friend.displayName)),
      ],
    );
  }
}

class _GameColumn extends StatelessWidget {
  final List<GameModel> games;
  final String label;

  const _GameColumn({required this.games, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            style: GoogleFonts.nunitoSans(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: games.isEmpty
              ? Center(
                  child: Text('Sin juegos',
                      style: GoogleFonts.nunitoSans(
                          fontSize: 13, color: AppColors.textMuted)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  itemCount: games.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _MiniGameCard(game: games[i]),
                ),
        ),
      ],
    );
  }
}

class _MiniGameCard extends StatelessWidget {
  final GameModel game;

  const _MiniGameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final bytes = ImageUtils.decodeBase64(game.imageBase64);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: bytes != null
                  ? Image.memory(bytes, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.surfaceElevated,
                      child: const Icon(Icons.sports_esports_outlined,
                          color: AppColors.textMuted, size: 24),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Text(
              game.nombre,
              style: GoogleFonts.nunitoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
