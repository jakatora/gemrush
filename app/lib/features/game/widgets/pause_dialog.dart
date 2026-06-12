import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../providers/app_providers.dart';

class PauseDialog extends ConsumerStatefulWidget {
  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  ConsumerState<PauseDialog> createState() => _PauseDialogState();
}

class _PauseDialogState extends ConsumerState<PauseDialog> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.read(settingsRepoProvider).current;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle, size: 56, color: AppColors.accent),
            const SizedBox(height: 12),
            Text(context.tr(en: 'Paused', pl: 'Pauza'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                )),
            const SizedBox(height: 20),
            _Toggle(
              icon: Icons.volume_up,
              label: context.tr(en: 'Sound', pl: 'Dźwięki'),
              value: settings.soundEnabled,
              onChanged: (v) async {
                await ref.read(settingsRepoProvider).setSound(v);
                ref.read(audioProvider).soundEnabled = v;
                setState(() {});
              },
            ),
            _Toggle(
              icon: Icons.music_note,
              label: context.tr(en: 'Music', pl: 'Muzyka'),
              value: settings.musicEnabled,
              onChanged: (v) async {
                await ref.read(settingsRepoProvider).setMusic(v);
                ref.read(audioProvider).musicEnabled = v;
                if (!v) await ref.read(audioProvider).stopMusic();
                setState(() {});
              },
            ),
            _Toggle(
              icon: Icons.vibration,
              label: context.tr(en: 'Haptics', pl: 'Wibracje'),
              value: settings.hapticsEnabled,
              onChanged: (v) async {
                await ref.read(settingsRepoProvider).setHaptics(v);
                ref.read(hapticsProvider).enabled = v;
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onResume();
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(context.tr(en: 'Resume', pl: 'Wznów')),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onRestart();
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                  context.tr(en: 'Restart level', pl: 'Restartuj poziom')),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onQuit();
              },
              icon: const Icon(Icons.exit_to_app, color: AppColors.muted),
              label: Text(
                  context.tr(en: 'Exit to map', pl: 'Wyjdź do mapy'),
                  style: const TextStyle(color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.onSurface,
              )),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.accent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
