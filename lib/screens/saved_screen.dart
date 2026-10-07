import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_session.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../utils/helpers.dart';
import '../widgets/common.dart';
import 'test_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.savedQuestions;
    return Scaffold(
      appBar: AppBar(title: const Text(T.savedQuestions)),
      body: list.isEmpty
          ? Padding(padding: const EdgeInsets.all(16), child: infoText(T.noSaved))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length + 1,
              itemBuilder: (c, i) {
                if (i == 0) {
                  return BigButton(T.practiceSaved, onTap: () => openScreen(context,
                      TestScreen(session: TestSession.start(T.savedQuestions, false, List.of(list)..shuffle()))));
                }
                final q = list[i - 1];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(q.question, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17)),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(cap(q.subject), style: const TextStyle(fontSize: 16)),
                        TextButton.icon(onPressed: () => s.toggleSave(q.id), icon: const Icon(Icons.delete), label: const Text(T.remove)),
                      ]),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
