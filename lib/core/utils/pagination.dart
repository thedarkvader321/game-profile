import 'dart:math' as math;

/// Resultado de paginar una lista.
class PageSlice<T> {
  final List<T> items;
  final int page; // índice base 0, ya ajustado al rango válido
  final int totalPages;

  const PageSlice({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  bool get hasPrevious => page > 0;
  bool get hasNext => page < totalPages - 1;
}

/// Cantidad de registros por página en la biblioteca.
const int kGamesPerPage = 10;

/// Devuelve la página [page] (base 0) de [all]. Si [page] está fuera de
/// rango (por ejemplo, tras eliminar juegos o aplicar un filtro) se ajusta
/// a la última página válida.
PageSlice<T> paginate<T>(
  List<T> all,
  int page, {
  int pageSize = kGamesPerPage,
}) {
  assert(pageSize > 0, 'pageSize debe ser mayor que 0');
  final totalPages = math.max(1, (all.length / pageSize).ceil());
  final int safePage = math.min(math.max(page, 0), totalPages - 1);
  final start = safePage * pageSize;
  final end = math.min(start + pageSize, all.length);
  return PageSlice<T>(
    items: all.sublist(start, end),
    page: safePage,
    totalPages: totalPages,
  );
}
