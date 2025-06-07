import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskaway_app/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskaway_app/features/tasks/data/datasources/supabase_task_remote_data_source.dart'; // Ensure this import is correct
import 'package:taskaway_app/features/tasks/data/models/task_model.dart';
import 'package:taskaway_app/features/tasks/data/repositories/task_repository.dart';

part 'task_repository_impl.g.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      return await _remoteDataSource.getTasks();
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  @override
  Future<void> addTask(Task task) async {
    try {
      await _remoteDataSource.addTask(task);
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      await _remoteDataSource.updateTask(task);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _remoteDataSource.deleteTask(id);
    } catch (e) {
      // log('Error in TaskRepositoryImpl.deleteTask: $e');
      throw Exception('Repository error deleting task: $e');
    }
  }

  @override
  Future<void> permanentlyDeleteTask(String id) async {
    try {
      await _remoteDataSource.permanentlyDeleteTask(id);
    } catch (e) {
      throw Exception('Failed to permanently delete task: $e');
    }
  }

  @override
  Future<void> cleanupOldDeletedTasks() async {
    try {
      await _remoteDataSource.cleanupOldDeletedTasks();
    } catch (e) {
      throw Exception('Failed to clean up old tasks: $e');
    }
  }
}

@riverpod
TaskRepository taskRepository(Ref ref) {
  final remoteDataSource = ref.watch(supabaseTaskRemoteDataSourceProvider);
  return TaskRepositoryImpl(remoteDataSource);
}
