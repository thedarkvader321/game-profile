import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_profile/core/utils/modal_utils.dart';

Future<double> _measure(WidgetTester tester, MediaQueryData data,
    {double? extra}) async {
  late double result;
  await tester.pumpWidget(
    MediaQuery(
      data: data,
      child: Builder(
        builder: (ctx) {
          result = extra == null
              ? modalBottomPadding(ctx)
              : modalBottomPadding(ctx, extra: extra);
          return const SizedBox();
        },
      ),
    ),
  );
  return result;
}

void main() {
  testWidgets('sin teclado ni barra del sistema: solo el margen extra',
      (tester) async {
    expect(await _measure(tester, const MediaQueryData()), 28);
  });

  testWidgets('con barra de navegación del sistema suma su altura',
      (tester) async {
    final v = await _measure(
      tester,
      const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 48)),
    );
    expect(v, 48 + 28);
  });

  testWidgets('con teclado abierto usa la altura del teclado (sin duplicar)',
      (tester) async {
    final v = await _measure(
      tester,
      const MediaQueryData(
        viewPadding: EdgeInsets.only(bottom: 48),
        viewInsets: EdgeInsets.only(bottom: 300),
      ),
    );
    expect(v, 300 + 28);
  });

  testWidgets('respeta el margen extra personalizado', (tester) async {
    final v = await _measure(
      tester,
      const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 20)),
      extra: 32,
    );
    expect(v, 20 + 32);
  });
}
