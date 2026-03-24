import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/vib_button.dart';

// ── Allocation Edit Dialog ────────────────────────────────────────────────────

class AllocEditDialog extends StatefulWidget {
  const AllocEditDialog({
    super.key,
    required this.memberName,
    required this.userId,
    required this.weekIndex,
    required this.currentValue,
    required this.onSaved,
  });

  final String memberName;
  final String userId;
  final int weekIndex;
  final int currentValue;
  final VoidCallback onSaved;

  @override
  State<AllocEditDialog> createState() => _AllocEditDialogState();
}

class _AllocEditDialogState extends State<AllocEditDialog> {
  late double _value;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue.toDouble();
  }

  Color get _trackColor {
    if (_value < 40) return const Color(0xFF4CAF50);
    if (_value <= 80) return const Color(0xFFFFC107);
    if (_value <= 100) return const Color(0xFFFF9800);
    return VibColors.danger;
  }

  String get _label {
    if (_value < 40) return 'Available';
    if (_value <= 80) return 'Normal';
    if (_value <= 100) return 'High';
    return 'Overloaded';
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      // POST /allocations with user_id, week_index, pct
      await ApiClient.instance.dio.patch('/resources/allocations', data: {
        'user_id': widget.userId,
        'week_index': widget.weekIndex,
        'pct': _value.round(),
      });
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Allocation — ${widget.memberName}'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Week ${widget.weekIndex + 1}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            // Big pct display
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _trackColor.withValues(alpha: 0.1),
                border: Border.all(color: _trackColor, width: 3),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_value.round()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _trackColor,
                    ),
                  ),
                  Text(
                    _label,
                    style: TextStyle(fontSize: 10, color: _trackColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _trackColor,
                thumbColor: _trackColor,
                inactiveTrackColor: _trackColor.withValues(alpha: 0.2),
                overlayColor: _trackColor.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: _value,
                min: 0,
                max: 120,
                divisions: 24,
                onChanged: (v) => setState(() => _value = v),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('0%',
                    style: TextStyle(fontSize: 10, color: VibColors.textLight)),
                Text('50%',
                    style: TextStyle(fontSize: 10, color: VibColors.textLight)),
                Text('100%',
                    style: TextStyle(fontSize: 10, color: VibColors.textLight)),
                Text('120%',
                    style: TextStyle(
                        fontSize: 10, color: VibColors.danger)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        VibButton(
          label: 'Save',
          onPressed: _loading ? null : _save,
          loading: _loading,
        ),
      ],
    );
  }
}
