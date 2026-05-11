import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Obsługa zgody RODO (UMP SDK) + iOS App Tracking Transparency.
/// Wywoływana raz przy starcie aplikacji, PRZED `MobileAds.initialize()`.
class ConsentService {
  bool consentResolved = false;

  /// Zwraca true gdy można inicjalizować ads (consent OK lub poza UE).
  Future<bool> requestConsent() async {
    try {
      final params = ConsentRequestParameters();
      await _requestUpdate(params);

      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        await _loadAndShowForm();
      }
      consentResolved = true;
      return await ConsentInformation.instance.canRequestAds();
    } catch (e) {
      if (kDebugMode) debugPrint('[consent] error: $e');
      return true;
    }
  }

  /// iOS-only: pokaż App Tracking Transparency. Wywołaj po UMP, przed `MobileAds.initialize()`.
  Future<void> requestATTIfNeeded() async {
    if (!Platform.isIOS) return;
    // TODO[BLOCKER B-ATT]: dodać `app_tracking_transparency` do pubspec i wywołać tu:
    //   final status = await AppTrackingTransparency.requestTrackingAuthorization();
  }

  Future<void> _requestUpdate(ConsentRequestParameters params) {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () => completer.complete(),
      (err) {
        if (kDebugMode) debugPrint('[consent] update error: $err');
        completer.complete();
      },
    );
    return completer.future;
  }

  Future<void> _loadAndShowForm() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((err) {
      if (err != null && kDebugMode) {
        debugPrint('[consent] form error: $err');
      }
      completer.complete();
    });
    return completer.future;
  }

  /// Otwiera ekran "Privacy options" (wymagany w Settings).
  Future<void> showPrivacyOptions() async {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((err) {
      if (err != null && kDebugMode) debugPrint('[consent] privacy: $err');
      completer.complete();
    });
    return completer.future;
  }
}
