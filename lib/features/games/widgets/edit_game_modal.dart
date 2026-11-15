import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/gallery_saver.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/modal_utils.dart';
import '../data/games_repository.dart';
import '../models/game_model.dart';
import 'modal_shared.dart';

class EditGameModal extends ConsumerStatefulWidget {
  final GameModel game;
  const EditGameModal({super.key, required this.game});

  @override
  ConsumerState<EditGameModal> createState() => _EditGameModalState();
}

class _EditGameModalState extends ConsumerState<EditGameModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late GameCategory _category;
  late String _imageBase64;
  bool _loading = false;
  bool _savingImage = false;
  SaveImageResult? _saveResult;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.game.nombre);
    _category = widget.game.categoria;
    _imageBase64 = widget.game.imageBase64;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final b64 = await ImageUtils.pickImageAsBase64();
    if (b64 != null) {
      setState(() {
        _imageBase64 = b64;
        _saveResult = null;
      });
    }
  }

  Future<void> _saveImageToGallery() async {
    setState(() {
      _savingImage = true;
      _saveResult = null;
    });
    final result = await GallerySaver.saveBase64(_imageBase64);
    if (!mounted) return;
    setState(() {
      _savingImage = false;
      _saveResult = result;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(gamesRepositoryProvider)!.update(
            gameId: widget.game.id,
            nombre: _nameCtrl.text.trim(),
            categoria: _category,
            imageBase64: _imageBase64,
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar los cambios. Inténtalo de nuevo.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar juego?'),
        content: Text(
          'Se eliminará "${widget.game.nombre}" de tu biblioteca.\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.nunitoSans(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Eliminar',
              style: GoogleFonts.nunitoSans(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await ref.read(gamesRepositoryProvider)!.delete(widget.game.id);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el juego.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = ImageUtils.decodeBase64(_imageBase64);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: modalBottomPadding(context),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModalHandle(),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Editar juego',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: _loading ? null : _confirmDelete,
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  tooltip: 'Eliminar juego',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withAlpha(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Nombre del juego',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa el nombre del juego' : null,
            ),
            const SizedBox(height: 16),

            Text(
              'Categoría',
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            CategoryChipsField(
              value: _category,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: imageBytes != null ? 160 : 72,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: imageBytes != null
                        ? AppColors.primary.withAlpha(100)
                        : AppColors.border,
                  ),
                ),
                child: imageBytes != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(imageBytes, fit: BoxFit.cover),
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: ImageChip(label: 'Cambiar imagen'),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Subir imagen  (opcional)',
                            style: GoogleFonts.nunitoSans(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            if (imageBytes != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('save_cover_button'),
                  onPressed: (_savingImage || _loading) ? null : _saveImageToGallery,
                  icon: _savingImage
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Guardar carátula en la galería'),
                ),
              ),
              if (_saveResult != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    GallerySaver.messageFor(_saveResult!),
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _saveResult == SaveImageResult.saved
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}
