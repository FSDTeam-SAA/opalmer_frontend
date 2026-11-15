import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';

// Refresh every mounted child view after a relationship changes.
final parentChildrenRevisionProvider = StateProvider<int>((ref) {
  ref.watch(authStateProvider);
  return 0;
});
