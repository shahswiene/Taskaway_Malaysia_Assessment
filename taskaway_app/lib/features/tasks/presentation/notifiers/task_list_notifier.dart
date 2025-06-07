import 'dart:async';
import 'dart:developer';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:taskaway_app/features/tasks/data/models/task_model.dart';
import 'package:taskaway_app/features/tasks/data/repositories/task_repository.dart'; // Import for the abstract class
import 'package:taskaway_app/features/tasks/data/repositories/task_repository_impl.dart';

part 'task_list_notifier.g.dart';

@riverpod
class TaskListNotifier extends _$TaskListNotifier {
  // Get the repository
  TaskRepository get _taskRepository => ref.read(taskRepositoryProvider);

  @override
  Future<List<Task>> build() async {
    // Load initial tasks
    return _fetchTasks();
  }

  Future<List<Task>> _fetchTasks() async {
    // Set state to loading if it's not already (e.g. on manual refresh)
    // state = const AsyncValue.loading(); // Handled automatically by AsyncNotifier on first build
    try {
      final tasks = await _taskRepository.getAllTasks();
      return tasks;
    } catch (e) {
      log('Error fetching tasks: $e', name: 'TaskListNotifier');
      // The AsyncNotifier will automatically set the state to AsyncError
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<void> refreshTasks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTasks());
  }

  Future<void> addTask(String title) async {
    // Optimistically update UI or show loading state
    // For simplicity, we'll refetch the list after adding.
    // A more advanced approach might involve adding to the current state directly.
    state = const AsyncValue.loading(); // Indicate loading
    try {
      // Create a new task model. ID and timestamps are handled by backend/model defaults.
      // For addTask, we primarily need the title.
      // The backend will generate id, created_at, updated_at.
      // is_completed defaults to false.
      final newTask = Task(
        id: '', // Placeholder, will be ignored by Supabase insert and generated
        title: title,
        createdAt: DateTime.now(), // Placeholder, will be set by Supabase
        updatedAt: DateTime.now(), // Placeholder, will be set by Supabase
      );
      await _taskRepository.addTask(newTask);
      await refreshTasks(); // Refresh the list to show the new task
    } catch (e, stackTrace) {
      log('Error adding task: $e', stackTrace: stackTrace, name: 'TaskListNotifier');
      state = AsyncValue.error(e, stackTrace); // Set error state
      // Optionally rethrow or handle specific errors for UI feedback
    }
  }

  Future<void> updateTask(Task task) async {
    state = const AsyncValue.loading();
    try {
      await _taskRepository.updateTask(task);
      await refreshTasks(); // Refresh the list
    } catch (e, stackTrace) {
      log('Error updating task: $e', stackTrace: stackTrace, name: 'TaskListNotifier');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    state = const AsyncValue.loading();
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await _taskRepository.updateTask(updatedTask);
      await refreshTasks();
    } catch (e, stackTrace) {
      log('Error toggling task completion: $e', stackTrace: stackTrace, name: 'TaskListNotifier');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    try {
      await _taskRepository.deleteTask(id);
      await refreshTasks(); // Refresh the list
    } catch (e, stackTrace) {
      log('Error deleting task: $e', stackTrace: stackTrace, name: 'TaskListNotifier');
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
