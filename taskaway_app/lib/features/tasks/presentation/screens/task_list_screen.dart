import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskaway_app/features/tasks/data/models/task_model.dart';
import 'package:taskaway_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskaway_app/core/theme/theme_provider.dart';
import 'package:taskaway_app/features/tasks/presentation/providers/filter_provider.dart';
import 'package:taskaway_app/features/tasks/presentation/providers/task_providers.dart';
import 'package:taskaway_app/features/tasks/presentation/screens/task_generator_screen.dart';

enum PopupAction {
  cleanup,
}

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  // Cache scroll controller to prevent recreation
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Defer loading to avoid frame drops
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(tasksProvider);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final tasksAsyncValue = ref.watch(filteredTasksProvider);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskAway'),
        actions: [
          _buildFilterButton(context, ref),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () async {
              // Toggle theme mode
              final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
              
              // Update provider
              ref.read(themeProvider.notifier).state = newMode;
              
              // Save preference
              await saveThemePreference(newMode);
            },
          ),
          PopupMenuButton<PopupAction>(
            onSelected: (PopupAction result) async {
              if (result == PopupAction.cleanup) {
                await _showCleanupConfirmationDialog(context, ref);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<PopupAction>(
                value: PopupAction.cleanup,
                child: Text('Clean Up All Deleted Tasks'),
              ),
            ],
          ),
        ],
      ),
      body: tasksAsyncValue.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks yet. Add one!\n🎉',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tasksProvider);
              return await ref.refresh(tasksProvider.future);
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: tasks.length,
              cacheExtent: 100, // Cache more items for smoother scrolling
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isInDeletedMode = ref.watch(taskFilterProvider) == TaskFilter.deleted;
                return RepaintBoundary(
                  child: _TaskItem(
                    key: ValueKey(task.id),
                    task: task,
                    isInDeletedMode: isInDeletedMode,
                    onEdit: (task) => _showTaskDialog(context, task: task),
                    onDelete: (id) => _confirmDelete(context, id),
                    onToggle: (task) {
                      ref
                          .read(taskRepositoryProvider)
                          .updateTask(task)
                          .then((_) => ref.invalidate(tasksProvider));
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          // In a real app, log this error
          // log('Error loading tasks: $error', stackTrace: stackTrace, name: 'TaskListScreen');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText.rich(
                TextSpan(
                  text: 'Failed to load tasks. Please try again. \n\n',
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Error: $error',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Smart task generator button
          FloatingActionButton.small(
            heroTag: 'smartTaskButton',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TaskGeneratorScreen(),
              ),
            ),
            tooltip: 'Generate Smart Tasks',
            child: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(height: 16),
          // Regular add task button
          FloatingActionButton(
            heroTag: 'addTaskButton',
            onPressed: () => _showTaskDialog(context),
            tooltip: 'Add Task',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(taskFilterProvider);
    final String filterText;

    switch (currentFilter) {
      case TaskFilter.all:
        filterText = 'All';
        break;
      case TaskFilter.active:
        filterText = 'Active';
        break;
      case TaskFilter.completed:
        filterText = 'Completed';
        break;
      case TaskFilter.deleted:
        filterText = 'Deleted';
        break;
    }

    return TextButton.icon(
      icon: const Icon(Icons.filter_list),
      label: Text(filterText),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () {
        _showFilterDialog(context, ref);
      },
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterTile(context, ref, TaskFilter.all, 'All Tasks'),
            _buildFilterTile(context, ref, TaskFilter.active, 'Active Tasks'),
            _buildFilterTile(context, ref, TaskFilter.completed, 'Completed Tasks'),
            _buildFilterTile(context, ref, TaskFilter.deleted, 'Deleted Tasks'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTile(BuildContext context, WidgetRef ref, TaskFilter filter, String title) {
    final currentFilter = ref.watch(taskFilterProvider);
    return ListTile(
      title: Text(title),
      leading: Radio<TaskFilter>(
        value: filter,
        groupValue: currentFilter,
        onChanged: (value) {
          ref.read(taskFilterProvider.notifier).state = value!;
          Navigator.pop(context);
        },
      ),
      onTap: () {
        ref.read(taskFilterProvider.notifier).state = filter;
        Navigator.pop(context);
      },
    );
  }

  Future<void> _showCleanupConfirmationDialog(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clean Up All Deleted Tasks'),
        content: const Text(
            'This will permanently delete ALL soft-deleted tasks. This action cannot be undone. Do you want to proceed?'),
        actions: [
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          FilledButton.icon(
            onPressed: () async {
              // First close the dialog
              Navigator.pop(context);
              
              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cleaning up deleted tasks...'),
                  duration: Duration(seconds: 2),
                ),
              );
              
              try {
                // Call cleanup method using the provider
                await ref.read(cleanupTasksProvider)();
                
                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All deleted tasks have been permanently removed'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error cleaning up tasks: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.cleaning_services),
            label: const Text('Clean Up'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog to add or edit a task.
  Future<void> _showTaskDialog(BuildContext context, {Task? task}) async {
    final titleController = TextEditingController(text: task?.title);
    final formKey = GlobalKey<FormState>();
    final widgetRef = ref; // Capture ref for use inside async operations

    bool? operationWasSuccessful;

    try {
      operationWasSuccessful = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // User must explicitly cancel or save
        builder: (dialogContext) { // This is the dialog's own context
          bool isHidingField = false;
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                key: UniqueKey(), // Add UniqueKey to ensure it's treated as a new widget and disposed cleanly
                title: Text(task != null ? 'Edit Task' : 'Add New Task'),
                content: isHidingField 
                    ? const SizedBox.shrink() 
                    : Form(
                        key: formKey,
                        child: TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Task Title'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title cannot be empty';
                            }
                            return null;
                          },
                          // autofocus: true, // Temporarily removed for diagnostics
                        ),
                      ),
                actions: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final newTitle = titleController.text.trim();
                        try {
                          if (task == null) {
                            final newTask = Task(
                              id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
                              title: newTitle,
                              isCompleted: false,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              isDeleted: false,
                            );
                            await widgetRef.read(taskRepositoryProvider).addTask(newTask);
                          } else {
                            final updatedTask = task.copyWith(
                              title: newTitle,
                              updatedAt: DateTime.now(),
                            );
                            await widgetRef.read(taskRepositoryProvider).updateTask(updatedTask);
                          }
                          // Hide the field, wait for rebuild, then pop
                          // Use the setState from StatefulBuilder
                          setState(() { 
                            isHidingField = true;
                          });
                          await Future.microtask(() {}); // Ensure rebuild before pop
                          if (dialogContext.mounted) Navigator.pop(dialogContext, true); // Success
                        } catch (e) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('Error saving task: $e')),
                            );
                            // Optionally, pop with false or do nothing to allow retry
                            // Navigator.pop(dialogContext, false);
                          }
                        }
                      }
                    },
                    icon: Icon(task != null ? Icons.save : Icons.add_task),
                    label: Text(task != null ? 'Save Changes' : 'Add Task'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              );
            },
          );
        }
      );
    } finally {
      // This block executes after `await showDialog` completes (dialog is closed).
      titleController.dispose();
    }

    // After dialog is closed and controller is disposed, invalidate if operation was successful.
    if (operationWasSuccessful == true) {
      // Introduce a small delay to ensure the framework has processed the dialog closure
      // and controller disposal completely before invalidating the provider.
      await Future.delayed(const Duration(milliseconds: 50)); 
      if (context.mounted) { // Ensure the TaskListScreen is still in the tree
        widgetRef.invalidate(tasksProvider);
      }
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    final currentFilter = ref.read(taskFilterProvider);
    final isPermanentlyDeleting = currentFilter == TaskFilter.deleted;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPermanentlyDeleting ? 'Permanently Delete Task?' : 'Delete Task'),
        content: Text(isPermanentlyDeleting
            ? 'This task will be permanently removed. This action cannot be undone.'
            : 'Are you sure you want to move this task to the bin?'),
        actions: [
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          FilledButton.icon(
            onPressed: () async {
              if (isPermanentlyDeleting) {
                await ref.read(taskRepositoryProvider).permanentlyDeleteTask(id);
              } else {
                await ref.read(taskRepositoryProvider).deleteTask(id);
              }
              ref.invalidate(tasksProvider);
              if (context.mounted) Navigator.pop(context);
            },
            icon: Icon(isPermanentlyDeleting ? Icons.delete_forever : Icons.delete),
            label: Text(isPermanentlyDeleting ? 'Permanently Delete' : 'Delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for TaskItem widget - we will create this as a separate file
class _TaskItem extends StatelessWidget {
  const _TaskItem({
    super.key,
    required this.task,
    required this.isInDeletedMode,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final Task task;
  final bool isInDeletedMode;
  final Function(Task) onEdit;
  final Function(String) onDelete;
  final Function(Task) onToggle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Theme.of(context).disabledColor : null,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
          color: task.isCompleted ? Theme.of(context).primaryColor : null,
        ),
        onPressed: () => onToggle(task.copyWith(isCompleted: !task.isCompleted)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isInDeletedMode) ...[
            IconButton(
              icon: Icon(Icons.edit, color: Colors.amber),
              onPressed: () => onEdit(task),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(task.id),
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.restore, color: Colors.blue),
              onPressed: () => onToggle(task.copyWith(isDeleted: false)),
            ),
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () => onDelete(task.id),
            ),
          ],
        ],
      ),
      onTap: () => onToggle(task.copyWith(isCompleted: !task.isCompleted)),
    );
  }
}
