import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:svg_drawing_animation/src/clipped_path_painter.dart';
import 'package:svg_drawing_animation/svg_drawing_animation.dart';

import 'animated_svg_test.mocks.dart';
import 'kanji_svg.dart';

// A line of length 1, transformed by a scale(2, 1). So the render length is 2.
const lineSvg = '''<svg height="10" width="10">
  <g transform="matrix(2 0 0 1 0 0)">
    <line x1="0" y1="0" x2="1" y2="0" />
  </g>
</svg>''';

const kanjiLength = 455;

@GenerateMocks([http.Client])
void main() {
  test('length', () async {
    final parser = SvgParser();
    expect(
        SvgDrawingAnimation.getPathLengthSum(await parser.parse(lineSvg)), 2);
    expect(SvgDrawingAnimation.getPathLengthSum(await parser.parse(kanjiSvg)),
        455.5347023010254);
    expect(
        SvgDrawingAnimation.getPathLengthSum(
            await SvgProvider.file(File('test/African_Elephant.svg')).svg),
        3459.3614106178284);
  });

  testWidgets('clipped path painter', (widgetTester) async {
    await renderClippedPathPainterAndCheckGoldens(
        widgetTester,
        'kanji_10_percent',
        await SvgProvider.string(kanjiSvg).resolve(),
        .1 * kanjiLength);
    await renderClippedPathPainterAndCheckGoldens(
        widgetTester,
        'kanji_50_percent',
        await SvgProvider.string(kanjiSvg).resolve(),
        .5 * kanjiLength);
    await renderClippedPathPainterAndCheckGoldens(
        widgetTester,
        'kanji_100_percent',
        await SvgProvider.string(kanjiSvg).resolve(),
        1.0 * kanjiLength);
  });

  test('network error shows the network error instead of a XML parsing error',
      () async {
    final client = MockClient();

    when(client.get(Uri.parse('https://notfound/img.svg'))).thenAnswer(
        (_) async => http.Response(
            'https://notfound/img.svg was not found', 404,
            reasonPhrase: 'Not found'));
    expect(
        () => SvgProvider.network('https://notfound/img.svg', client).resolve(),
        throwsA('Not found: https://notfound/img.svg was not found'));
  });

  test('asset error', () async {
    // Check that it throws a FlutterError. The message states it cant't find
    // the asset but I can't figure out how to match partial content of the
    // FlutterError message.
    expect(() => SvgProvider.asset('unknown-asset').resolve(),
        throwsA(isA<FlutterError>()));
  });

  group('rendering', () {
    testWidgets('from string', (widgetTester) async {
      await renderAndCheckGoldens(
          widgetTester, 'kanji', SvgProvider.string(kanjiSvg));
    });
    testWidgets('from file', (widgetTester) async {
      await renderAndCheckGoldens(widgetTester, 'elephant',
          SvgProvider.file(File('test/African_Elephant.svg')));
    });
    testWidgets('error', (widgetTester) async {
      final Completer<DrawableRoot> completer = Completer();
      final m = SvgProvider.future(completer.future);
      await widgetTester.pumpWidget(MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(title: const Text('Example')),
            body: Center(
              child: Card(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: SvgDrawingAnimation(
                    m,
                    duration: const Duration(milliseconds: 500),
                    repeats: false,
                  ),
                ),
              ),
            )),
      ));
      completer.completeError('Bad SVG');
      await widgetTester.pumpAndSettle();
      expect(find.textContaining('Bad SVG'), findsOneWidget);
    });
  });
}

Future<void> renderAndCheckGoldens(WidgetTester widgetTester,
    String description, SvgProvider svgProvider) async {
  await widgetTester.pumpWidget(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: Center(
          child: Card(
            child: SizedBox(
              width: 300,
              height: 300,
              child: SvgDrawingAnimation(
                svgProvider,
                duration: const Duration(milliseconds: 500),
                repeats: false,
              ),
            ),
          ),
        )),
  ));

  await widgetTester.pumpAndSettle(const Duration(seconds: 20));

  await expectLater(find.byType(MaterialApp),
      matchesGoldenFile('goldens/render_$description.png'));
}

Future<void> renderClippedPathPainterAndCheckGoldens(WidgetTester widgetTester,
    String description, DrawableRoot svg, double pathLengthLimit) async {
  await widgetTester.pumpWidget(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: SizedBox.expand(
          child: FittedBox(
              child: SizedBox.fromSize(
                  size: svg.viewport.viewBox,
                  child: CustomPaint(
                    painter: ClippedPathPainter(svg,
                        pathLengthLimit: pathLengthLimit),
                  ))),
        ),
      )));

  await widgetTester.pumpAndSettle();

  await expectLater(find.byType(MaterialApp),
      matchesGoldenFile('goldens/clipped_path_$description.png'));
}
