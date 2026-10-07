import 'package:flutter/material.dart';
import '../models/test_session.dart';
import '../strings.dart';
import '../utils/helpers.dart';
import '../widgets/option_tile.dart';

class ReviewScreen extends StatelessWidget {
  final TestSession session;
  const ReviewScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final s = session;
    return Scaffold(
      appBar: AppBar(title: const Text(T.reviewAnswers)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: s.qs.length,
        itemBuilder: (c, i) {
          final q = s.qs[i];
          final a = s.answers[i];
          final status = a == null ? T.notAnswered : (a == q.correctIndex ? T.correct : T.wrong);
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(T.questionOf(i + 1, s.qs.length), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(status, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ]),
                Text(cap(q.subject), style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(q.question, style: const TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                for (var k = 0; k < 4; k++)
                  OptionTile(
                    letter: 'ABCD'[k],
                    text: q.options[k],
                    state: k == q.correctIndex ? OptState.correct : (k == a ? OptState.wrong : OptState.none),
                    label: k == q.correctIndex ? (k == a ? '${T.correctAnswer} (${T.yourAnswer})' : T.correctAnswer) : (k == a ? T.yourAnswer : ''),
                  ),
                if (q.explanation.isNotEmpty) ...[
                  const Text(T.explanation, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(q.explanation, style: const TextStyle(fontSize: 16, height: 1.4)),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }
}
