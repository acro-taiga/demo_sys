import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/Resource/Strings.dart';
import 'dart:ui';

extension ContextEx on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorTheme => Theme.of(this).colorScheme;

  Size get screenSize => MediaQuery.of(this).size;

  double get screenHeight => MediaQuery.of(this).size.height;

  double get screenWidth => MediaQuery.of(this).size.width;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnack(
      SnackBar snackBar) {
    return ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}

class JaStrings implements FlutterPwValidatorStrings {
  @override
  final String atLeast = '8文字以上';
  @override
  final String uppercaseLetters = '大文字 -字以上';
  @override
  final String numericCharacters = '数字 -字以上';
  @override
  final String specialCharacters = '特殊文字 -字以上';

  @override
  // TODO: implement normalLetters
  String get normalLetters => "";
}

Map<int, Color> color = {
  50: Color(0xFFe9e9ed),
  100: Color(0xFFc8c8d1),
  200: Color(0xFFa3a3b3),
  300: Color(0xFF7e7e95),
  400: Color(0xFF62627e),
  500: Color(0xFF464667),
  600: Color(0xFF3f3f5f),
  700: Color(0xFF373754),
  800: Color(0xFF2f2f4a),
  900: Color(0xFF202039),
};

final MaterialColor primeColor = MaterialColor(0xFF2E2E48, color);

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
