import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskaway_app/core/providers/supabase_providers.dart';
import 'package:taskaway_app/features/tasks/data/datasources/task_remote_data_source.dart';
import 'dart:developer';

import 'package:taskaway_app/features/tasks/data/models/task_model.dart';

part 'supabase_task_remote_data_source.g.dart';

class SupabaseTaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final SupabaseClient _client;
  final String _tableName = 'tasks';

  SupabaseTaskRemoteDataSourceImpl(this._client);

  @override
  Future<List<Task>> getTasks() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      // Supabase < v10 returns List<dynamic>, v10+ returns List<Map<String, dynamic>>
      // The generated Task.fromJson expects Map<String, dynamic>.
      // Ensuring compatibility by casting if necessary.
      final tasks = (response as List<dynamic>)
          .map((data) => Task.fromJson(data as Map<String, dynamic>))
          .toList();
      return tasks;
    } catch (e) {
      log('Error fetching all tasks: $e', name: 'SupabaseTaskRemoteDataSourceImpl');
      // Consider more specific error handling or rethrowing custom exceptions
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  @override
  Future<void> addTask(Task task) async {
    // We only need to send fields that are not auto-generated or defaulted by Supabase
    // id, created_at, updated_at are handled by Supabase.
    // is_completed defaults to false in the model if not provided.
    // is_deleted defaults to false in the model if not provided.
    final taskData = {
      'title': task.title,
      'is_completed': task.isCompleted,
    };

    try {
      // Add the task to Supabase
      await _client
          .from(_tableName)
          .insert(taskData);

      log('Task added successfully');
    } catch (error) {
      log('Error adding task: $error');
      throw Exception('Failed to add task: $error');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskData = {
      'title': task.title,
      'is_completed': task.isCompleted,
      'is_deleted': task.isDeleted,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await _client
          .from(_tableName)
          .update(taskData)
          .eq('id', task.id);
      
      log('Task updated successfully');
    } catch (error) {
      log('Error updating task: $error');
      throw Exception('Failed to update task: $error');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      // Soft delete - mark as deleted and set update time
      await _client.from(_tableName).update({
        'is_deleted': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', taskId);
      log('Task marked as deleted successfully');
    } catch (error) {
      log('Error marking task as deleted: $error');
      throw Exception('Failed to mark task as deleted: $error');
    }
  }

  @override
  Future<void> permanentlyDeleteTask(String taskId) async {
    try {
      await _client.from(_tableName).delete().eq('id', taskId);
      log('Task permanently deleted successfully');
    } catch (error) {
      log('Error permanently deleting task: $error');
      throw Exception('Failed to permanently delete task: $error');
    }
  }

  @override
  Future<void> cleanupOldDeletedTasks() async {
    try {
      // Get all deleted tasks for debugging
      final allDeletedTasks = await _client.from(_tableName)
          .select()
          .eq('is_deleted', true);
          
      log('Total deleted tasks to clean up: ${allDeletedTasks.length}');
      
      // List all deleted tasks that will be permanently removed
      for (final task in allDeletedTasks) {
        log('Will delete: ${task['id']} - Title: ${task['title']} - Updated: ${task['updated_at']}');
      }
      
      if (allDeletedTasks.isNotEmpty) {
        // Delete all tasks that are marked as deleted
        final result = await _client.from(_tableName)
            .delete()
            .eq('is_deleted', true);
            
        log('Deletion result: $result');
        log('Permanently deleted ${allDeletedTasks.length} tasks');
      } else {
        log('No deleted tasks found to clean up');
      }
      
      log('Cleanup completed successfully');
    } catch (error) {
      log('Error cleaning up deleted tasks: $error');
      throw Exception('Failed to clean up deleted tasks: $error');
    }
  }
}

// For testing purposes - modify the cleanup function to work with recent tasks for testing
Future<void> createTestTaskWithOldDeletionDate(SupabaseClient client) async {
  try {
    // Create a test task that's deleted but recent
    final result = await client.from('tasks').insert({
      'title': 'Old deleted task for testing ${DateTime.now().millisecondsSinceEpoch}',
      'is_completed': false,
      'is_deleted': true
    }).select().single();
    
    log('Created test deleted task: ${result['id']}');
  } catch (e) {
    log('Error creating test task: $e');
  }
}

@riverpod
TaskRemoteDataSource supabaseTaskRemoteDataSource(Ref ref) {
  return SupabaseTaskRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}
