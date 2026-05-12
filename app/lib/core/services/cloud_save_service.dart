/// Cloud save — scaffold dla Firebase Anonymous Auth + Firestore.
///
/// Strategia:
///   1. Anonymous Auth: użytkownik dostaje stabilny UID bez logowania.
///   2. Doc `users/{uid}` zawiera snapshot Hive profile + progress.
///   3. Synchronizacja przy app start (pull) i po istotnych zmianach (push).
///   4. Konflikt: timestamp ostatniej zmiany lokalnej vs zdalnej, większa wygrywa.
library;

import 'package:flutter/foundation.dart';

import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/progress_repository.dart';

class CloudSaveSnapshot {
  final int coins;
  final int totalStars;
  final int highestLevel;
  final Map<int, int> starsPerLevel;
  final DateTime updatedAt;

  const CloudSaveSnapshot({
    required this.coins,
    required this.totalStars,
    required this.highestLevel,
    required this.starsPerLevel,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'totalStars': totalStars,
        'highestLevel': highestLevel,
        'starsPerLevel':
            starsPerLevel.map((k, v) => MapEntry(k.toString(), v)),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class CloudSaveService {
  CloudSaveService({
    required this.profileRepo,
    required this.progressRepo,
  });

  final ProfileRepository profileRepo;
  final ProgressRepository progressRepo;

  /// Pobiera snapshot zdalny. Null gdy brak.
  /// TODO[BLOCKER B-CLOUD-SAVE]: implementacja Firestore:
  ///   final doc = await FirebaseFirestore.instance
  ///     .collection('users').doc(uid).get();
  Future<CloudSaveSnapshot?> pull(String userId) async {
    if (kDebugMode) debugPrint('[cloud-save] pull stub (uid=$userId)');
    return null;
  }

  /// Wysyła aktualny stan.
  Future<bool> push(String userId) async {
    if (kDebugMode) debugPrint('[cloud-save] push stub (uid=$userId)');
    return true;
  }

  /// Merge — przyjmuje większy z lokalnego/zdalnego per level.
  /// Zwraca true jeśli lokalny stan został zaktualizowany.
  Future<bool> mergeFromRemote(CloudSaveSnapshot remote) async {
    var changed = false;
    // Coins: weź większe
    if (remote.coins > profileRepo.current.coins) {
      await profileRepo.addCoins(remote.coins - profileRepo.current.coins);
      changed = true;
    }
    // Stars per level: weź większe
    for (final entry in remote.starsPerLevel.entries) {
      final local = progressRepo.getLevel(entry.key);
      if (local == null || local.stars < entry.value) {
        await progressRepo.recordResult(
          levelId: entry.key,
          stars: entry.value,
          score: 0, // remote nie ma score per level w MVP
          won: true,
        );
        changed = true;
      }
    }
    return changed;
  }
}
