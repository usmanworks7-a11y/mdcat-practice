import 'package:flutter/material.dart';
import '../strings.dart';

// Big tap button (height 56).
class BigButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool filled;
  const BigButton(this.text, {super.key, this.onTap, this.filled = true});

  @override
  Widget build(BuildContext context) {
    final child = Text(text, textAlign: TextAlign.center);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: filled
            ? FilledButton(onPressed: onTap, child: child)
            : OutlinedButton(onPressed: onTap, child: child),
      ),
    );
  }
}

// Row of choices. The student taps one.
class Picker<V> extends StatelessWidget {
  final List<V> items;
  final V? value;
  final String Function(V) label;
  final ValueChanged<V> onChanged;
  const Picker({super.key, required this.items, required this.value, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((i) => ChoiceChip(
                label: Text(label(i), style: const TextStyle(fontSize: 16)),
                selected: i == value,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                onSelected: (_) => onChanged(i),
              ))
          .toList(),
    );
  }
}

Widget heading(String t) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    );

Future<bool> confirmDialog(BuildContext c, String title, String body, String yes, String no) async {
  final r = await showDialog<bool>(
    context: c,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(body, style: const TextStyle(fontSize: 16)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(no)),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(yes)),
      ],
    ),
  );
  return r ?? false;
}

void openScreen(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

Widget infoText(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(t, style: const TextStyle(fontSize: 16)),
    );

String yesNoSave(bool saved) => saved ? T.saved : T.save;
