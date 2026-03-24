import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/top_bar.dart';
import 'gantt_painter.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final ganttTasksProvider =
    FutureProvider.family<List<Task>, String>((ref, projectId) async {
  final resp = await ApiClient.instance.dio.get('/projects/$projectId/tasks');
  return (resp.data as List)
      .map((t) => Task.fromJson(t as Map<String, dynamic>))
      .toList();
});

// ── Zoom levels ───────────────────────────────────────────────────────────────

enum GanttZoom { week, month, quarter }

final _zoomProvider = StateProvider((_) => GanttZoom.week);

// ── Gantt Screen ──────────────────────────────────────────────────────────────

class GanttScreen extends ConsumerWidget {
  const GanttScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(ganttTasksProvider(projectId));
    final zoom = ref.watch(_zoomProvider);

    return Scaffold(
      appBar: TopBar(
        title: 'Gantt Chart',
        actions: [
          _ZoomToggle(zoom: zoom, onChanged: (z) => ref.read(_zoomProvider.notifier).state = z),
        ],
      ),
      backgroundColor: VibColors.bg,
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) => tasks.isEmpty
            ? const Center(child: Text('No tasks with dates to display.'))
            : _GanttView(tasks: tasks, zoom: zoom),
      ),
    );
  }
}

// ── Gantt View ────────────────────────────────────────────────────────────────

class _GanttView extends StatelessWidget {
  const _GanttView({required this.tasks, required this.zoom});
  final List<Task> tasks;
  final GanttZoom zoom;

  List<Task> get _flatTasks {
    final result = <Task>[];
    void flatten(Task t) {
      result.add(t);
      for (final c in t.children) {
        flatten(c);
      }
    }
    for (final t in tasks) flatten(t);
    return result.where((t) => t.startDate != null || t.endDate != null).toList();
  }

  @override
  Widget build(BuildContext context) {
    final flat = _flatTasks;
    if (flat.isEmpty) {
      return const Center(child: Text('No tasks with dates to display.'));
    }

    final earliest = flat
        .where((t) => t.startDate != null)
        .map((t) => t.startDate!)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final latest = flat
        .where((t) => t.endDate != null)
        .map((t) => t.endDate!)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final colWidth = zoom == GanttZoom.week ? 70.0 : zoom == GanttZoom.month ? 40.0 : 20.0;
    final totalDays = latest.difference(earliest).inDays + 14;
    final totalWidth = totalDays * (colWidth / 7);

    return Row(
      children: [
        // Task name column (sticky-like)
        SizedBox(
          width: 240,
          child: Column(
            children: [
              Container(
                height: 40,
                color: VibColors.bg,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: const Text('Task',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: VibColors.textLight)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: flat.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final t = flat[i];
                    return Container(
                      height: 40,
                      color: VibColors.surface,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          if (t.isMilestone)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: VibColors.brand,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                              transform: Matrix4.rotationZ(0.785),
                            ),
                          Expanded(
                            child: Text(
                              t.title,
                              style: const TextStyle(
                                  fontSize: 12, color: VibColors.textDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Gantt painter area
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth,
              child: Column(
                children: [
                  // Header row
                  _GanttHeader(
                    start: earliest,
                    totalDays: totalDays,
                    colWidth: colWidth,
                    zoom: zoom,
                  ),
                  const Divider(height: 1),
                  // Bars
                  Expanded(
                    child: CustomPaint(
                      painter: GanttPainter(
                        tasks: flat,
                        projectStart: earliest,
                        colWidth: colWidth,
                        rowHeight: 40,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Gantt Header ──────────────────────────────────────────────────────────────

class _GanttHeader extends StatelessWidget {
  const _GanttHeader({
    required this.start,
    required this.totalDays,
    required this.colWidth,
    required this.zoom,
  });

  final DateTime start;
  final int totalDays;
  final double colWidth;
  final GanttZoom zoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: VibColors.bg,
      child: CustomPaint(
        painter: _HeaderPainter(
          start: start,
          totalDays: totalDays,
          colWidth: colWidth,
          zoom: zoom,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HeaderPainter extends CustomPainter {
  _HeaderPainter({
    required this.start,
    required this.totalDays,
    required this.colWidth,
    required this.zoom,
  });

  final DateTime start;
  final int totalDays;
  final double colWidth;
  final GanttZoom zoom;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = VibColors.border
      ..strokeWidth = 1;
    final textStyle = const TextStyle(
      fontSize: 9,
      color: VibColors.textLight,
      fontWeight: FontWeight.w600,
    );

    // Draw week/month columns
    final step = zoom == GanttZoom.week ? 7 : zoom == GanttZoom.month ? 30 : 90;
    final stepWidth = colWidth * step / 7;

    var x = 0.0;
    var d = start;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);

      final label = zoom == GanttZoom.week
          ? 'W${_weekNum(d)}'
          : zoom == GanttZoom.month
              ? _monthLabel(d)
              : 'Q${((d.month - 1) ~/ 3) + 1}';

      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 4, (size.height - tp.height) / 2));

      x += stepWidth;
      d = d.add(Duration(days: step));
    }
  }

  int _weekNum(DateTime d) {
    final startOfYear = DateTime(d.year, 1, 1);
    return ((d.difference(startOfYear).inDays) / 7).ceil() + 1;
  }

  String _monthLabel(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[d.month - 1];
  }

  @override
  bool shouldRepaint(_HeaderPainter old) =>
      old.start != start || old.zoom != zoom;
}

// ── Zoom Toggle ───────────────────────────────────────────────────────────────

class _ZoomToggle extends StatelessWidget {
  const _ZoomToggle({required this.zoom, required this.onChanged});
  final GanttZoom zoom;
  final ValueChanged<GanttZoom> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<GanttZoom>(
      segments: const [
        ButtonSegment(value: GanttZoom.week, label: Text('Week')),
        ButtonSegment(value: GanttZoom.month, label: Text('Month')),
        ButtonSegment(value: GanttZoom.quarter, label: Text('Quarter')),
      ],
      selected: {zoom},
      onSelectionChanged: (s) => onChanged(s.first),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
