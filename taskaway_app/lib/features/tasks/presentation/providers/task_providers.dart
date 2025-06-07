import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskaway_app/features/tasks/data/models/task_model.dart';
import 'package:taskaway_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskaway_app/features/tasks/presentation/providers/filter_provider.dart';

/// Provider that watches the task repository and returns all tasks
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getAllTasks();
});

/// Provider that returns filtered tasks based on the current filter
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsyncValue = ref.watch(tasksProvider);
  final filter = ref.watch(taskFilterProvider);

  return tasksAsyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (tasks) {
      switch (filter) {
        case TaskFilter.active:
          return AsyncValue.data(
            tasks.where((task) => !task.isCompleted && !task.isDeleted).toList());
        case TaskFilter.completed:
          return AsyncValue.data(
            tasks.where((task) => task.isCompleted && !task.isDeleted).toList());
        case TaskFilter.deleted:
          return AsyncValue.data(
            tasks.where((task) => task.isDeleted).toList());
        case TaskFilter.all:
          return AsyncValue.data(
            tasks.where((task) => !task.isDeleted).toList());
      }
    },
  );
});

/// Provider that performs cleanup of tasks deleted more than 30 days ago
final cleanupTasksProvider = Provider<Future<void> Function()>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  
  return () async {
    await repository.cleanupOldDeletedTasks();
    // Refresh the tasks list after cleanup
    ref.invalidate(tasksProvider);
  };
});
