import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
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
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: s.soundEnabled,
            title: const Text('Dźwięki'),
            onChanged: (v) async {
              await repo.setSound(v);
              ref.read(audioProvider).soundEnabled = v;
              setState(() {});
            },
          ),
          SwitchListTile(
            value: s.musicEnabled,
            title: const Text('Muzyka'),
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
            onChanged: (v) async {
              await repo.setHaptics(v);
              ref.read(hapticsProvider).enabled = v;
              setState(() {});
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore, color: AppColors.accent),
            title: const Text('Przywróć zakupy'),
            onTap: () async {
              await ref.read(iapServiceProvider).restorePurchases();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próba przywrócenia zakupów wysłana.')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppColors.accent),
            title: const Text('Opcje prywatności'),
            subtitle: const Text('Zarządzaj zgodą RODO i reklamami spersonalizowanymi'),
            onTap: () async {
              await ref.read(consentProvider).showPrivacyOptions();
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Wersja'),
            subtitle: Text('0.1.0 (1)'),
          ),
        ],
      ),
    );
  }
}
