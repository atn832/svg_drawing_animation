import 'package:flutter/material.dart';

typedef LoadingWidgetBuilder = Widget Function(BuildContext context);

typedef ErrorWidgetBuilder = Widget Function(
    BuildContext context, Object error, StackTrace? stackTrace);

/// A loading widget builder that renders a [CircularProgressIndicator].
Widget defaultLoadingWidgetBuilder(context) =>
    const Center(child: CircularProgressIndicator());

/// An error widget builder that displays an error.
Widget defaultErrorWidgetBuilder(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
) =>
    Center(child: Text('Unable to load SVG: $error'));
