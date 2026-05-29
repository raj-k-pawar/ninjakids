import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _secureStorage;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterSecureStorage? secureStorage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ─── Current auth state ───────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ─── Parent Registration ──────────────────────────────────────────────────

  Future<ParentEntity> registerParent({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final now = DateTime.now();

    final parent = ParentEntity(
      id: uid,
      name: name,
      email: email,
      kidIds: [],
      subscriptionPlan: 'free',
      createdAt: now,
    );

    await _firestore.collection(AppConstants.colParents).doc(uid).set({
      'id': uid,
      'name': name,
      'email': email,
      'kidIds': [],
      'subscriptionPlan': 'free',
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });

    await _firestore.collection(AppConstants.colUsers).doc(uid).set({
      'role': AppConstants.roleParent,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _storeUserRole(AppConstants.roleParent);
    return parent;
  }

  // ─── Parent Login ─────────────────────────────────────────────────────────

  Future<ParentEntity> loginParent({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final doc = await _firestore.collection(AppConstants.colParents).doc(uid).get();

    if (!doc.exists) throw Exception('Parent profile not found');

    final data = doc.data()!;
    await _storeUserRole(AppConstants.roleParent);

    return ParentEntity(
      id: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? email,
      kidIds: List<String>.from(data['kidIds'] ?? []),
      subscriptionPlan: data['subscriptionPlan'] ?? 'free',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ─── Google Sign-In (Parent) ──────────────────────────────────────────────

  Future<ParentEntity> signInWithGoogle() async {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    final credential = await _auth.signInWithProvider(googleProvider);
    final user = credential.user!;

    // Check if parent profile exists, create if not
    final docRef = _firestore.collection(AppConstants.colParents).doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'id': user.uid,
        'name': user.displayName ?? 'Parent',
        'email': user.email ?? '',
        'kidIds': [],
        'subscriptionPlan': 'free',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      await _firestore.collection(AppConstants.colUsers).doc(user.uid).set({
        'role': AppConstants.roleParent,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final data = (await docRef.get()).data()!;
    await _storeUserRole(AppConstants.roleParent);

    return ParentEntity(
      id: user.uid,
      name: data['name'] ?? user.displayName ?? '',
      email: data['email'] ?? user.email ?? '',
      kidIds: List<String>.from(data['kidIds'] ?? []),
      subscriptionPlan: data['subscriptionPlan'] ?? 'free',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ─── Kid Login (PIN-based) ────────────────────────────────────────────────

  Future<KidEntity> loginKid({
    required String parentId,
    required String kidId,
    required String pin,
  }) async {
    final doc = await _firestore.collection(AppConstants.colKids).doc(kidId).get();

    if (!doc.exists) throw Exception('Kid profile not found');

    final data = doc.data()!;

    // Verify PIN
    if (data['pin'] != pin) throw Exception('Incorrect PIN');
    // Verify kid belongs to this parent
    if (data['parentId'] != parentId) throw Exception('Unauthorized access');

    await _storeUserRole(AppConstants.roleKid);
    await _secureStorage.write(key: AppConstants.prefCurrentUserId, value: kidId);

    return _kidFromFirestore(doc.id, data);
  }

  // ─── Add Kid Profile ──────────────────────────────────────────────────────

  Future<KidEntity> addKidProfile({
    required String parentId,
    required String name,
    required String avatarEmoji,
    required int age,
    required String className,
    required String pin,
    required List<String> allowedSubjects,
    required int dailyScreenTimeLimitMinutes,
  }) async {
    final docRef = _firestore.collection(AppConstants.colKids).doc();
    final now = DateTime.now();

    final kidData = {
      'id': docRef.id,
      'parentId': parentId,
      'name': name,
      'avatarEmoji': avatarEmoji,
      'age': age,
      'className': className,
      'pin': pin,
      'allowedSubjects': allowedSubjects,
      'allowedGames': [],
      'dailyScreenTimeLimitMinutes': dailyScreenTimeLimitMinutes,
      'todayScreenTimeMinutes': 0,
      'isGamesLocked': false,
      'totalXp': 0,
      'level': 1,
      'coins': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(kidData);

    // Link kid to parent
    await _firestore.collection(AppConstants.colParents).doc(parentId).update({
      'kidIds': FieldValue.arrayUnion([docRef.id]),
    });

    return KidEntity(
      id: docRef.id,
      parentId: parentId,
      name: name,
      avatarEmoji: avatarEmoji,
      age: age,
      className: className,
      pin: pin,
      allowedSubjects: allowedSubjects,
      dailyScreenTimeLimitMinutes: dailyScreenTimeLimitMinutes,
      createdAt: now,
      lastActiveAt: now,
    );
  }

  // ─── Fetch parent ─────────────────────────────────────────────────────────

  Future<ParentEntity?> getParent(String uid) async {
    final doc = await _firestore.collection(AppConstants.colParents).doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return ParentEntity(
      id: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      kidIds: List<String>.from(data['kidIds'] ?? []),
      subscriptionPlan: data['subscriptionPlan'] ?? 'free',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ─── Fetch kids for parent ────────────────────────────────────────────────

  Future<List<KidEntity>> getKidsForParent(String parentId) async {
    final snapshot = await _firestore
        .collection(AppConstants.colKids)
        .where('parentId', isEqualTo: parentId)
        .get();

    return snapshot.docs.map((doc) => _kidFromFirestore(doc.id, doc.data())).toList();
  }

  // ─── Password Reset ───────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
    await _secureStorage.deleteAll();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  KidEntity _kidFromFirestore(String id, Map<String, dynamic> data) {
    return KidEntity(
      id: id,
      parentId: data['parentId'] ?? '',
      name: data['name'] ?? '',
      avatarEmoji: data['avatarEmoji'] ?? '🦊',
      age: data['age'] ?? 5,
      className: data['className'] ?? 'Class 1',
      pin: data['pin'] ?? '0000',
      allowedSubjects: List<String>.from(data['allowedSubjects'] ?? []),
      allowedGames: List<String>.from(data['allowedGames'] ?? []),
      dailyScreenTimeLimitMinutes: data['dailyScreenTimeLimitMinutes'] ?? 60,
      todayScreenTimeMinutes: data['todayScreenTimeMinutes'] ?? 0,
      isGamesLocked: data['isGamesLocked'] ?? false,
      totalXp: data['totalXp'] ?? 0,
      level: data['level'] ?? 1,
      coins: data['coins'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Future<void> _storeUserRole(String role) async {
    await _secureStorage.write(key: AppConstants.prefUserRole, value: role);
  }

  Future<String?> getStoredUserRole() async {
    return await _secureStorage.read(key: AppConstants.prefUserRole);
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
