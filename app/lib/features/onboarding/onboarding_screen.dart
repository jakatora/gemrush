import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/routes.dart';
import '../../core/i18n/app_locale.dart';

/// Onboarding pokazywany raz przy pierwszym uruchomieniu.
/// Flag pamiętany w SharedPreferences-like Hive boxie 'meta'.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const _flagKey = 'onboarding_seen';

  static Future<bool> wasSeen() async {
    final box = await Hive.openBox<bool>('meta');
    return box.get(_flagKey, defaultValue: false) ?? false;
  }

  static Future<void> markSeen() async {
    final box = await Hive.openBox<bool>('meta');
    await box.put(_flagKey, true);
  }

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.titleEn,
    required this.titlePl,
    required this.bodyEn,
    required this.bodyPl,
    required this.color,
  });

  final IconData icon;
  final String titleEn;
  final String titlePl;
  final String bodyEn;
  final String bodyPl;
  final Color color;
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _slides = <_OnboardingSlide>[
    _OnboardingSlide(
      icon: Icons.swap_horiz,
      titleEn: 'Match 3 or more gems',
      titlePl: 'Łącz 3 lub więcej klejnotów',
      bodyEn:
          'Drag two adjacent gems to swap them and create a match.',
      bodyPl:
          'Przeciągnij dwa sąsiednie klejnoty, żeby zamienić je miejscami i utworzyć match.',
      color: Color(0xFF49D88B),
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome,
      titleEn: 'Create special gems',
      titlePl: 'Twórz specjalne klejnoty',
      bodyEn:
          'Match 4, 5 or L-shaped gems to spawn striped, wrapped or a color bomb.',
      bodyPl:
          'Łącz 4, 5 lub klejnoty w kształcie L, żeby otrzymać striped, wrapped lub color bomb.',
      color: Color(0xFFFFB627),
    ),
    _OnboardingSlide(
      icon: Icons.flag,
      titleEn: 'Beat every level goal',
      titlePl: 'Ukończ cele każdego poziomu',
      bodyEn:
          'Clear jelly, collect ingredients or just hit the target score. 300 levels await!',
      bodyPl:
          'Wyczyść galaretkę, zbierz orzeszki lub po prostu zdobądź wymarzony wynik. 300 poziomów czeka!',
      color: Color(0xFFFF4757),
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    await OnboardingScreen.markSeen();
    if (mounted) context.go(Routes.menu);
  }

  String _title(BuildContext context, _OnboardingSlide s) =>
      LocaleScope.of(context) == AppLocale.pl ? s.titlePl : s.titleEn;
  String _body(BuildContext context, _OnboardingSlide s) =>
      LocaleScope.of(context) == AppLocale.pl ? s.bodyPl : s.bodyEn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _done,
                child: Text(
                  context.tr(en: 'Skip', pl: 'Pomiń'),
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final p = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.color.withValues(alpha: 0.25),
                            border: Border.all(color: p.color, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: p.color.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(p.icon, size: 70, color: p.color),
                        ),
                        const SizedBox(height: 32),
                        Text(_title(context, p),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            )),
                        const SizedBox(height: 16),
                        Text(_body(context, p),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.muted,
                              height: 1.5,
                            )),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: active ? AppColors.accent : AppColors.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_page < _slides.length - 1) {
                      _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _done();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Text(_page < _slides.length - 1
                      ? context.tr(en: 'Next', pl: 'Dalej')
                      : context.tr(en: "Let's go!", pl: 'Zaczynamy!')),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
