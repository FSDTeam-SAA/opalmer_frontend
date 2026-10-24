import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the current selected tab index for the student dashboard.
/// 0: Home, 1: Lessons, 2: Chat, 3: Quiz, 4: Profile
final studentTabIndexProvider = StateProvider<int>((ref) => 0);

/// Provider to manage the current selected tab index for the teacher dashboard.
/// 0: Home, 1: Classes, 2: Assignments, 3: Grades. Menu opens a drawer.
final teacherTabIndexProvider = StateProvider<int>((ref) => 0);
