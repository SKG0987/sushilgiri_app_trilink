import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/todo.dart';
import '../services/auth_provider.dart';
import '../services/todo_provider.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTodos());
  }

  void _fetchTodos() {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      context
          .read<TodoProvider>()
          .fetchTodos(userId: auth.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEditDialog({Todo? todo}) {
    final titleController = TextEditingController(text: todo?.title ?? '');
    final descController =
        TextEditingController(text: todo?.description ?? '');
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  todo == null ? 'Add New Task' : 'Edit Task',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Title is required' : null,
                  style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'Enter task title...',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: descController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Add more details...',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          Navigator.pop(ctx);

                          final provider = context.read<TodoProvider>();
                          final authProvider = context.read<AuthProvider>();

                          try {
                            final title = titleController.text.trim();
                            final description = descController.text.trim();

                            if (todo == null) {
                              await provider.addTodo(
                                title,
                                description:
                                    description.isEmpty ? null : description,
                                userId: authProvider.currentUser?.id,
                              );
                            } else {
                              await provider.updateTodo(
                                todo.id,
                                title,
                                description:
                                    description.isEmpty ? null : description,
                              );
                            }
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(todo == null
                                    ? 'Failed to add task'
                                    : 'Failed to update task'),
                              ),
                            );
                          }
                        },
                        child: Text(todo == null ? 'Add Task' : 'Save'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Todo todo) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Task',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${todo.title}"?',
          style: GoogleFonts.poppins(color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style:
                  GoogleFonts.poppins(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<TodoProvider>().deleteTodo(todo.id);
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete task'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final loggedIn = auth.isLoggedIn;

        return Scaffold(
          appBar: AppBar(
            title: const Text('To-Do List'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (loggedIn)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _fetchTodos,
                ),
            ],
            bottom: loggedIn
                ? TabBar(
                    controller: _tabController,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor:
                        theme.colorScheme.onSurfaceVariant,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 2.5,
                    tabs: const [
                      Tab(text: 'Pending'),
                      Tab(text: 'Completed'),
                    ],
                  )
                : null,
          ),
          body: !loggedIn
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'First Login to use To-Do',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Consumer<TodoProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      );
                    }

                    if (provider.error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Error loading todos',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.error!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _fetchTodos,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _TodoList(
                          todos: provider.pendingTodos,
                          emptyMessage:
                              'No pending tasks!\nTap + to add one.',
                          emptyIcon: Icons.task_alt_rounded,
                          onEdit: (todo) => _showAddEditDialog(todo: todo),
                          onDelete: (todo) => _confirmDelete(context, todo),
                          onToggle: (todo) => context
                              .read<TodoProvider>()
                              .toggleComplete(todo.id),
                        ),
                        _TodoList(
                          todos: provider.completedTodos,
                          emptyMessage: 'No completed tasks yet.',
                          emptyIcon: Icons.check_circle_outline_rounded,
                          onEdit: (todo) => _showAddEditDialog(todo: todo),
                          onDelete: (todo) => _confirmDelete(context, todo),
                          onToggle: (todo) => context
                              .read<TodoProvider>()
                              .toggleComplete(todo.id),
                        ),
                      ],
                    );
                  },
                ),
          floatingActionButton: loggedIn
              ? FloatingActionButton(
                  onPressed: () => _showAddEditDialog(),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: const Icon(Icons.add_rounded),
                )
              : null,
        );
      },
    );
  }
}

class _TodoList extends StatelessWidget {
  final List<Todo> todos;
  final String emptyMessage;
  final IconData emptyIcon;
  final void Function(Todo) onEdit;
  final void Function(Todo) onDelete;
  final void Function(Todo) onToggle;

  const _TodoList({
    required this.todos,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _TodoCard(
          todo: todo,
          onEdit: () => onEdit(todo),
          onDelete: () => onDelete(todo),
          onToggle: () => onToggle(todo),
        );
      },
    );
  }
}

class _TodoCard extends StatefulWidget {
  final Todo todo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _TodoCard({
    required this.todo,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  State<_TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<_TodoCard> {
  bool _expanded = false;

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');

    final hour24 = dt.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = hour24 < 12 ? 'AM' : 'PM';

    return '$y/$m/$d, $hour12:$min $ampm';
  }

  static String _relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';

    if (diff.inDays == 1) {
      final hour24 = dt.hour;
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = hour24 < 12 ? 'AM' : 'PM';
      return 'yesterday $hour12:$min $ampm';
    }

    return _formatDate(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todo = widget.todo;

    final relativeDate = _relativeTime(
      todo.isCompleted && todo.completedAt != null
          ? todo.completedAt!
          : todo.createdAt,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              todo.title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: todo.isCompleted
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todo.description != null && todo.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      todo.description!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                      maxLines: _expanded ? 999 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (!_expanded)
                  Text(
                    relativeDate,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    todo.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 22,
                    color: todo.isCompleted
                        ? const Color(0xFF10B981)
                        : theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                  ),
                  onPressed: widget.onToggle,
                  tooltip: todo.isCompleted ? 'Mark pending' : 'Mark complete',
                ),
                if (!todo.isCompleted)
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: widget.onEdit,
                    tooltip: 'Edit',
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: theme.dividerColor),
                  Text(
                    'Created: ${_formatDate(todo.createdAt)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  if (todo.isCompleted && todo.completedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Completed: ${_formatDate(todo.completedAt!)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}