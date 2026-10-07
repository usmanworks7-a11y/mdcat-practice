import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'state/app_state.dart';
import 'strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  try {
    await state.init();
  } catch (_) {} // the app must still open
  runApp(ChangeNotifierProvider.value(value: state, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _theme(Brightness b) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6B66), brightness: b),
    );
    final t = base.textTheme;
    return base.copyWith(
      textTheme: t.copyWith(
        bodyMedium: t.bodyMedium?.copyWith(fontSize: 16),
        bodyLarge: t.bodyLarge?.copyWith(fontSize: 18),
        labelLarge: t.labelLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return MaterialApp(
      title: T.appName,
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: s.dark ? ThemeMode.dark : ThemeMode.light,
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(s.large ? 1.2 : 1.0)),
        child: child ?? const SizedBox(),
      ),
      home: const HomeScreen(),
    );
  }
}
