import 'package:gal/gal.dart';
import 'image_utils.dart';

enum SaveImageResult {
  saved,
  noImage,
  accessDenied,
  notEnoughSpace,
  unsupportedFormat,
  failed,
}

/// Guarda en la galería del teléfono una imagen almacenada como base64.
/// No usa ninguna API externa: la imagen ya está en la app.
class GallerySaver {
  GallerySaver._();

  static Future<SaveImageResult> saveBase64(String? imageBase64) async {
    final bytes = ImageUtils.decodeBase64(imageBase64);
    if (bytes == null || bytes.isEmpty) return SaveImageResult.noImage;

    try {
      if (!await Gal.hasAccess()) {
        if (!await Gal.requestAccess()) return SaveImageResult.accessDenied;
      }
      await Gal.putImageBytes(bytes);
      return SaveImageResult.saved;
    } on GalException catch (e) {
      if (e.type == GalExceptionType.accessDenied) {
        return SaveImageResult.accessDenied;
      }
      if (e.type == GalExceptionType.notEnoughSpace) {
        return SaveImageResult.notEnoughSpace;
      }
      if (e.type == GalExceptionType.notSupportedFormat) {
        return SaveImageResult.unsupportedFormat;
      }
      return SaveImageResult.failed;
    } catch (_) {
      return SaveImageResult.failed;
    }
  }

  static String messageFor(SaveImageResult result) => switch (result) {
        SaveImageResult.saved => 'Carátula guardada en tu galería',
        SaveImageResult.noImage => 'Este juego no tiene imagen para guardar',
        SaveImageResult.accessDenied =>
          'Sin permiso para guardar en la galería. Actívalo en los ajustes del teléfono.',
        SaveImageResult.notEnoughSpace => 'No hay espacio suficiente en el teléfono',
        SaveImageResult.unsupportedFormat => 'Formato de imagen no compatible',
        SaveImageResult.failed => 'No se pudo guardar la imagen. Inténtalo de nuevo.',
      };
}
