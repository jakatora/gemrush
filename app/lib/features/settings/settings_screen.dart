import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../game/flame_components/gem_sprite.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(settingsRepoProvider);
    final s = repo.current;

    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader('Audio i wibracje'),
          SwitchListTile(
            value: s.soundEnabled,
            title: const Text('Dźwięki'),
            subtitle: const Text('Krótkie efekty (matche, swap, win)'),
            secondary: const Icon(Icons.volume_up, color: AppColors.accent),
            onChanged: (v) async {
              await repo.setSound(v);
              ref.read(audioProvider).soundEnabled = v;
              setState(() {});
            },
          ),
          SwitchListTile(
            value: s.musicEnabled,
            title: const Text('Muzyka'),
            subtitle: const Text('Tło muzyczne w grze'),
            secondary: const Icon(Icons.music_note, color: AppColors.accent),
            onChanged: (v) async {
              await repo.setMusic(v);
              ref.read(audioProvider).musicEnabled = v;
              if (!v) await ref.read(audioProvider).stopMusic();
              setState(() {});
            },
          ),
          SwitchListTile(
            value: s.hapticsEnabled,
            title: const Text('Wibracje'),
            subtitle: const Text('Haptic feedback przy interakcjach'),
            secondary: const Icon(Icons.vibration, color: AppColors.accent),
            onChanged: (v) async {
              await repo.setHaptics(v);
              ref.read(hapticsProvider).enabled = v;
              setState(() {});
            },
          ),
          const _SectionHeader('Dostępność'),
          SwitchListTile(
            value: s.colorBlindMode,
            title: const Text('Tryb daltonistyczny'),
            subtitle: const Text(
                'Wyraźniejsze kształty na klejnotach (a11y)'),
            secondary:
                const Icon(Icons.accessibility, color: AppColors.accent),
            onChanged: (v) async {
              await repo.setColorBlindMode(v);
              GemSprite.colorBlindMode = v;
              setState(() {});
            },
          ),
          const _SectionHeader('Konto i zakupy'),
          ListTile(
            leading: const Icon(Icons.restore, color: AppColors.accent),
            title: const Text('Przywróć zakupy'),
            subtitle: const Text('Odtwórz zakup remove_ads / IAP'),
            onTap: () async {
              await ref.read(iapServiceProvider).restorePurchases();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Próba przywrócenia zakupów wysłana.')),
                );
              }
            },
          ),
          const _SectionHeader('Prywatność'),
          ListTile(
            leading:
                const Icon(Icons.privacy_tip, color: AppColors.accent),
            title: const Text('Opcje prywatności'),
            subtitle:
                const Text('Zarządzaj zgodą RODO / spersonalizowanymi reklamami'),
            onTap: () async {
              await ref.read(consentProvider).showPrivacyOptions();
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: AppColors.accent),
            title: const Text('Polityka prywatności'),
            subtitle: const Text('Otwórz pełną politykę'),
            onTap: () async {
              // TODO[BLOCKER B-PRIV-URL]: wstaw realny URL po hostowaniu.
              final uri = Uri.parse('https://example.com/privacy');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              }
            },
          ),
          const _SectionHeader('O aplikacji'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.accent),
            title: Text('Wersja'),
            subtitle: Text('1.0.0 (1)'),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.accent),
            title: const Text('Kontakt'),
            subtitle: const Text('jakatora68@gmail.com'),
            onTap: () async {
              final uri = Uri.parse('mailto:jakatora68@gmail.com?subject=GemRush');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
