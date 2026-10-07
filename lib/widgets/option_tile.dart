import 'package:flutter/material.dart';

enum OptState { none, selected, correct, wrong }

// One answer card (A, B, C or D). Uses words as well as color.
class OptionTile extends StatelessWidget {
  final String letter, text;
  final OptState state;
  final String label;
  final VoidCallback? onTap;
  const OptionTile({super.key, required this.letter, required this.text, this.state = OptState.none, this.label = '', this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color border = cs.outline;
    Color? bg;
    var w = 1.0;
    if (state == OptState.selected) { border = cs.primary; w = 3; }
    if (state == OptState.correct) { border = Colors.green.shade700; bg = Colors.green.shade700.withAlpha(50); w = 3; }
    if (state == OptState.wrong) { border = Colors.red.shade700; bg = Colors.red.shade700.withAlpha(50); w = 3; }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg ?? cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: border, width: w)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(letter, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(text, style: const TextStyle(fontSize: 17)),
                  if (label.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
