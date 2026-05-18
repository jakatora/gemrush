import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/routes.dart';

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

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _pages = [
    (
      icon: Icons.swap_horiz,
      title: 'Łącz 3 lub więcej klejnotów',
      body: 'Przeciągnij dwa sąsiednie klejnoty, żeby zamienić je miejscami i utworzyć match.',
      color: Color(0xFF49D88B),
    ),
    (
      icon: Icons.auto_awesome,
      title: 'Twórz specjalne klejnoty',
      body: 'Łącz 4, 5 lub klejnoty w kształcie L, żeby otrzymać striped, wrapped lub color bomb.',
      color: Color(0xFFFFB627),
    ),
    (
      icon: Icons.flag,
      title: 'Ukończ cele każdego poziomu',
      body: 'Wyczyść galaretkę, zbierz orzeszki lub po prostu zdobądź wymarzony wynik. 300 poziomów czeka!',
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
                child: const Text('Pomiń',
                    style: TextStyle(color: AppColors.muted)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
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
                        Text(p.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            )),
                        const SizedBox(height: 16),
                        Text(p.body,
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
              children: List.generate(_pages.length, (i) {
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
                    if (_page < _pages.length - 1) {
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
                  child:
                      Text(_page < _pages.length - 1 ? 'Dalej' : 'Zaczynamy!'),
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
