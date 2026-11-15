import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/models/user_model.dart';
import '../../profile/widgets/edit_profile_bottom_sheet.dart';
import '../../settings/screens/settings_screen.dart';
import '../data/games_repository.dart';
import '../models/game_model.dart';
import '../widgets/add_game_modal.dart';
import '../widgets/edit_game_modal.dart';
import '../widgets/game_card_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  GameCategory _filter = GameCategory.all;
  final _searchCtrl = TextEditingController();
  String _query = '';

  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<GameModel> _applyFilters(List<GameModel> all) {
    var list = all;
    if (_filter != GameCategory.all) {
      list = list.where((g) => g.categoria == _filter).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((g) => g.nombre.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  void _openAdd() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AddGameModal(),
      );

  void _openEdit(GameModel game) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => EditGameModal(game: game),
      );

  void _openProfile(UserModel? user) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => EditProfileBottomSheet(user: user),
      );

  void _openSettings() => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const SettingsScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 200),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesStreamProvider);
    final profileAsync = ref.watch(profileStreamProvider);
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          final t = _bgController.value;
          final from = themeState.gradientFrom;
          final to = themeState.gradientTo;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.lerp(Alignment.topLeft, Alignment.topCenter, t)!,
                end: Alignment.lerp(Alignment.bottomRight, Alignment.bottomCenter, t)!,
                colors: [
                  Color.lerp(from[0], to[0], t)!,
                  Color.lerp(from[1], to[1], t)!,
                  Color.lerp(from[2], to[2], t)!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _AppBar(
                profileAsync: profileAsync,
                onProfileTap: (u) => _openProfile(u),
                onSettings: _openSettings,
              ),
              Expanded(
                child: gamesAsync.when(
                  loading: _buildShimmer,
                  error: (e, _) => _ErrorState(message: e.toString()),
                  data: (all) => _buildBody(all),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Agregar',
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildBody(List<GameModel> all) {
    final filtered = _applyFilters(all);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _StatsCard(games: all)),
        SliverToBoxAdapter(child: _SearchBar(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          onClear: () {
            _searchCtrl.clear();
            setState(() => _query = '');
          },
          hasQuery: _query.isNotEmpty,
        )),
        SliverToBoxAdapter(child: _FilterChips(
          selected: _filter,
          onSelect: (c) => setState(() => _filter = c),
          games: all,
        )),
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              title: _query.isNotEmpty
                  ? 'Sin resultados'
                  : _filter == GameCategory.all
                      ? 'Tu biblioteca está vacía'
                      : 'Sin juegos en "${_filter.displayName}"',
              subtitle: _query.isNotEmpty
                  ? 'No hay juegos que coincidan con "$_query".'
                  : _filter == GameCategory.all
                      ? 'Toca + Agregar para añadir tu primer juego.'
                      : 'Cambia el filtro o agrega juegos en esta categoría.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => GameCardWidget(
                  game: filtered[i],
                  onEdit: () => _openEdit(filtered[i]),
                ),
                childCount: filtered.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmer() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: 6,
          itemBuilder: (_, _) => const ShimmerCard(),
        ),
      );
}

// ──────────────────────────────────────────────────────────────
// AppBar
// ──────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final AsyncValue<UserModel?> profileAsync;
  final void Function(UserModel?) onProfileTap;
  final VoidCallback onSettings;

  const _AppBar({
    required this.profileAsync,
    required this.onProfileTap,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
      child: Row(
        children: [
          const Icon(Icons.sports_esports_rounded, color: AppColors.primary, size: 26),
          const SizedBox(width: 10),
          Text(
            'GameTracker',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          // Flexible para que ceda espacio si el nombre es muy largo
          Flexible(
            child: profileAsync.when(
              loading: () => const SizedBox(width: 36, height: 36),
              error: (_, _) => const SizedBox.shrink(),
              data: (user) => GestureDetector(
                onTap: () => onProfileTap(user),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        user?.displayName ?? '',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _Avatar(photoBase64: user?.photoBase64),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textMuted, size: 22),
            onPressed: onSettings,
            tooltip: 'Configuración',
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoBase64;
  const _Avatar({this.photoBase64});

  @override
  Widget build(BuildContext context) {
    final bytes = ImageUtils.decodeBase64(photoBase64);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        color: AppColors.surfaceElevated,
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes != null
          ? Image.memory(bytes, fit: BoxFit.cover)
          : const Icon(Icons.person_rounded, color: AppColors.textMuted, size: 20),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Stats card
// ──────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final List<GameModel> games;
  const _StatsCard({required this.games});

  @override
  Widget build(BuildContext context) {
    final playing = games.where((g) => g.categoria == GameCategory.inProgress).length;
    final pending = games.where((g) => g.categoria == GameCategory.toPlay).length;
    final completed = games.where((g) => g.categoria == GameCategory.completed).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withAlpha(40),
              AppColors.primary.withAlpha(10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withAlpha(60)),
        ),
        child: Row(
          children: [
            _StatCell(label: 'Todos', count: games.length, color: AppColors.primary),
            _Divider(),
            _StatCell(label: 'Jugando', count: playing, color: AppColors.statusPlaying),
            _Divider(),
            _StatCell(label: 'Pendientes', count: pending, color: AppColors.statusPending),
            _Divider(),
            _StatCell(label: 'Completados', count: completed, color: AppColors.statusCompleted),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatCell({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 34, color: AppColors.border);
}

// ──────────────────────────────────────────────────────────────
// Search bar
// ──────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasQuery;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hasQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar juego...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Category filter chips
// ──────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final GameCategory selected;
  final ValueChanged<GameCategory> onSelect;
  final List<GameModel> games;

  const _FilterChips({
    required this.selected,
    required this.onSelect,
    required this.games,
  });

  int _count(GameCategory cat) {
    if (cat == GameCategory.all) return games.length;
    return games.where((g) => g.categoria == cat).length;
  }

  @override
  Widget build(BuildContext context) {
    final cats = [
      GameCategory.all,
      GameCategory.inProgress,
      GameCategory.toPlay,
      GameCategory.completed,
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        itemCount: cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = cats[i];
          final isSelected = selected == cat;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            child: FilterChip(
              label: Text('${cat.displayName}  ${_count(cat)}'),
              selected: isSelected,
              onSelected: (_) => onSelect(cat),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryDim,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
              labelStyle: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Error state
// ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los juegos',
              style: GoogleFonts.nunitoSans(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifica tu conexión a internet\ne inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
