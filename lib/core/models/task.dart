import 'package:equatable/equatable.dart';

String _stringField(Object? value, {required String fallback}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

class Task extends Equatable {
  const Task({
    required this.id,
    required this.projectId,
    this.parentId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    this.startDate,
    this.endDate,
    this.isMilestone = false,
    required this.wbsPos,
    this.children = const [],
  });

  final String id;
  final String projectId;
  final String? parentId;
  final String title;
  final String? description;
  final String status;   // todo | in_progress | in_review | done
  final String priority; // critical | high | medium | low
  final String? assigneeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isMilestone;
  final String wbsPos;
  final List<Task> children;

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        parentId: json['parent_id'] as String?,
        title: json['title'] as String,
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'todo',
        priority: json['priority'] as String? ?? 'medium',
        assigneeId: json['assignee_id'] as String?,
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'] as String)
            : null,
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        isMilestone: json['is_milestone'] as bool? ?? false,
        wbsPos: _stringField(json['wbs_pos'], fallback: '0'),
        children: (json['children'] as List<dynamic>?)
                ?.map((c) => Task.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'parent_id': parentId,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'assignee_id': assigneeId,
        'start_date': startDate?.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
        'is_milestone': isMilestone,
        'wbs_pos': wbsPos,
      };

  Task copyWith({
    String? status,
    String? priority,
    String? assigneeId,
    List<Task>? children,
  }) =>
      Task(
        id: id,
        projectId: projectId,
        parentId: parentId,
        title: title,
        description: description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        assigneeId: assigneeId ?? this.assigneeId,
        startDate: startDate,
        endDate: endDate,
        isMilestone: isMilestone,
        wbsPos: wbsPos,
        children: children ?? this.children,
      );

  @override
  List<Object?> get props => [id, projectId, title, status, priority, wbsPos];
}
