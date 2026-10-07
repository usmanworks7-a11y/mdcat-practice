import 'package:flutter/material.dart';
import '../models/test_session.dart';
import '../strings.dart';
import '../utils/helpers.dart';
import '../widgets/common.dart';
import 'review_screen.dart';
import 'test_screen.dart';

class ResultScreen extends StatelessWidget {
  final TestSession session;
  final int seconds;
  final bool timeUp;
  const ResultScreen({super.key, required this.session, required this.seconds, this.timeUp = false});

  @override
  Widget build(BuildContext context) {
    final s = session;
    final total = s.qs.length;
    final score = s.score;
    final pct = total == 0 ? 0 : (score * 100 / total).round();
    // Group the score by subject.
    final per = <String, List<int>>{};
    for (var i = 0; i < total; i++) {
      final e = per.putIfAbsent(s.qs[i].subject, () => [0, 0]);
      e[1]++;
      if (s.answers[i] == s.qs[i].correctIndex) e[0]++;
    }
    final retry = [for (var i = 0; i < total; i++) if (s.answers[i] != s.qs[i].correctIndex) s.qs[i]];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.popUntil(context, (r) => r.isFirst);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(T.result), automaticallyImplyLeading: false),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          if (timeUp) infoText(T.timeUp),
          Text('$score / $total ($pct%)', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
          infoText(T.timeTaken(fmtTime(seconds))),
          heading(T.scoreBySubject),
          for (final e in per.entries) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(cap(e.key), style: const TextStyle(fontSize: 16)),
              Text('${e.value[0]} / ${e.value[1]} (${(e.value[0] * 100 / e.value[1]).round()}%)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: e.value[0] / e.value[1], minHeight: 10),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 8),
          BigButton(T.reviewAnswers, onTap: () => openScreen(context, ReviewScreen(session: s))),
          if (retry.isNotEmpty)
            BigButton(T.retryWrong, filled: false, onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => TestScreen(session: TestSession.start(T.retryWrong, false, retry))));
            }),
          BigButton(T.backHome, filled: false, onTap: () => Navigator.popUntil(context, (r) => r.isFirst)),
        ]),
      ),
    );
  }
}
