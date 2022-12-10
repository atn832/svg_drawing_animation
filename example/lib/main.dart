import 'package:flutter/material.dart';
import 'package:svg_drawing_animation/svg_drawing_animation.dart';

import 'kanji_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
          appBar: AppBar(title: const Text('Example')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Card(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: SvgDrawingAnimation(
                    SvgProviders.string(kanjiSvg),
                    duration: const Duration(seconds: 2),
                    repeats: true,
                  ),
                ),
              ),
              Card(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: SvgDrawingAnimation(
                    SvgProviders.string(kanjiSvg),
                    duration: const Duration(seconds: 2),
                    curve: Curves.decelerate,
                    repeats: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('SVG from URL'),
              Card(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: SvgDrawingAnimation(
                    SvgProviders.network(
                        'https://upload.wikimedia.org/wikipedia/commons/4/4a/African_Elephant_SVG.svg'),
                    duration: const Duration(seconds: 10),
                    repeats: false,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Error handling'),
              Card(
                child: SizedBox(
                  width: 300,
                  height: 30,
                  child: SvgDrawingAnimation(
                    SvgProviders.string('<some invalid svg'),
                    duration: const Duration(seconds: 10),
                  ),
                ),
              ),
            ]),
          )),
    );
  }
}
