import 'question.dart';

// One running test (practice or mock).
class TestSession {
  final String title;
  final bool mock;
  final List<Question> qs;
  final Map<int, int> answers; // question number -> chosen option (0..3)
  final Set<int> flags;
  int index;
  final int totalSeconds;
  final int startMillis;
  final int endMillis;

  TestSession({
    required this.title, required this.mock, required this.qs,
    Map<int, int>? answers, Set<int>? flags, this.index = 0,
    required this.totalSeconds, required this.startMillis, required this.endMillis,
  })  : answers = answers ?? {},
        flags = flags ?? {};

  // Mock test: 1 minute for each question.
  factory TestSession.start(String title, bool mock, List<Question> qs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final total = mock ? qs.length * 60 : 0;
    return TestSession(title: title, mock: mock, qs: qs, totalSeconds: total,
        startMillis: now, endMillis: now + total * 1000);
  }

  int get score {
    var n = 0;
    for (var i = 0; i < qs.length; i++) {
      if (answers[i] == qs[i].correctIndex) n++;
    }
    return n;
  }

  Map<String, dynamic> toJson() => {
        'title': title, 'mock': mock, 'ids': qs.map((q) => q.id).toList(),
        'answers': answers.map((k, v) => MapEntry('$k', v)),
        'flags': flags.toList(), 'index': index, 'total': totalSeconds,
        'start': startMillis, 'end': endMillis,
      };

  static TestSession? fromJson(Map<String, dynamic> j, Map<String, Question> byId) {
    try {
      final qs = <Question>[];
      for (final id in (j['ids'] as List)) {
        final q = byId[id.toString()];
        if (q == null) return null;
        qs.add(q);
      }
      if (qs.isEmpty) return null;
      final idx = (j['index'] as num).toInt();
      return TestSession(
        title: j['title'] as String, mock: j['mock'] as bool, qs: qs,
        answers: (j['answers'] as Map).map((k, v) => MapEntry(int.parse(k as String), (v as num).toInt())),
        flags: (j['flags'] as List).map((e) => (e as num).toInt()).toSet(),
        index: idx >= 0 && idx < qs.length ? idx : 0,
        totalSeconds: (j['total'] as num).toInt(),
        startMillis: (j['start'] as num).toInt(), endMillis: (j['end'] as num).toInt(),
      );
    } catch (_) {
      return null;
    }
  }
}
