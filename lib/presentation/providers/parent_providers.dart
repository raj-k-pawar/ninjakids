import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../services/auth/auth_service.dart';

// ─── Parent Providers ─────────────────────────────────────────────────────────

final currentParentIdProvider = StateProvider<String?>((ref) => null);

final currentParentProvider = FutureProvider<ParentEntity>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final uid = authService.currentUser?.uid;
  if (uid == null) throw Exception('Not authenticated');
  final parent = await authService.getParent(uid);
  if (parent == null) throw Exception('Parent profile not found');
  return parent;
});

final parentKidsProvider = FutureProvider<List<KidEntity>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final uid = authService.currentUser?.uid;
  if (uid == null) return [];
  return authService.getKidsForParent(uid);
});

// ─── Kid Providers ────────────────────────────────────────────────────────────

final currentKidIdProvider = StateProvider<String?>((ref) => null);

final currentKidProvider = FutureProvider<KidEntity>((ref) async {
  // TODO: load from secure storage / auth flow
  throw UnimplementedError('Set currentKidId first');
});

// ─── Gamification Notifier ────────────────────────────────────────────────────

class GamificationState {
  final int xp;
  final int coins;
  final int level;
  final int streak;
  final List<String> newlyUnlockedBadges;

  const GamificationState({
    this.xp = 0,
    this.coins = 0,
    this.level = 1,
    this.streak = 0,
    this.newlyUnlockedBadges = const [],
  });

  GamificationState copyWith({
    int? xp,
    int? coins,
    int? level,
    int? streak,
    List<String>? newlyUnlockedBadges,
  }) {
    return GamificationState(
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      newlyUnlockedBadges: newlyUnlockedBadges ?? this.newlyUnlockedBadges,
    );
  }
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(const GamificationState());

  void addXp(int amount) {
    final newXp = state.xp + amount;
    final newLevel = (newXp / 500).floor() + 1;
    state = state.copyWith(xp: newXp, level: newLevel);
  }

  void addCoins(int amount) {
    state = state.copyWith(coins: state.coins + amount);
  }

  void incrementStreak() {
    state = state.copyWith(streak: state.streak + 1);
  }

  void resetStreak() {
    state = state.copyWith(streak: 0);
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>(
  (ref) => GamificationNotifier(),
);
