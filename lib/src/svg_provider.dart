import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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
  static SvgProvider network(String src) async {
    final response = await http.get(Uri.parse(src));
    return string(response.body);
  }

  /// Obtains SVG from a [File].
  static SvgProvider file(File file) async {
    return string(await file.readAsString());
  }

  /// Obtains SVG from an [AssetBundle] using a key.
  static SvgProvider asset(String name) async {
    return string(await rootBundle.loadString(name));
  }
}
