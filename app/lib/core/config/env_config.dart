import 'dart:io' show Platform;

class EnvConfig {
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static const _admobAppIdAndroid = String.fromEnvironment(
    'ADMOB_APP_ID_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713',
  );
  static const _admobAppIdIos = String.fromEnvironment(
    'ADMOB_APP_ID_IOS',
    defaultValue: 'ca-app-pub-3940256099942544~1458002511',
  );

  static const _interstitialAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );
  static const _interstitialIos = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910',
  );

  static const _rewardedAndroid = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
  static const _rewardedIos = String.fromEnvironment(
    'ADMOB_REWARDED_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/1712485313',
  );

  static const _bannerAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );
  static const _bannerIos = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );

  static String get admobAppId =>
      Platform.isAndroid ? _admobAppIdAndroid : _admobAppIdIos;
  static String get interstitialId =>
      Platform.isAndroid ? _interstitialAndroid : _interstitialIos;
  static String get rewardedId =>
      Platform.isAndroid ? _rewardedAndroid : _rewardedIos;
  static String get bannerId =>
      Platform.isAndroid ? _bannerAndroid : _bannerIos;

  static bool get isProd => flavor == 'prod';
  static bool get isDev => flavor == 'dev';

  static bool get usingTestAdIds => admobAppId.contains('3940256099942544');
}
