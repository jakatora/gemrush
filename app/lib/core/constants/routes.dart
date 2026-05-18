class Routes {
  Routes._();

  static const splash = '/';
  static const menu = '/menu';
  static const map = '/map';
  static const game = '/game';
  static const shop = '/shop';
  static const settings = '/settings';
  static const achievements = '/achievements';
  static const stats = '/stats';

  static String gameWithLevel(int levelId) => '/game/$levelId';
}
