import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Tutorial pojawiający się raz, przy pierwszej rozgrywce.
/// Trzy kroki, dismissable.
class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _step = 0;

  static const _steps = [
    (
      icon: Icons.swap_horiz,
      title: 'Przeciągnij dwa klejnoty',
      body: 'Łączcie 3+ tego samego koloru, by je rozbić.',
    ),
    (
      icon: Icons.auto_awesome,
      title: 'Łącz 4 lub 5',
      body: '4 w linii — striped (czyści rząd). 5 w linii — color bomb.',
    ),
    (
      icon: Icons.flag,
      title: 'Wykonaj cel poziomu',
      body: 'Cele widzisz na górze. Uważaj na licznik ruchów!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return Stack(
      children: [
        ColoredBox(
          color: Colors.black.withValues(alpha: 0.75),
          child: const SizedBox.expand(),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 36),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(step.icon, size: 64, color: AppColors.accent),
                const SizedBox(height: 16),
                Text(step.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    )),
                const SizedBox(height: 12),
                Text(step.body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    final active = i == _step;
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? AppColors.accent : AppColors.muted,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_step < _steps.length - 1) {
                      setState(() => _step += 1);
                    } else {
                      widget.onDone();
                    }
                  },
                  child: Text(_step < _steps.length - 1 ? 'Dalej' : 'Graj!'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
