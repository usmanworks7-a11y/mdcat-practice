import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config.dart';
import '../models/question.dart';

class DataService {
  static Future<File> _savedFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/mcqs.json');
  }

  // The working copy saved on the phone. Empty list if missing or broken.
  static Future<List<Question>> loadSaved() async {
    try {
      final f = await _savedFile();
      if (!await f.exists()) return [];
      return await compute(parseQuestions, await f.readAsString());
    } catch (_) {
      return [];
    }
  }

  // The starter file inside the app.
  static Future<List<Question>> loadBundled() async {
    try {
      return await compute(parseQuestions, await rootBundle.loadString('assets/mcqs.json'));
    } catch (_) {
      return [];
    }
  }

  static Future<int> bundledVersion() async {
    try {
      final m = jsonDecode(await rootBundle.loadString('assets/version.json'));
      return (m['version'] as num).toInt();
    } catch (_) {
      return 0;
    }
  }

  // Downloads only the tiny version.json. Returns null if anything goes wrong.
  static Future<Map<String, dynamic>?> fetchVersion() async {
    try {
      final r = await http.get(Uri.parse('${baseUrl}version.json')).timeout(const Duration(seconds: 6));
      if (r.statusCode != 200) return null;
      final m = jsonDecode(utf8.decode(r.bodyBytes));
      if (m is Map<String, dynamic> && m['version'] is num) return m;
      return null;
    } catch (_) {
      return null;
    }
  }

  // Safe download: check the data first, write a temp file, then replace the old file.
  static Future<List<Question>> download(Map<String, dynamic> info) async {
    final name = (info['file'] ?? 'mcqs.json').toString();
    final r = await http.get(Uri.parse('$baseUrl$name')).timeout(const Duration(seconds: 90));
    if (r.statusCode != 200) throw Exception('bad status');
    final text = utf8.decode(r.bodyBytes);
    final qs = await compute(parseQuestions, text);
    if (qs.isEmpty) throw Exception('empty or broken file');
    final f = await _savedFile();
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(text, flush: true);
    await tmp.rename(f.path);
    return qs;
  }
}
