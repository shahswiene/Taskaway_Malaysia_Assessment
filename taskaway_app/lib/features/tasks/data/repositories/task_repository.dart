import 'package:taskaway_app/features/tasks/data/models/task_model.dart';

/// Abstract class for the Task Repository.
/// This layer mediates between the domain layer and data mapping layers,
/// handling data retrieval and storage.
abstract class TaskRepository {
  /// Fetches all tasks.
  Future<List<Task>> getAllTasks();

  /// Adds a new task.
  /// The [task] model should contain the title.
  Future<void> addTask(Task task);

  /// Updates an existing task.
  Future<void> updateTask(Task task);

  /// Deletes a task by its [id].
  Future<void> deleteTask(String id);

  /// Permanently deletes a task by its [id].
  Future<void> permanentlyDeleteTask(String id);

  /// Cleans up old deleted tasks.
  Future<void> cleanupOldDeletedTasks();
}
