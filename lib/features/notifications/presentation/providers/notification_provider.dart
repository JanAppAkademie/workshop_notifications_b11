import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationIdProvider = StateProvider<int>((ref) => 0);

final notificationPermissionGrantedProvider = StateProvider<bool>((ref) => false);

final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController(ref);
});

class NotificationController {
  NotificationController(this._ref);

  final Ref _ref;

  NotificationService get _service => _ref.read(notificationServiceProvider);

  int _getNextId() {
    final currentId = _ref.read(notificationIdProvider);
    _ref.read(notificationIdProvider.notifier).state = currentId + 1;
    return currentId + 1;
  }

  Future<bool> requestPermissions() async {
    final granted = await _service.requestPermissions();
    _ref.read(notificationPermissionGrantedProvider.notifier).state = granted;
    return granted;
  }

  bool get hasPermission => _ref.read(notificationPermissionGrantedProvider);

  Future<void> showInstantNotification() async {
    final id = _getNextId();
    await _service.showInstantNotification(
      id: id,
      title: 'Instant Notification 🔔',
      body: 'This notification was shown immediately! ID: $id',
      payload: 'instant_$id',
    );
  }

  Future<void> scheduleNotification5Seconds() async {
    final id = _getNextId();
    await _service.scheduleNotificationAfterDelay(
      id: id,
      title: 'Scheduled Notification 5s',
      body: 'This notification was scheduled 5 seconds ago! ID: $id',
      delay: const Duration(seconds: 5),
      payload: 'scheduled_5s_$id',
    );
  }

  Future<void> scheduleNotification30Seconds() async {
    final id = _getNextId();
    await _service.scheduleNotificationAfterDelay(
      id: id,
      title: 'Scheduled Notification 30s',
      body: 'This notification was scheduled 30 seconds ago! ID: $id',
      delay: const Duration(seconds: 30),
      payload: 'scheduled_30s_$id',
    );
  }

  DateTime calculateScheduledDateTime(TimeOfDay pickedTime) {
    final now = DateTime.now();
    var scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    return scheduledDateTime;
  }

  Future<void> scheduleNotificationAtTime({
    required TimeOfDay pickedTime,
    required String formattedTime,
  }) async {
    final scheduledDateTime = calculateScheduledDateTime(pickedTime);
    final id = _getNextId();
    await _service.scheduleNotification(
      id: id,
      title: 'Scheduled Notification at $formattedTime',
      body: 'You scheduled this for $formattedTime! ID: $id',
      scheduledTime: scheduledDateTime,
      payload: 'scheduled_time_$id',
    );
  }
}
