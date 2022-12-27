# SVG Drawing Animation

[![pub package](https://img.shields.io/pub/v/svg_drawing_animation.svg)](https://pub.dartlang.org/packages/svg_drawing_animation)

Widget for drawing line animations of SVG. For now, it only renders paths. Feel free to propose pull requests if you want to support a new feature.

<img src="https://github.com/atn832/svg_drawing_animation/raw/main/svg_drawing_animation.gif" width="360" />

## Features

- load SVG from any source (string, network...). See built-in [SvgProvider]s.
- supports [Duration] and speed.
- supports [Curve]s.
- customizable loading and error state.
- customizable "pen" rendering.

See [SvgDrawingAnimation] for more.

## Difference with other packages

- [drawing_animation](https://pub.dartlang.org/packages/drawing_animation) served as inspiration for this package. It appears not to be maintained any more. Check out the table below for differences.
- [flutter_svg](https://pub.dev/packages/flutter_svg) provides a Widget to render static SVG. We use flutter_svg to parse SVG.
- [animated_svg](https://pub.dev/packages/animated_svg) makes smooth transitions between two different SVG.

| Feature | this package | drawing animation |
| --- | --- | --- |
| Draws animations of SVG | ✅ | ✅ |
| Load SVG from String | ✅ | ❌ |
| Load SVG from Network | ✅ | ❌ |
| Load SVG from Assets | ✅ | ✅ |
| Load SVG from File | ✅ | ❌ |
| Recursive style (eg a group's style applies to its children) | ✅ | ❌ |
| Duration, Curve, repeats | ✅ | ✅ |
| Speed instead of Duration | ✅ | ❌ |
| Draws the Pen | ✅ | ❌ |
| Line orders (in order, all at once, top to bottom...) | ❌ | ✅ |

## Usage

### Basic Usage

```dart
import 'package:svg_drawing_animation/svg_drawing_animation.dart';
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
        home: Scaffold(
            appBar: AppBar(title: const Text('Example')),
            body: Center(
                child: SvgDrawingAnimation(
              SvgProvider.network(
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
  home: Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Center(
          child: SizedBox(
              width: 300,
              height: 300,
              child: SvgDrawingAnimation(
        SvgProvider.network(
            'https://upload.wikimedia.org/wikipedia/commons/4/4a/African_Elephant_SVG.svg'),
        duration: const Duration(seconds: 10),
      )))));
```

### With curves and repeat

```dart
SvgDrawingAnimation(
    SvgProvider.network(
        'https://upload.wikimedia.org/wikipedia/commons/4/4a/African_Elephant_SVG.svg'),
    duration: const Duration(seconds: 10),
    curve: Curves.decelerate,
    repeats: true)
```

### Speed instead of duration

```dart
SvgDrawingAnimation(
    SvgProvider.network(
        'https://upload.wikimedia.org/wikipedia/commons/4/4a/African_Elephant_SVG.svg'),
    speed: 100,
    repeats: true)
```

### Custom progress indicator

```dart
SvgDrawingAnimation(
    SvgProvider.network(
        'https://upload.wikimedia.org/wikipedia/commons/4/4a/African_Elephant_SVG.svg'),
    duration: const Duration(seconds: 4),
    loadingWidgetBuilder: (context) => Center(child: LinearProgressIndicator()))
```

### Custom error handling

By default svg_drawing_animation shows an error message when an error occurs, but
you can customize what to show to the user instead.

```dart
SvgDrawingAnimation(
    SvgProvider.network(
        'https://upload.wikimedia.org/wikipedia/commons/4/4a/African_Elephant_SVG.svg'),
    duration: const Duration(seconds: 4),
    errorWidgetBuilder: (context) => Text('Oops! Something went wrong.'))
```

### Drawing the Pen

```dart
SvgDrawingAnimation(
    SvgProvider.network(
        'https://upload.wikimedia.org/wikipedia/commons/4/4a/African_Elephant_SVG.svg'),
    duration: const Duration(seconds: 4),
    penRenderer: CirclePenRenderer(radius: 15))
```

## Design choices

### Constructor parameters: Duration, Curve, repeats

We've followed the style of [ImplicitlyAnimatedWidget], which take a [Duration], a [Curve] and a `repeats` flag similar to [AnimatedRotation.turns]. This allows for a good amount of customization without having to mess with AnimationControllers and StatefulWidgets.

See <https://docs.flutter.dev/development/ui/animations> for comprehensive information on animations.

### SvgProvider

Flutter's [Image] widdget uses an [ImageProvider], while flutter_svg's [SvgPicture] uses a similar [PictureProvider] pattern. We follow that architecture by introducing an [SvgProvider] with Futures instead of Streams for simplicity.

### Loading and Error states

We allow custom rendering of loading and error states similar to Image's [ImageLoadingBuilder] and [ImageErrorWidgetBuilder].

## Developing

### Re-generating http.Client mocks

Run `flutter pub run build_runner build`. See [Flutter Cookbook on Mockito](https://docs.flutter.dev/cookbook/testing/unit/mocking#3-create-a-test-file-with-a-mock-httpclient).
