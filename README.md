# SVG Drawing Animation

Draws animated SVG paths. For now, it ignores any other shapes. Feel free to propose pull requests if you want to support a new feature.

## Difference with other packages

- [flutter_svg](https://pub.dev/packages/flutter_svg). flutter_svg provides a Widget to render static SVGs. svg_drawing_animation uses flutter_svg to parse SVG.
- [drawing_animation](https://pub.dartlang.org/packages/drawing_animation). While svg_drawing_animation is heavily inspired from it, svg_drawing_animation supports more features such as loading an SVG on the network or files, recursive stroke styles (eg a stroke style on a group applies to all child paths)...
- [animated_svg](https://pub.dev/packages/animated_svg) makes smooth transitions between two different SVGs.

## Features

- load an SVG by string or network.
- supports [Duration](https://api.flutter.dev/flutter/dart-core/Duration-class.html).
- supports [Curves](https://api.flutter.dev/flutter/animation/Curve-class.html).
- customizable loading state.

## Usage

### Basic Usage

```dart
import 'package:animated_svg/animated_svg.dart';
import 'package:animated_svg/svg_provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(title: const Text('Example')),
            body: Center(
                child: AnimatedSvg(
              SvgProviders.network(
                  'https://upload.wikimedia.org/wikipedia/commons/4/4a/African_Elephant_SVG.svg'),
              duration: const Duration(seconds: 10),
            ))));
  }
}
```

### Fit it in a box

```dart
MaterialApp(
  title: 'Flutter Demo',
  theme: ThemeData(
    primarySwatch: Colors.blue,
  ),
  home: Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Center(
          child: SizedBox(
              width: 300,
              height: 300,
              child: AnimatedSvg(
        SvgProviders.network(
            'https://upload.wikimedia.org/wikipedia/commons/4/4a/African_Elephant_SVG.svg'),
        duration: const Duration(seconds: 10),
      )))));
```

### With curves and repeat

```dart
AnimatedSvg(
    SvgProviders.network(
        'https://upload.wikimedia.org/wikipedia/commons/4/4a/African_Elephant_SVG.svg'),
    duration: const Duration(seconds: 10),
    curve: Curves.decelerate,
    repeats: true,
```

## Design choices

We've followed the style of [ImplicitAnimations](https://api.flutter.dev/flutter/widgets/ImplicitlyAnimatedWidget-class.html), which take a [Duration](https://api.flutter.dev/flutter/dart-core/Duration-class.html), a [Curve](https://api.flutter.dev/flutter/animation/Curve-class.html) and a `repeats` flag similar to [AnimatedRotation's turns](https://api.flutter.dev/flutter/widgets/AnimatedRotation/turns.html). This allows for a good amount of customization without having to mess with Animations and StatefulWidgets.

See <https://docs.flutter.dev/development/ui/animations> for comprehensive information on animations.
