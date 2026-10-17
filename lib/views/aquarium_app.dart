import 'package:flutter/material.dart';

import '../viewmodels/aquarium_view_model.dart';
import 'screens/aquarium_shell.dart';

class AquaTimerApp extends StatelessWidget {
  const AquaTimerApp({required this.viewModel, super.key});

  final AquariumViewModel viewModel;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AquaTimer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff006c68),
            primary: const Color(0xff006c68),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xfff1f7fc),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xffe2edf3)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xffe4f5fb),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: AquariumShell(viewModel: viewModel),
      );
}
