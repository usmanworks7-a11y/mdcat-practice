import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_session.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../utils/helpers.dart';
import '../widgets/common.dart';
import '../widgets/option_tile.dart';
import 'result_screen.dart';

// Shared screen for practice mode and mock test.
class TestScreen extends StatefulWidget {
  final TestSession session;
  const TestScreen({super.key, required this.session});
  @override
  State<TestScreen> createState() => _S();
}

class _S extends State<TestScreen> {
  Timer? _timer;
  int _left = 0;
  bool _done = false;

  TestSession get s => widget.session;

  @override
  void initState() {
    super.initState();
    context.read<AppState>().saveSession(s);
    if (s.mock) {
      _tick();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final left = ((s.endMillis - DateTime.now().millisecondsSinceEpoch) / 1000).ceil();
    if (left <= 0) {
      _finish(timeUp: true);
    } else if (mounted) {
      setState(() => _left = left);
    }
  }

  void _save() => context.read<AppState>().saveSession(s);

  // Ends the test, saves progress and opens the result screen.
  void _finish({bool timeUp = false}) {
    if (_done || !mounted) return;
    _done = true;
    _timer?.cancel();
    final used = ((DateTime.now().millisecondsSinceEpoch - s.startMillis) / 1000).round();
    final shown = s.mock && used > s.totalSeconds ? s.totalSeconds : used;
    context.read<AppState>().recordTest(s);
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ResultScreen(session: s, seconds: shown, timeUp: timeUp)));
  }

  Future<void> _submit() async {
    final left = s.qs.length - s.answers.length;
    final ok = await confirmDialog(context, T.submitTitle, T.submitBody(left), T.submit, T.keepGoing);
    if (ok) _finish();
  }

  void _choose(int i) {
    if (!s.mock && s.answers.containsKey(s.index)) return; // practice: answer is locked
    setState(() => s.answers[s.index] = i);
    _save();
  }

  void _go(int i) {
    setState(() => s.index = i);
    _save();
  }

  void _openList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(T.questionList, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: s.qs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.1),
                itemBuilder: (c, i) {
                  final fl = s.flags.contains(i);
                  final an = s.answers.containsKey(i);
                  final word = fl ? T.flagged : (an ? T.answered : T.notAnswered);
                  final color = fl ? Colors.amber.shade700 : (an ? Colors.green.shade700 : Colors.grey);
                  return InkWell(
                    onTap: () {
                      Navigator.pop(c);
                      _go(i);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: color, width: i == s.index ? 4 : 2),
                        color: color.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('${i + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(word, style: const TextStyle(fontSize: 12)),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final q = s.qs[s.index];
    final chosen = s.answers[s.index];
    final locked = !s.mock && chosen != null;
    final last = s.index == s.qs.length - 1;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await confirmDialog(context, T.leaveTitle, T.leaveBody, T.leave, T.stay);
        if (ok && mounted) {
          _done = true;
          _timer?.cancel();
          app.clearSession();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.title),
          actions: [
            if (s.mock)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(children: [
                  const Icon(Icons.timer),
                  const SizedBox(width: 4),
                  Text(fmtTime(_left), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ]),
              ),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(T.questionOf(s.index + 1, s.qs.length), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton.icon(
                  onPressed: () => app.toggleSave(q.id),
                  icon: Icon(app.isSaved(q.id) ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(yesNoSave(app.isSaved(q.id))),
                ),
              ]),
              const SizedBox(height: 8),
              Text(q.question, style: const TextStyle(fontSize: 19, height: 1.4, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              for (var i = 0; i < 4; i++) _option(i, q.options[i], q.correctIndex, chosen, locked),
              if (locked) _feedback(chosen == q.correctIndex, q.explanation),
              if (!s.mock && !locked) infoText(T.chooseAnswer),
            ]),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: s.mock ? _mockBar(last) : _practiceBar(locked, last),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _option(int i, String text, int correct, int? chosen, bool locked) {
    var st = OptState.none;
    var label = '';
    if (locked) {
      if (i == correct) { st = OptState.correct; label = T.correctAnswer; }
      else if (i == chosen) { st = OptState.wrong; label = T.yourAnswer; }
    } else if (s.mock && chosen == i) {
      st = OptState.selected;
      label = T.selected;
    }
    return OptionTile(letter: 'ABCD'[i], text: text, state: st, label: label, onTap: () => _choose(i));
  }

  Widget _feedback(bool ok, String explanation) {
    final c = ok ? Colors.green.shade700 : Colors.red.shade700;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: c.withAlpha(40), borderRadius: BorderRadius.circular(10), border: Border.all(color: c)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ok ? T.correct : T.wrong, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        if (explanation.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(explanation, style: const TextStyle(fontSize: 16, height: 1.4)),
        ],
      ]),
    );
  }

  Widget _practiceBar(bool locked, bool last) {
    if (!locked) return const SizedBox(height: 0);
    return BigButton(last ? T.finish : T.next, onTap: () => last ? _finish() : _go(s.index + 1));
  }

  Widget _mockBar(bool last) {
    final fl = s.flags.contains(s.index);
    Widget b(String t, VoidCallback? f, {bool filled = false}) => Expanded(
          child: SizedBox(
            height: 48,
            child: filled
                ? FilledButton(onPressed: f, child: Text(t, textAlign: TextAlign.center))
                : OutlinedButton(onPressed: f, child: Text(t, textAlign: TextAlign.center)),
          ),
        );
    const gap = SizedBox(width: 8);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        b(T.previous, s.index == 0 ? null : () => _go(s.index - 1)),
        gap,
        b(T.next, last ? null : () => _go(s.index + 1)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        b(fl ? T.flagged : T.flag, () {
          setState(() => fl ? s.flags.remove(s.index) : s.flags.add(s.index));
          _save();
        }),
        gap,
        b(T.list, _openList),
        gap,
        b(T.submit, _submit, filled: true),
      ]),
    ]);
  }
}
