import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';

/// Provides SVG. See [SvgProviders] for predefined providers.
typedef SvgProvider = Future<DrawableRoot>;

/// Provides utility functions to obtain SVG.
class SvgProviders {
  /// Obtains SVG from a String.
  static SvgProvider string(String svgString) {
    return SvgParser().parse(svgString);
  }

  /// Obtains SVG from a URL.
  static SvgProvider network(String src, [Client? client]) async {
    final response = await (client ?? Client()).get(Uri.parse(src));
    if (response.statusCode != 200) {
      return Future.error([
        if (response.reasonPhrase != null) response.reasonPhrase,
        response.body
      ].join(': '));
    }
    return string(response.body);
  }

  /// Obtains SVG from a [File].
  static SvgProvider file(File file) async {
    // For some reason, unit tests freeze if I use `await file.readAsString()`.
    return string(file.readAsStringSync());
  }

  /// Obtains SVG from an [AssetBundle] using a key.
  static SvgProvider asset(String name) async {
    return string(await rootBundle.loadString(name));
  }
}
