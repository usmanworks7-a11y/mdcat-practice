import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../widgets/common.dart';
import 'past_papers_screen.dart';
import 'subject_screen.dart';
import 'mock_setup_screen.dart';
import 'saved_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import 'test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text(T.appName)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (s.updating) ...[
          const LinearProgressIndicator(),
          infoText(T.updating),
        ] else if (s.updateInfo != null)
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(T.newMcqs, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                FilledButton(onPressed: s.doUpdate, child: const Text(T.updateNow)),
              ]),
            ),
          ),
        if (s.message != null)
          Card(
            child: ListTile(
              title: Text(s.message!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              trailing: TextButton(onPressed: s.dismissMessage, child: const Text('OK')),
            ),
          ),
        if (s.questions.isEmpty) infoText(T.noData),
        if (s.hasSession)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(T.unfinished, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(children: [
                  FilledButton(
                    onPressed: () {
                      final t = s.loadSession();
                      if (t == null) {
                        s.clearSession();
                      } else {
                        openScreen(context, TestScreen(session: t));
                      }
                    },
                    child: const Text(T.continueTest),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(onPressed: s.clearSession, child: const Text(T.discard)),
                ]),
              ]),
            ),
          ),
        const SizedBox(height: 8),
        BigButton(T.pastPapers, onTap: () => openScreen(context, const PastPapersScreen())),
        BigButton(T.subjectPractice, onTap: () => openScreen(context, const SubjectScreen())),
        BigButton(T.mockTest, onTap: () => openScreen(context, const MockSetupScreen())),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: SizedBox(height: 52, child: OutlinedButton(
              onPressed: () => openScreen(context, const SavedScreen()), child: const Text(T.savedQuestions, textAlign: TextAlign.center)))),
          const SizedBox(width: 12),
          Expanded(child: SizedBox(height: 52, child: OutlinedButton(
              onPressed: () => openScreen(context, const ProgressScreen()), child: const Text(T.myProgress, textAlign: TextAlign.center)))),
        ]),
        const SizedBox(height: 12),
        SizedBox(height: 48, child: TextButton.icon(
            onPressed: () => openScreen(context, const SettingsScreen()),
            icon: const Icon(Icons.settings), label: const Text(T.settings))),
      ]),
    );
  }
}
