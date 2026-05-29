import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Todo> get pendingTodos =>
      _todos.where((t) => !t.isCompleted).toList();
  List<Todo> get completedTodos =>
      _todos.where((t) => t.isCompleted).toList();

  Future<void> fetchTodos({String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = userId != null
          ? await _supabase
              .from('todos')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false)
          : await _supabase
              .from('todos')
              .select()
              .order('created_at', ascending: false);

      _todos = (response as List).map((e) => Todo.fromJson(e)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(String title, {String? description, String? userId}) async {
    try {
      final response = await _supabase
          .from('todos')
          .insert({
            'title': title,
            'description': description,
            'is_completed': false,
            'user_id': userId,
          })
          .select()
          .single();

      _todos.insert(0, Todo.fromJson(response));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTodo(String id, String title,
      {String? description}) async {
    try {
      await _supabase.from('todos').update({
        'title': title,
        'description': description,
      }).eq('id', id);

      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(
          title: title,
          description: description,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleComplete(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final newVal = !_todos[index].isCompleted;
    final now = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 5, minutes: 45));
    try {
      await _supabase.from('todos').update({
        'is_completed': newVal,
        'completed_at': newVal ? now.toIso8601String() : null,
      }).eq('id', id);

      _todos[index] = _todos[index].copyWith(
        isCompleted: newVal,
        completedAt: newVal ? now : null,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _supabase.from('todos').delete().eq('id', id);
      _todos.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
