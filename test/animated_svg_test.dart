import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:svg_drawing_animation/svg_drawing_animation.dart';
import 'package:svg_drawing_animation/svg_provider.dart';

import 'kanji_svg.dart';

// A line of length 1, transformed by a scale(2, 1). So the render length is 2.
const lineSvg = '''<svg height="10" width="10">
  <g transform="matrix(2 0 0 1 0 0)">
    <line x1="0" y1="0" x2="1" y2="0" />
  </g>
</svg>''';

void main() {
  test('length', () async {
    final parser = SvgParser();
    expect(
        SvgDrawingAnimation.getPathLengthSum(await parser.parse(lineSvg)), 2);
    expect(
        (SvgDrawingAnimation.getPathLengthSum(await parser.parse(kanjiSvg)) -
                455)
            .abs(),
        lessThan(1));
  });

  testWidgets('rendering', (widgetTester) async {
    await renderAndCheckGoldens(
        widgetTester, 'kanji', SvgProviders.string(kanjiSvg));
    await renderAndCheckGoldens(
        widgetTester,
        'elephant',
        SvgParser()
            .parse(File('test/African_Elephant.svg').readAsStringSync()));
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

  // No matter the duration, the elephant is incomplete. I don't know why.
  await widgetTester.pumpAndSettle(const Duration(seconds: 20));
  await expectLater(find.byType(MaterialApp),
      matchesGoldenFile('goldens/render_$description.png'));
}
