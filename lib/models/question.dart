import 'dart:convert';

class Question {
  final String id, question, a, b, c, d, correct, explanation, subject, board, difficulty;
  final int year;
  final String chapter; // empty text = no chapter data
  const Question({
    required this.id, required this.question, required this.a, required this.b,
    required this.c, required this.d, required this.correct, required this.explanation,
    required this.subject, required this.board, required this.difficulty,
    required this.year, required this.chapter,
  });

  List<String> get options => [a, b, c, d];
  int get correctIndex => 'abcd'.indexOf(correct);

  // Removes tags like "(Practice Set 26)" at the end of the text.
  static String clean(String t) =>
      t.replaceAll(RegExp(r'\s*\(\s*Practice Set\s*\d+\s*\)\s*$', caseSensitive: false), '').trim();

  // Returns null if the row is broken. Broken rows are skipped.
  static Question? tryParse(dynamic j) {
    try {
      if (j is! Map) return null;
      String g(String k) => (j[k] ?? '').toString().trim();
      final correct = g('correct').toLowerCase();
      final text = clean(g('question'));
      if (text.isEmpty || correct.length != 1 || !'abcd'.contains(correct)) return null;
      if (g('option_a').isEmpty || g('option_b').isEmpty) return null;
      return Question(
        id: g('id').isEmpty ? text.hashCode.toString() : g('id'),
        question: text,
        a: g('option_a'), b: g('option_b'), c: g('option_c'), d: g('option_d'),
        correct: correct,
        explanation: g('explanation'),
        subject: g('subject').toLowerCase(),
        board: g('board').toUpperCase(),
        difficulty: g('difficulty').toLowerCase(),
        year: int.tryParse(g('year')) ?? 0,
        chapter: g('chapter'), // optional field
      );
    } catch (_) {
      return null;
    }
  }
}

// Top-level function so it can run in the background (compute).
List<Question> parseQuestions(String text) {
  try {
    final d = jsonDecode(text);
    if (d is! List) return [];
    final out = <Question>[];
    for (final e in d) {
      final q = Question.tryParse(e);
      if (q != null) out.add(q);
    }
    return out;
  } catch (_) {
    return [];
  }
}
