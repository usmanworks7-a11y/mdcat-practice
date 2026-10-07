import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../utils/helpers.dart';
import '../widgets/common.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  Widget _row(String a, String b) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(a, style: const TextStyle(fontSize: 16)),
          Text(b, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    var n = 0, ok = 0;
    for (final v in s.bySubject.values) { n += v[0]; ok += v[1]; }
    final acc = s.bySubject.entries.where((e) => e.value[0] > 0).toList()
      ..sort((a, b) => (a.value[1] / a.value[0]).compareTo(b.value[1] / b.value[0]));
    int pct(List<int> v) => (v[1] * 100 / v[0]).round();
    final last = s.history.reversed.take(10).toList();
    return Scaffold(
      appBar: AppBar(title: const Text(T.myProgress)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (n == 0) infoText(T.noProgress),
        _row(T.attempted, '${fmtNum(s.attempted.length)}'),
        _row(T.accuracy, n == 0 ? '-' : '${(ok * 100 / n).round()}%'),
        if (acc.isNotEmpty) ...[
          heading(T.accBySubject),
          for (final e in acc) ...[
            _row(cap(e.key), '${pct(e.value)}%'),
            LinearProgressIndicator(value: e.value[1] / e.value[0], minHeight: 10),
          ],
          heading(T.weak),
          for (var i = 0; i < acc.length; i++) _row('${i + 1}. ${cap(acc[i].key)}', '${pct(acc[i].value)}%'),
        ],
        if (last.isNotEmpty) ...[
          heading(T.lastTests),
          for (final h in last)
            _row(DateTime.tryParse('${h['date']}')?.toLocal().toString().substring(0, 16) ?? '',
                '${h['score']} / ${h['total']} (${((h['score'] as num) * 100 / (h['total'] as num)).round()}%)'),
        ],
        const SizedBox(height: 24),
        BigButton(T.resetProgress, filled: false, onTap: () async {
          final yes = await confirmDialog(context, T.resetProgress, T.resetBody, T.reset, T.cancel);
          if (yes) s.resetProgress();
        }),
      ]),
    );
  }
}
