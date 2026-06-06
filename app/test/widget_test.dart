// Basit smoke test. Tam uygulama (NotaOyunApp) ses/asset/prefs başlatması
// gerektirdiğinden, burada hafif bir widget testiyle yetiniyoruz; iş mantığı
// testleri models_test / play_controller_test / progress_service_test'te.
//
// Not: Bu dosya bilerek var — `flutter create` aksi halde MyApp'e referans
// veren bozuk bir varsayılan widget_test.dart üretiyor.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notaoyun/theme/app_theme.dart';

void main() {
  testWidgets('tema kurulu MaterialApp render olur', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildNotaOyunTheme(),
        home: const Scaffold(body: Center(child: Text('NotaOyun'))),
      ),
    );

    expect(find.text('NotaOyun'), findsOneWidget);
  });
}
