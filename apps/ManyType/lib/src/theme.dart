import 'package:flutter/widgets.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_riverpod/manyui_riverpod.dart';

final themeModeProvider = mThemeModeProvider;

MThemeData manyTypeLightTheme() =>
    MThemeData.workbenchLight(primary: const Color(0xFF1E6A50));

MThemeData manyTypeDarkTheme() => MThemeData.workbenchDark(
  primary: const Color(0xFF75D2AD),
  primaryForeground: const Color(0xFF0E241B),
);
