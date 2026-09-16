import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/practice_repository.dart';
import 'features/practice/practice_controller.dart';
import 'features/practice/practice_page.dart';

class SpeakLoopApp extends StatelessWidget {
  const SpeakLoopApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SpeakLoop',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F1E7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF177E79),
        brightness: Brightness.light,
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: const Color(0xFF20322F),
        displayColor: const Color(0xFF20322F),
      ),
      focusColor: const Color(0x33177E79),
    ),
    home: const _Bootstrap(),
  );
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  PracticeController? controller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = PracticeController(
      SharedPreferencesPracticeRepository(preferences),
    );
    await value.initialize();
    if (mounted) setState(() => controller = value);
  }

  @override
  Widget build(BuildContext context) => controller == null
      ? const Scaffold(body: Center(child: CircularProgressIndicator()))
      : PracticePage(controller: controller!);

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
