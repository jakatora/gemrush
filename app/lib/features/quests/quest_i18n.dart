import 'package:flutter/widgets.dart';

import '../../core/i18n/app_locale.dart';
import '../../data/models/quest.dart';

class _Loc {
  const _Loc(this.title, this.desc);
  final String title;
  final String desc;
}

const _enQuestById = <String, _Loc>{
  'win_3': _Loc('Win 3 levels', ''),
  'win_5': _Loc('Win 5 levels', ''),
  'cascade_3': _Loc('Trigger a 3× cascade', 'In one game'),
  'special_5': _Loc('Create 5 special gems', 'During the day'),
  'coins_100': _Loc('Earn 100 coins', 'From levels'),
  'booster_use': _Loc('Use 2 boosters', ''),
  'score_50k': _Loc('Score 50,000 points', 'In a single level'),
  'star_5': _Loc('Earn 5 stars', ''),
  'combo_4': _Loc('Trigger a 4× cascade', ''),
  'hint_use': _Loc('Use 1 hint', ''),
  'shuffle_1': _Loc('Use 1 shuffle', ''),
  'win_no_boost': _Loc('Win 2 levels without boosters', ''),
};

String questTitleFor(BuildContext context, Quest q) {
  if (LocaleScope.of(context) == AppLocale.pl) return q.title;
  return _enQuestById[q.id]?.title ?? q.title;
}

String questDescriptionFor(BuildContext context, Quest q) {
  if (LocaleScope.of(context) == AppLocale.pl) return q.description;
  return _enQuestById[q.id]?.desc ?? q.description;
}
