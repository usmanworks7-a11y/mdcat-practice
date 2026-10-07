import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_session.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../config.dart';
import '../widgets/common.dart';
import 'test_screen.dart';

class MockSetupScreen extends StatefulWidget {
  const MockSetupScreen({super.key});
  @override
  State<MockSetupScreen> createState() => _S();
}

class _S extends State<MockSetupScreen> {
  int count = 50;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final qs = s.mixed(count); // only used to count; the real test is made on Start
    return Scaffold(
      appBar: AppBar(title: const Text(T.mockTest)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        heading(T.howMany),
        Picker<int>(items: mockCounts, value: count, label: (c) => '$c', onChanged: (v) => setState(() => count = v)),
        const SizedBox(height: 16),
        infoText(T.mockInfo),
        if (qs.isEmpty) infoText(T.noMatch) else if (qs.length < count) infoText(T.onlyAvailable(qs.length)),
        const SizedBox(height: 8),
        BigButton(T.start, onTap: qs.isEmpty ? null : () {
          final real = s.mixed(count);
          openScreen(context, TestScreen(session: TestSession.start(T.mockTest, true, real)));
        }),
      ]),
    );
  }
}
