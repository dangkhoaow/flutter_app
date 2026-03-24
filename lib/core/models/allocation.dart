import 'package:equatable/equatable.dart';

class Allocation extends Equatable {
  const Allocation({
    required this.userId,
    required this.projectId,
    required this.weekStart,
    required this.pct,
  });

  final String userId;
  final String projectId;
  final DateTime weekStart;
  final int pct; // 0-120

  factory Allocation.fromJson(Map<String, dynamic> json) => Allocation(
        userId: json['user_id'] as String,
        projectId: json['project_id'] as String,
        weekStart: DateTime.parse(json['week_start'] as String),
        pct: json['pct'] as int,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'project_id': projectId,
        'week_start': weekStart.toIso8601String().split('T').first,
        'pct': pct,
      };

  @override
  List<Object?> get props => [userId, projectId, weekStart, pct];
}

class HeatmapRow extends Equatable {
  const HeatmapRow({
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.weeks,
  });

  final String userId;
  final String userName;
  final String userRole;
  final List<int> weeks; // 12 values 0-120

  factory HeatmapRow.fromJson(Map<String, dynamic> json) => HeatmapRow(
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        userRole: json['user_role'] as String,
        weeks: (json['weeks'] as List<dynamic>).map((w) => w as int).toList(),
      );

  @override
  List<Object?> get props => [userId, userName, weeks];
}
