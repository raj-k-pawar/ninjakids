import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../services/auth/auth_service.dart';

final currentKidProvider = FutureProvider<KidEntity>((ref) async {
  throw UnimplementedError('Set active kid in auth flow');
});
