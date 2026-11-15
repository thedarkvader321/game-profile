import 'package:flutter_test/flutter_test.dart';
import 'package:game_profile/core/utils/pagination.dart';

List<int> _items(int n) => List<int>.generate(n, (i) => i);

void main() {
  group('paginate', () {
    test('lista vacía: una página vacía', () {
      final r = paginate<int>([], 0);
      expect(r.items, isEmpty);
      expect(r.page, 0);
      expect(r.totalPages, 1);
      expect(r.hasPrevious, isFalse);
      expect(r.hasNext, isFalse);
    });

    test('exactamente 10 registros caben en una sola página', () {
      final r = paginate(_items(10), 0);
      expect(r.items.length, 10);
      expect(r.totalPages, 1);
      expect(r.hasNext, isFalse);
    });

    test('11 registros generan 2 páginas (10 + 1)', () {
      final p0 = paginate(_items(11), 0);
      final p1 = paginate(_items(11), 1);
      expect(p0.totalPages, 2);
      expect(p0.items, _items(10));
      expect(p0.hasNext, isTrue);
      expect(p0.hasPrevious, isFalse);
      expect(p1.items, [10]);
      expect(p1.hasNext, isFalse);
      expect(p1.hasPrevious, isTrue);
    });

    test('25 registros: 3 páginas, la última con 5', () {
      final last = paginate(_items(25), 2);
      expect(last.totalPages, 3);
      expect(last.items, [20, 21, 22, 23, 24]);
    });

    test('página fuera de rango se ajusta a la última', () {
      final r = paginate(_items(15), 99);
      expect(r.page, 1);
      expect(r.items, [10, 11, 12, 13, 14]);
    });

    test('página negativa se ajusta a la primera', () {
      final r = paginate(_items(15), -3);
      expect(r.page, 0);
      expect(r.items.length, 10);
    });

    test('el tamaño por defecto es 10', () {
      expect(kGamesPerPage, 10);
    });
  });
}
