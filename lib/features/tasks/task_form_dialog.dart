import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/vib_button.dart';

// ── Task Form Dialog ──────────────────────────────────────────────────────────

class TaskFormDialog extends StatefulWidget {
  const TaskFormDialog({
    super.key,
    required this.projectId,
    this.task,
    this.parentTask,
    required this.onSaved,
  });

  final String projectId;
  final Task? task;
  final Task? parentTask;
  final VoidCallback onSaved;

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _status;
  late String _priority;
  late bool _isMilestone;
  late DateTime? _startDate;
  late DateTime? _endDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title);
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    _status = widget.task?.status ?? 'todo';
    _priority = widget.task?.priority ?? 'medium';
    _isMilestone = widget.task?.isMilestone ?? false;
    _startDate = widget.task?.startDate;
    _endDate = widget.task?.endDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'title': _titleCtrl.text.trim(),
      'description':
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'status': _status,
      'priority': _priority,
      'is_milestone': _isMilestone,
      'start_date': _startDate != null ? _fmt(_startDate!) : null,
      'end_date': _endDate != null ? _fmt(_endDate!) : null,
      'parent_id': widget.parentTask?.id,
    };

    try {
      if (widget.task == null) {
        await ApiClient.instance.dio
            .post('/projects/${widget.projectId}/tasks', data: data);
      } else {
        await ApiClient.instance.dio
            .patch('/tasks/${widget.task!.id}', data: data);
      }
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _loading = false);
      }
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['todo', 'in_progress', 'in_review', 'done']
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _priority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: ['critical', 'high', 'medium', 'low']
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(true),
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: 'Start Date'),
                          child: Text(
                            _startDate != null ? _fmtDisp(_startDate!) : '—',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(false),
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: 'End Date'),
                          child: Text(
                            _endDate != null ? _fmtDisp(_endDate!) : '—',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Mark as Milestone'),
                  value: _isMilestone,
                  onChanged: (v) => setState(() => _isMilestone = v ?? false),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: VibColors.brand,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        VibButton(
          label: widget.task == null ? 'Create Task' : 'Save Changes',
          onPressed: _loading ? null : _submit,
          loading: _loading,
        ),
      ],
    );
  }

  String _fmtDisp(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
