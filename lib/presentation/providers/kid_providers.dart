import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';

final currentKidProvider = FutureProvider<KidEntity>((ref) async {
  throw UnimplementedError('Set active kid in auth flow');
});
