import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_session.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../config.dart';
import '../utils/helpers.dart';
import '../widgets/common.dart';
import 'test_screen.dart';

class PastPapersScreen extends StatefulWidget {
  const PastPapersScreen({super.key});
  @override
  State<PastPapersScreen> createState() => _S();
}

class _S extends State<PastPapersScreen> {
  int? year;
  String? board, subject;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final years = s.years;
    year ??= years.isEmpty ? null : years.first;
    final list = year == null ? <dynamic>[] : s.filter(year: year, board: board, subject: subject);
    return Scaffold(
      appBar: AppBar(title: const Text(T.pastPapers)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        heading(T.year),
        Picker<int>(items: years, value: year, label: (y) => '$y', onChanged: (v) => setState(() => year = v)),
        heading(T.boardOpt),
        Picker<String?>(items: [null, ...s.boards], value: board, label: (b) => b ?? T.any, onChanged: (v) => setState(() => board = v)),
        heading(T.subjectOpt),
        Picker<String?>(items: [null, ...subjects], value: subject, label: (b) => b == null ? T.any : cap(b), onChanged: (v) => setState(() => subject = v)),
        const SizedBox(height: 16),
        infoText(list.isEmpty ? T.noMatch : T.matches(list.length)),
        BigButton(T.start, onTap: list.isEmpty ? null : () {
          final qs = s.filter(year: year, board: board, subject: subject);
          openScreen(context, TestScreen(session: TestSession.start(T.pastPapers, false, qs)));
        }),
      ]),
    );
  }
}
