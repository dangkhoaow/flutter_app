import 'package:flutter/material.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_theme.dart';

// ── GanttPainter ──────────────────────────────────────────────────────────────

class GanttPainter extends CustomPainter {
  GanttPainter({
    required this.tasks,
    required this.projectStart,
    required this.colWidth,
    required this.rowHeight,
  });

  final List<Task> tasks;
  final DateTime projectStart;
  final double colWidth; // pixels per day = colWidth / 7
  final double rowHeight;

  double get _pxPerDay => colWidth / 7;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawTodayLine(canvas, size);
    for (var i = 0; i < tasks.length; i++) {
      _drawTask(canvas, tasks[i], i);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VibColors.border
      ..strokeWidth = 0.5;

    // Horizontal row lines
    for (var i = 0; i <= tasks.length; i++) {
      final y = i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical week lines
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += colWidth;
    }
  }

  void _drawTodayLine(Canvas canvas, Size size) {
    final today = DateTime.now();
    final x = today.difference(projectStart).inDays * _pxPerDay;
    if (x < 0 || x > size.width) return;

    final paint = Paint()
      ..color = VibColors.danger.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
  }

  void _drawTask(Canvas canvas, Task task, int rowIndex) {
    final y = rowIndex * rowHeight;

    if (task.isMilestone) {
      _drawMilestone(canvas, task, y);
    } else if (task.startDate != null && task.endDate != null) {
      _drawBar(canvas, task, y);
    }
  }

  void _drawBar(Canvas canvas, Task task, double y) {
    final start = task.startDate!;
    final end = task.endDate!;

    final x1 = start.difference(projectStart).inDays * _pxPerDay;
    final x2 = end.difference(projectStart).inDays * _pxPerDay + _pxPerDay;
    final width = x2 - x1;
    if (width <= 0) return;

    final barHeight = rowHeight * 0.5;
    final barY = y + (rowHeight - barHeight) / 2;

    final color = _statusColor(task.status);

    // Bar background
    final bgPaint = Paint()..color = color.withValues(alpha: 0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x1, barY, width, barHeight),
        const Radius.circular(4),
      ),
      bgPaint,
    );

    // Progress fill (approximate from status)
    final progress = _statusProgress(task.status);
    if (progress > 0) {
      final fillPaint = Paint()..color = color.withValues(alpha: 0.7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x1, barY, width * progress, barHeight),
          const Radius.circular(4),
        ),
        fillPaint,
      );
    }

    // Border
    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x1, barY, width, barHeight),
        const Radius.circular(4),
      ),
      borderPaint,
    );

    // Label
    if (width > 40) {
      final tp = TextPainter(
        text: TextSpan(
          text: task.title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.9),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width - 8);
      tp.paint(canvas, Offset(x1 + 4, barY + (barHeight - tp.height) / 2));
    }
  }

  void _drawMilestone(Canvas canvas, Task task, double y) {
    final date = task.endDate ?? task.startDate;
    if (date == null) return;

    final x = date.difference(projectStart).inDays * _pxPerDay;
    final centerY = y + rowHeight / 2;
    const size = 10.0;

    final paint = Paint()..color = VibColors.brand;
    final path = Path()
      ..moveTo(x, centerY - size)
      ..lineTo(x + size, centerY)
      ..lineTo(x, centerY + size)
      ..lineTo(x - size, centerY)
      ..close();
    canvas.drawPath(path, paint);
  }

  Color _statusColor(String status) {
    return switch (status) {
      'done' => VibColors.teal,
      'in_progress' => VibColors.brand,
      'in_review' => const Color(0xFF7B2CBF),
      _ => VibColors.textMid,
    };
  }

  double _statusProgress(String status) {
    return switch (status) {
      'done' => 1.0,
      'in_review' => 0.8,
      'in_progress' => 0.5,
      _ => 0.0,
    };
  }

  @override
  bool shouldRepaint(GanttPainter old) =>
      old.tasks != tasks ||
      old.projectStart != projectStart ||
      old.colWidth != colWidth;
}
