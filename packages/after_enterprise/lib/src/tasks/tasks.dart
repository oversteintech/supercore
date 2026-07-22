import 'package:after_core/after_core.dart';
import 'package:meta/meta.dart';

import '../scope/enterprise_scope.dart';

enum TaskStatus { open, inProgress, blocked, done, cancelled }

enum TaskPriority { low, medium, high, urgent }

@immutable
class EnterpriseTask {
  const EnterpriseTask({
    required this.id,
    required this.organizationId,
    required this.title,
    this.description,
    this.assigneeId,
    this.dueAt,
    this.status = TaskStatus.open,
    this.priority = TaskPriority.medium,
    this.linkedWorkflowInstanceId,
    this.tags = const [],
    this.createdAt,
  });

  final String id;
  final String organizationId;
  final String title;
  final String? description;
  final String? assigneeId;
  final DateTime? dueAt;
  final TaskStatus status;
  final TaskPriority priority;
  final String? linkedWorkflowInstanceId;
  final List<String> tags;
  final DateTime? createdAt;

  EnterpriseTask copyWith({
    String? title,
    String? description,
    String? assigneeId,
    DateTime? dueAt,
    TaskStatus? status,
    TaskPriority? priority,
    String? linkedWorkflowInstanceId,
    List<String>? tags,
  }) {
    return EnterpriseTask(
      id: id,
      organizationId: organizationId,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeId: assigneeId ?? this.assigneeId,
      dueAt: dueAt ?? this.dueAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      linkedWorkflowInstanceId:
          linkedWorkflowInstanceId ?? this.linkedWorkflowInstanceId,
      tags: tags ?? this.tags,
      createdAt: createdAt,
    );
  }
}

abstract class TaskRepository {
  /// Fail-closed: [organizationId] is required (ADR-002).
  Future<List<EnterpriseTask>> listTasks({
    required String organizationId,
    String? assigneeId,
    TaskStatus? status,
  });

  Future<Page<EnterpriseTask>> pageTasks({
    required String organizationId,
    PageQuery query = const PageQuery(),
    String? assigneeId,
    TaskStatus? status,
  });

  Future<EnterpriseTask?> getTask(String id);
  Future<EnterpriseTask> createTask(EnterpriseTask task);
  Future<EnterpriseTask> updateTask(EnterpriseTask task);
  Future<void> deleteTask(String id);
}

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository({List<EnterpriseTask>? seed})
      : _tasks = {for (final t in seed ?? const <EnterpriseTask>[]) t.id: t};

  final Map<String, EnterpriseTask> _tasks;
  var _nextId = 1;

  @override
  Future<List<EnterpriseTask>> listTasks({
    required String organizationId,
    String? assigneeId,
    TaskStatus? status,
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    return _tasks.values.where((t) {
      if (t.organizationId != org) return false;
      if (assigneeId != null && t.assigneeId != assigneeId) return false;
      if (status != null && t.status != status) return false;
      return true;
    }).toList(growable: false);
  }

  @override
  Future<Page<EnterpriseTask>> pageTasks({
    required String organizationId,
    PageQuery query = const PageQuery(),
    String? assigneeId,
    TaskStatus? status,
  }) async {
    final all = await listTasks(
      organizationId: organizationId,
      assigneeId: assigneeId,
      status: status,
    );
    return Page.fromList(all, query);
  }

  @override
  Future<EnterpriseTask?> getTask(String id) async => _tasks[id];

  @override
  Future<EnterpriseTask> createTask(EnterpriseTask task) async {
    final id = task.id.isEmpty ? 'task_${_nextId++}' : task.id;
    final stored = EnterpriseTask(
      id: id,
      organizationId: task.organizationId,
      title: task.title,
      description: task.description,
      assigneeId: task.assigneeId,
      dueAt: task.dueAt,
      status: task.status,
      priority: task.priority,
      linkedWorkflowInstanceId: task.linkedWorkflowInstanceId,
      tags: task.tags,
      createdAt: task.createdAt ?? DateTime.now().toUtc(),
    );
    _tasks[id] = stored;
    return stored;
  }

  @override
  Future<EnterpriseTask> updateTask(EnterpriseTask task) async {
    _tasks[task.id] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.remove(id);
  }
}
