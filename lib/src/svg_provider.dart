import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';

typedef SvgProvider = Future<DrawableRoot>;

class SvgProviders {
  static SvgProvider string(String svgString) {
    return SvgParser().parse(svgString);
  }

  static SvgProvider network(String src) async {
    final response = await http.get(Uri.parse(src));
    return string(response.body);
  }

  static SvgProvider file(File file) async {
    return string(await file.readAsString());
  }

  static SvgProvider asset(String name) async {
    return string(await rootBundle.loadString(name));
  }
}
