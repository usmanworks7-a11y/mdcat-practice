import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/question.dart';
import '../models/test_session.dart';
import '../services/data_service.dart';
import '../strings.dart';

class AppState extends ChangeNotifier {
  SharedPreferences? _p;
  List<Question> questions = [];
  int dataVersion = 0;
  bool large = false, dark = false;
  Set<String> saved = {}, wrong = {}, attempted = {};
  Map<String, List<int>> bySubject = {}; // subject -> [answered, correct]
  List<Map<String, dynamic>> history = [];
  Map<String, dynamic>? updateInfo; // set when a newer online version exists
  bool updating = false;
  bool hasSession = false;
  String? message;

  Future<void> init() async {
    try {
      _p = await SharedPreferences.getInstance();
      large = _p?.getBool('large') ?? false;
      dark = _p?.getBool('dark') ?? false;
      saved = (_p?.getStringList('saved') ?? []).toSet();
      wrong = (_p?.getStringList('wrong') ?? []).toSet();
      attempted = (_p?.getStringList('attempted') ?? []).toSet();
      hasSession = _p?.getString('session') != null;
      try {
        final m = jsonDecode(_p?.getString('bySubject') ?? '{}') as Map;
        bySubject = m.map((k, v) => MapEntry(k as String, List<int>.from(v as List)));
      } catch (_) {
        bySubject = {};
      }
      try {
        history = (jsonDecode(_p?.getString('history') ?? '[]') as List)
            .map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        history = [];
      }
    } catch (_) {}
    var qs = await DataService.loadSaved();
    if (qs.isEmpty) {
      qs = await DataService.loadBundled();
      dataVersion = await DataService.bundledVersion();
    } else {
      dataVersion = _p?.getInt('dataVersion') ?? 0;
    }
    questions = qs;
    checkUpdate(); // not awaited: it never blocks the app
  }

  void _savePrefs() {
    _p?.setStringList('saved', saved.toList());
    _p?.setStringList('wrong', wrong.toList());
    _p?.setStringList('attempted', attempted.toList());
    _p?.setString('bySubject', jsonEncode(bySubject));
    _p?.setString('history', jsonEncode(history));
  }

  // ---------- update ----------
  // Returns 1 = new data, 0 = latest, -1 = could not check.
  Future<int> checkUpdate() async {
    try {
      final info = await DataService.fetchVersion();
      if (info == null) return -1;
      if ((info['version'] as num).toInt() > dataVersion) {
        updateInfo = info;
        notifyListeners();
        return 1;
      }
      updateInfo = null;
      notifyListeners();
      return 0;
    } catch (_) {
      return -1;
    }
  }

  Future<void> doUpdate() async {
    if (updateInfo == null || updating) return;
    updating = true;
    message = null;
    notifyListeners();
    try {
      final qs = await DataService.download(updateInfo!);
      questions = qs;
      dataVersion = (updateInfo!['version'] as num).toInt();
      await _p?.setInt('dataVersion', dataVersion);
      updateInfo = null;
      message = T.updated(qs.length);
    } catch (_) {
      message = T.updateFailed;
    }
    updating = false;
    notifyListeners();
  }

  void dismissMessage() {
    message = null;
    notifyListeners();
  }

  // ---------- picking questions ----------
  // Filters the questions and removes repeated texts, so a test never repeats a question.
  List<Question> filter({String? subject, String? board, int? year, String? difficulty, String? chapter}) {
    final seen = <String>{};
    final out = <Question>[];
    for (final q in questions) {
      if (subject != null && q.subject != subject) continue;
      if (board != null && q.board != board) continue;
      if (year != null && q.year != year) continue;
      if (difficulty != null && q.difficulty != difficulty) continue;
      if (chapter != null && q.chapter != chapter) continue;
      if (seen.add(q.question.toLowerCase())) out.add(q);
    }
    return out;
  }

  List<int> get years => (questions.map((q) => q.year).where((y) => y > 0).toSet().toList()..sort((a, b) => b.compareTo(a)));
  List<String> get boards => (questions.map((q) => q.board).where((b) => b.isNotEmpty).toSet().toList()..sort());
  List<String> chaptersFor(String subject) =>
      (questions.where((q) => q.subject == subject && q.chapter.isNotEmpty).map((q) => q.chapter).toSet().toList()..sort());

  List<Question> pick(List<Question> pool, int n) {
    final l = List<Question>.of(pool)..shuffle();
    return l.take(n).toList();
  }

  // Mixes all subjects one by one, so each subject gets a fair share.
  List<Question> mixed(int n) {
    final lists = subjects.map((s) => pick(filter(subject: s), 100000)).toList();
    final out = <Question>[];
    var i = 0;
    while (out.length < n && lists.any((l) => i < l.length)) {
      for (final l in lists) {
        if (i < l.length && out.length < n) out.add(l[i]);
      }
      i++;
    }
    return out..shuffle();
  }

  // ---------- saved questions ----------
  bool isSaved(String id) => saved.contains(id);
  void toggleSave(String id) {
    if (!saved.remove(id)) saved.add(id);
    _savePrefs();
    notifyListeners();
  }

  List<Question> get savedQuestions => questions.where((q) => saved.contains(q.id)).toList();
  List<Question> wrongQuestions() => questions.where((q) => wrong.contains(q.id)).toList();

  // ---------- progress ----------
  void recordTest(TestSession t) {
    for (var i = 0; i < t.qs.length; i++) {
      final a = t.answers[i];
      if (a == null) continue;
      final q = t.qs[i];
      attempted.add(q.id);
      final st = bySubject.putIfAbsent(q.subject, () => [0, 0]);
      st[0]++;
      if (a == q.correctIndex) {
        st[1]++;
        wrong.remove(q.id);
      } else {
        wrong.add(q.id);
      }
    }
    history.add({'score': t.score, 'total': t.qs.length, 'date': DateTime.now().toIso8601String()});
    if (history.length > 50) history.removeAt(0);
    _savePrefs();
    clearSession();
  }

  void resetProgress() {
    attempted = {};
    wrong = {};
    bySubject = {};
    history = [];
    _savePrefs();
    notifyListeners();
  }

  // ---------- settings ----------
  void setLarge(bool v) {
    large = v;
    _p?.setBool('large', v);
    notifyListeners();
  }

  void setDark(bool v) {
    dark = v;
    _p?.setBool('dark', v);
    notifyListeners();
  }

  // ---------- unfinished test ----------
  void saveSession(TestSession s) {
    hasSession = true;
    _p?.setString('session', jsonEncode(s.toJson()));
  }

  void clearSession() {
    hasSession = false;
    _p?.remove('session');
    notifyListeners();
  }

  TestSession? loadSession() {
    try {
      final raw = _p?.getString('session');
      if (raw == null) return null;
      final byId = {for (final q in questions) q.id: q};
      return TestSession.fromJson(jsonDecode(raw) as Map<String, dynamic>, byId);
    } catch (_) {
      return null;
    }
  }
}
