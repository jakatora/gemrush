import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_locale.dart';

/// Tutorial pojawiający się raz, przy pierwszej rozgrywce.
/// Trzy kroki, dismissable.
class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialStep {
  const _TutorialStep({
    required this.icon,
    required this.titleEn,
    required this.titlePl,
    required this.bodyEn,
    required this.bodyPl,
  });

  final IconData icon;
  final String titleEn;
  final String titlePl;
  final String bodyEn;
  final String bodyPl;
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _step = 0;

  static const _steps = <_TutorialStep>[
    _TutorialStep(
      icon: Icons.swap_horiz,
      titleEn: 'Drag two gems',
      titlePl: 'Przeciągnij dwa klejnoty',
      bodyEn: 'Match 3+ of the same color to clear them.',
      bodyPl: 'Łączcie 3+ tego samego koloru, by je rozbić.',
    ),
    _TutorialStep(
      icon: Icons.auto_awesome,
      titleEn: 'Match 4 or 5',
      titlePl: 'Łącz 4 lub 5',
      bodyEn:
          '4 in a line — striped (clears a row). 5 in a line — color bomb.',
      bodyPl: '4 w linii — striped (czyści rząd). 5 w linii — color bomb.',
    ),
    _TutorialStep(
      icon: Icons.flag,
      titleEn: 'Beat the goal',
      titlePl: 'Wykonaj cel poziomu',
      bodyEn: 'Goals show at the top. Watch the move counter!',
      bodyPl: 'Cele widzisz na górze. Uważaj na licznik ruchów!',
    ),
  ];

  String _title(BuildContext context, _TutorialStep s) =>
      LocaleScope.of(context) == AppLocale.pl ? s.titlePl : s.titleEn;
  String _body(BuildContext context, _TutorialStep s) =>
      LocaleScope.of(context) == AppLocale.pl ? s.bodyPl : s.bodyEn;

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
                Text(_title(context, step),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    )),
                const SizedBox(height: 12),
                Text(_body(context, step),
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
                  child: Text(_step < _steps.length - 1
                      ? context.tr(en: 'Next', pl: 'Dalej')
                      : context.tr(en: 'Play!', pl: 'Graj!')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
