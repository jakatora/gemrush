import 'package:flutter/foundation.dart';

/// ConsentService — STUB. UMP SDK (google_mobile_ads) tymczasowo wyłączony.
///
/// Po podłożeniu z powrotem `google_mobile_ads` przywróć właściwą
/// implementację UMP. Aktualnie wszystkie metody są no-op żeby app
/// startował bez Google Play Services.
class ConsentService {
  bool consentResolved = false;

  Future<bool> requestConsent() async {
    if (kDebugMode) debugPrint('[consent] STUB — UMP disabled');
    consentResolved = true;
    return true;
  }

  Future<void> requestATTIfNeeded() async {}

  Future<void> showPrivacyOptions() async {
    if (kDebugMode) debugPrint('[consent] showPrivacyOptions STUB');
  }
}
