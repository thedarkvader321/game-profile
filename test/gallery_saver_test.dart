import 'package:flutter_test/flutter_test.dart';
import 'package:game_profile/core/utils/gallery_saver.dart';

void main() {
  group('GallerySaver', () {
    test('sin imagen (null o vacía) devuelve noImage sin tocar la galería',
        () async {
      expect(await GallerySaver.saveBase64(null), SaveImageResult.noImage);
      expect(await GallerySaver.saveBase64(''), SaveImageResult.noImage);
    });

    test('base64 inválido devuelve noImage', () async {
      expect(await GallerySaver.saveBase64('%%%no-es-base64%%%'),
          SaveImageResult.noImage);
    });

    test('todos los resultados tienen mensaje no vacío', () {
      for (final r in SaveImageResult.values) {
        expect(GallerySaver.messageFor(r), isNotEmpty);
      }
    });
  });
}
