import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Espacio inferior para los bottom sheets: respeta la barra de navegación /
/// botones del sistema (viewPadding) y, si el teclado está abierto, usa la
/// altura del teclado. [extra] es el margen visual adicional.
double modalBottomPadding(BuildContext context, {double extra = 28}) {
  final mq = MediaQuery.of(context);
  return math.max(mq.viewInsets.bottom, mq.viewPadding.bottom) + extra;
}
