import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_session.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../config.dart';
import '../utils/helpers.dart';
import '../widgets/common.dart';
import 'test_screen.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});
  @override
  State<SubjectScreen> createState() => _S();
}

class _S extends State<SubjectScreen> {
  String subject = subjects.first;
  String? difficulty, chapter;
  int count = 10;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final chapters = s.chaptersFor(subject); // empty = chapter data does not exist, so hide it
    if (chapter != null && !chapters.contains(chapter)) chapter = null;
    final pool = s.filter(subject: subject, difficulty: difficulty, chapter: chapter);
    final n = pool.length < count ? pool.length : count;
    return Scaffold(
      appBar: AppBar(title: const Text(T.subjectPractice)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        heading(T.subject),
        Picker<String>(items: subjects, value: subject, label: cap, onChanged: (v) => setState(() => subject = v)),
        heading(T.difficultyOpt),
        Picker<String?>(items: const [null, 'easy', 'medium', 'hard'], value: difficulty, label: (d) => d == null ? T.any : cap(d), onChanged: (v) => setState(() => difficulty = v)),
        if (chapters.isNotEmpty) ...[
          heading(T.chapterOpt),
          Picker<String?>(items: [null, ...chapters], value: chapter, label: (c) => c ?? T.any, onChanged: (v) => setState(() => chapter = v)),
        ],
        heading(T.howMany),
        Picker<int>(items: practiceCounts, value: count, label: (c) => '$c', onChanged: (v) => setState(() => count = v)),
        const SizedBox(height: 16),
        infoText(pool.isEmpty ? T.noMatch : (pool.length < count ? T.onlyAvailable(pool.length) : T.matches(pool.length))),
        BigButton(T.start, onTap: pool.isEmpty ? null : () {
          final qs = s.pick(pool, n);
          openScreen(context, TestScreen(session: TestSession.start(cap(subject), false, qs)));
        }),
      ]),
    );
  }
}
