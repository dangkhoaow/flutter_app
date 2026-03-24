import 'package:equatable/equatable.dart';

class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.color,
    required this.startDate,
    required this.endDate,
    required this.ownerId,
    this.completionPct = 0,
    this.memberCount = 0,
    this.isBehindSchedule = false,
  });

  final String id;
  final String name;
  final String? description;
  final String status; // active | on_hold | completed | archived
  final String color;
  final DateTime startDate;
  final DateTime endDate;
  final String ownerId;
  final int completionPct;
  final int memberCount;
  final bool isBehindSchedule;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'active',
        color: json['color'] as String? ?? '#1a2b5f',
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        ownerId: json['owner_id'] as String,
        completionPct: json['completion_pct'] as int? ?? 0,
        memberCount: json['member_count'] as int? ?? 0,
        isBehindSchedule: json['is_behind_schedule'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'status': status,
        'color': color,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'owner_id': ownerId,
      };

  @override
  List<Object?> get props =>
      [id, name, status, color, startDate, endDate, ownerId, completionPct];
}
