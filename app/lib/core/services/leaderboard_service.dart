/// Leaderboard — scaffold pod Firestore.
///
/// Aktualnie operuje lokalnie (Hive). Po założeniu Firebase i włączeniu Firestore,
/// podmień implementację `_remoteFetch` i `_remoteSubmit` na realne wywołania.
library;

import 'package:flutter/foundation.dart';

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int totalStars;
  final int highestLevel;
  final int totalScore;
  final DateTime updatedAt;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.totalStars,
    required this.highestLevel,
    required this.totalScore,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'totalStars': totalStars,
        'highestLevel': highestLevel,
        'totalScore': totalScore,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) =>
      LeaderboardEntry(
        userId: j['userId'] as String,
        displayName: j['displayName'] as String,
        totalStars: (j['totalStars'] as num).toInt(),
        highestLevel: (j['highestLevel'] as num).toInt(),
        totalScore: (j['totalScore'] as num).toInt(),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );
}

class LeaderboardService {
  /// Top-N globalnie.
  /// TODO[BLOCKER B-LEADERBOARD]: implementacja Firestore:
  ///   FirebaseFirestore.instance.collection('leaderboard')
  ///     .orderBy('totalStars', descending: true).limit(limit).get()
  Future<List<LeaderboardEntry>> fetchTop({int limit = 100}) async {
    if (kDebugMode) {
      debugPrint('[leaderboard] fetchTop stub (Firestore not configured)');
    }
    return const [];
  }

  /// Wysyła stan gracza. Idempotentne — overrides poprzedni wpis tego usera.
  Future<bool> submitOwn(LeaderboardEntry entry) async {
    if (kDebugMode) debugPrint('[leaderboard] submit stub: ${entry.toJson()}');
    return true;
  }

  /// Pozycja użytkownika w globalnym ranking.
  Future<int?> myRank(String userId) async => null;
}
