import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../utils/helpers.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _S();
}

class _S extends State<SettingsScreen> {
  String? note;
  bool checking = false;

  Widget _row(String a, String b) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(a, style: const TextStyle(fontSize: 16)),
          Text(b, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text(T.settings)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        heading(T.textSize),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text(T.normal)),
            ButtonSegment(value: true, label: Text(T.large)),
          ],
          selected: {s.large},
          onSelectionChanged: (v) => s.setLarge(v.first),
        ),
        heading(T.theme),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text(T.light)),
            ButtonSegment(value: true, label: Text(T.dark)),
          ],
          selected: {s.dark},
          onSelectionChanged: (v) => s.setDark(v.first),
        ),
        const SizedBox(height: 24),
        BigButton(T.checkUpdates, filled: false, onTap: checking ? null : () async {
          setState(() => checking = true);
          final r = await s.checkUpdate();
          if (!mounted) return;
          setState(() {
            checking = false;
            note = r == 1 ? T.newMcqs : (r == 0 ? T.latest : T.checkFailed);
          });
        }),
        if (note != null) infoText(note!),
        if (s.updateInfo != null && !s.updating) BigButton(T.updateNow, onTap: s.doUpdate),
        if (s.updating) infoText(T.updating),
        if (s.message != null) infoText(s.message!),
        const SizedBox(height: 16),
        _row(T.appVersionLabel, appVersion),
        _row(T.dataVersionLabel, '${s.dataVersion}'),
        _row(T.totalQuestions, fmtNum(s.questions.length)),
      ]),
    );
  }
}
