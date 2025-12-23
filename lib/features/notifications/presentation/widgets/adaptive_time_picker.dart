import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveTimePicker {
  AdaptiveTimePicker._();

  static Future<TimeOfDay?> show(BuildContext context) async {
    final now = DateTime.now();
    final initialTime = now.add(const Duration(minutes: 1));

    if (Platform.isIOS) {
      return _showCupertinoTimePicker(context, initialTime);
    } else {
      return showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialTime),
      );
    }
  }

  static Future<TimeOfDay?> _showCupertinoTimePicker(
    BuildContext context,
    DateTime initialTime,
  ) async {
    DateTime? selectedTime = initialTime;

    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialTime,
                onDateTimeChanged: (DateTime newTime) {
                  selectedTime = newTime;
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedTime != null) {
      return TimeOfDay.fromDateTime(selectedTime!);
    }
    return null;
  }
}

