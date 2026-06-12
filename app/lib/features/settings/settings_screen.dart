import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_locale.dart';
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
    final currentLocale = LocaleScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(en: 'Settings', pl: 'Ustawienia')),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(context.tr(en: 'Language', pl: 'Język')),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.accent),
            title: Text(context.tr(en: 'Language', pl: 'Język')),
            subtitle: Text(
              currentLocale == AppLocale.en ? 'English' : 'Polski',
            ),
            trailing: SegmentedButton<AppLocale>(
              segments: const [
                ButtonSegment(value: AppLocale.en, label: Text('EN')),
                ButtonSegment(value: AppLocale.pl, label: Text('PL')),
              ],
              selected: {currentLocale},
              onSelectionChanged: (set) async {
                final next = set.first;
                final notifier = LocaleScope.notifierOf(context);
                await repo.setLanguage(next.code);
                notifier.locale = next;
                if (mounted) setState(() {});
              },
              showSelectedIcon: false,
            ),
          ),
          _SectionHeader(
            context.tr(en: 'Audio and haptics', pl: 'Audio i wibracje'),
          ),
          SwitchListTile(
            value: s.soundEnabled,
            title: Text(context.tr(en: 'Sound', pl: 'Dźwięki')),
            subtitle: Text(context.tr(
              en: 'Short effects (matches, swap, win)',
              pl: 'Krótkie efekty (matche, swap, win)',
            )),
            secondary: const Icon(Icons.volume_up, color: AppColors.accent),
            onChanged: (v) async {
              await repo.setSound(v);
              ref.read(audioProvider).soundEnabled = v;
              setState(() {});
            },
          ),
          SwitchListTile(
            value: s.musicEnabled,
            title: Text(context.tr(en: 'Music', pl: 'Muzyka')),
            subtitle: Text(context.tr(
              en: 'In-game background music',
              pl: 'Tło muzyczne w grze',
            )),
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
            title: Text(context.tr(en: 'Haptics', pl: 'Wibracje')),
            subtitle: Text(context.tr(
              en: 'Haptic feedback on interactions',
              pl: 'Haptic feedback przy interakcjach',
            )),
            secondary: const Icon(Icons.vibration, color: AppColors.accent),
            onChanged: (v) async {
              await repo.setHaptics(v);
              ref.read(hapticsProvider).enabled = v;
              setState(() {});
            },
          ),
          _SectionHeader(
            context.tr(en: 'Accessibility', pl: 'Dostępność'),
          ),
          SwitchListTile(
            value: s.colorBlindMode,
            title: Text(
              context.tr(en: 'Color-blind mode', pl: 'Tryb daltonistyczny'),
            ),
            subtitle: Text(context.tr(
              en: 'Distinct shapes on gems (a11y)',
              pl: 'Wyraźniejsze kształty na klejnotach (a11y)',
            )),
            secondary:
                const Icon(Icons.accessibility, color: AppColors.accent),
            onChanged: (v) async {
              await repo.setColorBlindMode(v);
              GemSprite.colorBlindMode = v;
              setState(() {});
            },
          ),
          _SectionHeader(
            context.tr(en: 'Account and purchases', pl: 'Konto i zakupy'),
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: AppColors.accent),
            title: Text(
              context.tr(en: 'Restore purchases', pl: 'Przywróć zakupy'),
            ),
            subtitle: Text(context.tr(
              en: 'Restore remove_ads / IAP',
              pl: 'Odtwórz zakup remove_ads / IAP',
            )),
            onTap: () async {
              await ref.read(iapServiceProvider).restorePurchases();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr(
                      en: 'Restore request sent.',
                      pl: 'Próba przywrócenia zakupów wysłana.',
                    )),
                  ),
                );
              }
            },
          ),
          _SectionHeader(context.tr(en: 'Privacy', pl: 'Prywatność')),
          ListTile(
            leading:
                const Icon(Icons.privacy_tip, color: AppColors.accent),
            title: Text(
              context.tr(en: 'Privacy options', pl: 'Opcje prywatności'),
            ),
            subtitle: Text(context.tr(
              en: 'Manage GDPR consent / personalized ads',
              pl: 'Zarządzaj zgodą RODO / spersonalizowanymi reklamami',
            )),
            onTap: () async {
              await ref.read(consentProvider).showPrivacyOptions();
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: AppColors.accent),
            title: Text(
              context.tr(en: 'Privacy policy', pl: 'Polityka prywatności'),
            ),
            subtitle: Text(context.tr(
              en: 'Open full policy',
              pl: 'Otwórz pełną politykę',
            )),
            onTap: () async {
              final uri = Uri.parse('https://jakatora.github.io/gemrush/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              }
            },
          ),
          _SectionHeader(context.tr(en: 'About', pl: 'O aplikacji')),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.accent),
            title: Text(context.tr(en: 'Version', pl: 'Wersja')),
            subtitle: const Text('1.0.1 (5)'),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.accent),
            title: Text(context.tr(en: 'Contact', pl: 'Kontakt')),
            subtitle: const Text('jakatora68@gmail.com'),
            onTap: () async {
              final uri = Uri.parse(
                  'mailto:jakatora68@gmail.com?subject=Gem Rush Saga');
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
