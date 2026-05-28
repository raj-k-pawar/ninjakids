import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

/// Handles all analytics: quiz sessions, screen time, subject performance.
class AnalyticsService {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  final _uuid = const Uuid();

  AnalyticsService({
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  // ─── Save completed quiz session ──────────────────────────────────────────

  Future<void> saveQuizSession({
    required String kidId,
    required String subject,
    required String className,
    required int score,
    required int total,
    required int xpEarned,
    required int coinsEarned,
    required Duration timeTaken,
    required List<String> questionIds,
    required List<String> answers,
  }) async {
    final sessionId = _uuid.v4();
    final now = DateTime.now();

    // Save to Firestore
    await _firestore.collection(AppConstants.colQuizHistory).doc(sessionId).set({
      'id': sessionId,
      'kidId': kidId,
      'subject': subject,
      'className': className,
      'score': score,
      'total': total,
      'accuracy': total > 0 ? (score / total * 100).round() : 0,
      'xpEarned': xpEarned,
      'coinsEarned': coinsEarned,
      'timeTakenSeconds': timeTaken.inSeconds,
      'questionIds': questionIds,
      'answers': answers,
      'completedAt': FieldValue.serverTimestamp(),
      'date': _dateKey(now),
    });

    // Update kid's overall stats atomically
    await _firestore.collection(AppConstants.colKids).doc(kidId).update({
      'totalXp': FieldValue.increment(xpEarned),
      'coins': FieldValue.increment(coinsEarned),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });

    // Update level if needed
    await _recalculateLevel(kidId);

    // Log to Firebase Analytics
    await _analytics.logEvent(
      name: 'quiz_completed',
      parameters: {
        'subject': subject,
        'score': score,
        'total': total,
        'accuracy': total > 0 ? (score / total * 100).round() : 0,
        'xp_earned': xpEarned,
      },
    );
  }

  // ─── Screen time tracking ─────────────────────────────────────────────────

  Future<void> addScreenTime({
    required String kidId,
    required int minutes,
    required String section, // 'quiz' | 'games' | 'speaking' | 'home'
  }) async {
    final today = _dateKey(DateTime.now());

    // Update kid's today counter
    await _firestore.collection(AppConstants.colKids).doc(kidId).update({
      'todayScreenTimeMinutes': FieldValue.increment(minutes),
    });

    // Log to screen_time_logs
    final logRef = _firestore
        .collection(AppConstants.colScreenTimeLogs)
        .doc('${kidId}_$today');

    await logRef.set({
      'kidId': kidId,
      'date': today,
      'totalMinutes': FieldValue.increment(minutes),
      'breakdown.$section': FieldValue.increment(minutes),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> resetDailyScreenTime(String kidId) async {
    await _firestore.collection(AppConstants.colKids).doc(kidId).update({
      'todayScreenTimeMinutes': 0,
    });
  }

  // ─── Fetch weekly activity ────────────────────────────────────────────────

  Future<List<int>> getWeeklyActivity(String kidId) async {
    final now = DateTime.now();
    final results = <int>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      try {
        final doc = await _firestore
            .collection(AppConstants.colScreenTimeLogs)
            .doc('${kidId}_$key')
            .get();
        results.add(doc.exists ? (doc.data()?['totalMinutes'] ?? 0) as int : 0);
      } catch (_) {
        results.add(0);
      }
    }
    return results;
  }

  // ─── Fetch subject performance ────────────────────────────────────────────

  Future<Map<String, double>> getSubjectPerformance(
    String kidId, {
    int lastDays = 30,
  }) async {
    final since = DateTime.now().subtract(Duration(days: lastDays));

    final snapshot = await _firestore
        .collection(AppConstants.colQuizHistory)
        .where('kidId', isEqualTo: kidId)
        .where('completedAt', isGreaterThan: Timestamp.fromDate(since))
        .get();

    final subjectData = <String, List<int>>{}; // subject -> [scores]

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final subject = data['subject'] as String? ?? 'Unknown';
      final score = data['score'] as int? ?? 0;
      final total = data['total'] as int? ?? 1;
      subjectData.putIfAbsent(subject, () => []).add(
            (score / total * 100).round(),
          );
    }

    return subjectData.map(
      (subject, scores) => MapEntry(
        subject,
        scores.reduce((a, b) => a + b) / scores.length,
      ),
    );
  }

  // ─── Fetch quiz history ───────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> quizHistoryStream(String kidId) {
    return _firestore
        .collection(AppConstants.colQuizHistory)
        .where('kidId', isEqualTo: kidId)
        .orderBy('completedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ─── Streak management ────────────────────────────────────────────────────

  Future<void> updateStreak(String kidId) async {
    final kidDoc = await _firestore
        .collection(AppConstants.colKids)
        .doc(kidId)
        .get();

    if (!kidDoc.exists) return;
    final data = kidDoc.data()!;

    final lastActive = (data['lastActiveAt'] as Timestamp?)?.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastActive == null) {
      await kidDoc.reference.update({
        'currentStreak': 1,
        'longestStreak': 1,
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final lastActiveDay = DateTime(
      lastActive.year,
      lastActive.month,
      lastActive.day,
    );
    final diff = today.difference(lastActiveDay).inDays;

    int currentStreak = data['currentStreak'] ?? 0;
    int longestStreak = data['longestStreak'] ?? 0;

    if (diff == 0) {
      // Same day — no change to streak
    } else if (diff == 1) {
      // Consecutive day
      currentStreak++;
      if (currentStreak > longestStreak) longestStreak = currentStreak;
    } else {
      // Streak broken
      currentStreak = 1;
    }

    await kidDoc.reference.update({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Achievement checking ─────────────────────────────────────────────────

  Future<List<String>> checkAndUnlockAchievements(String kidId) async {
    final kidDoc = await _firestore
        .collection(AppConstants.colKids)
        .doc(kidId)
        .get();

    if (!kidDoc.exists) return [];
    final data = kidDoc.data()!;

    final currentStreak = data['currentStreak'] ?? 0;
    final totalXp = data['totalXp'] ?? 0;
    final _ = data['level'] ?? 1; // reserved for future level-based achievements

    final unlocked = <String>[];

    // Streak achievements
    final streakMilestones = {
      'streak_3': 3,
      'streak_7': 7,
      'streak_14': 14,
      'streak_30': 30,
    };

    for (final entry in streakMilestones.entries) {
      if (currentStreak >= entry.value) {
        final wasUnlocked = await _unlockAchievement(kidId, entry.key);
        if (wasUnlocked) unlocked.add(entry.key);
      }
    }

    // XP achievements
    final xpMilestones = {
      'xp_500': 500,
      'xp_1000': 1000,
      'xp_5000': 5000,
    };
    for (final entry in xpMilestones.entries) {
      if (totalXp >= entry.value) {
        final wasUnlocked = await _unlockAchievement(kidId, entry.key);
        if (wasUnlocked) unlocked.add(entry.key);
      }
    }

    return unlocked;
  }

  Future<bool> _unlockAchievement(String kidId, String achievementId) async {
    final ref = _firestore
        .collection(AppConstants.colAchievements)
        .doc('${kidId}_$achievementId');

    final doc = await ref.get();
    if (doc.exists && (doc.data()?['isUnlocked'] == true)) return false;

    await ref.set({
      'kidId': kidId,
      'achievementId': achievementId,
      'isUnlocked': true,
      'unlockedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return true;
  }

  // ─── Level recalculation ──────────────────────────────────────────────────

  Future<void> _recalculateLevel(String kidId) async {
    final doc = await _firestore
        .collection(AppConstants.colKids)
        .doc(kidId)
        .get();
    if (!doc.exists) return;

    final xp = doc.data()?['totalXp'] ?? 0;
    final newLevel = (xp / 500).floor() + 1; // recalculated level

    await doc.reference.update({'level': newLevel});
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(),
);
