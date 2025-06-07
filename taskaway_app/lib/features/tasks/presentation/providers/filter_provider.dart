import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TaskFilter {
  all,
  active,
  completed,
  deleted
}

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);
