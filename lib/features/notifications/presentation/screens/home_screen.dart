import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../providers/fcm_provider.dart';
import '../widgets/section_card.dart';
import '../widgets/action_button.dart';
import '../widgets/adaptive_time_picker.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final controller = ref.read(notificationControllerProvider);
    final granted = await controller.requestPermissions();
    if (!granted && mounted) {
      _showSnackBar('Notification permission denied');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(notificationControllerProvider);
    final fcmTokenAsync = ref.watch(fcmTokenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications Demo',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /*
            SectionCard(
              title: 'FCM Token',
              subtitle: 'Firebase Cloud Messaging device token',
              icon: Icons.cloud,
              iconColor: Colors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: fcmTokenAsync.when(
                      data: (token) => SelectableText(
                        token ?? 'No token available',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      loading: () => const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (e, _) => Text(
                        'Error: $e',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          label: 'Copy Token',
                          icon: Icons.copy,
                          onPressed: () async {
                            final token = await ref.read(
                              fcmTokenProvider.future,
                            );
                            if (token != null) {
                              await Clipboard.setData(
                                ClipboardData(text: token),
                              );
                              _showSnackBar('Token copied to clipboard!');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionButton(
                          label: 'Refresh',
                          icon: Icons.refresh,
                          onPressed: () {
                            ref.read(fcmControllerProvider).refreshToken();
                            _showSnackBar('Token refreshed!');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            */
            const SizedBox(height: 20),

            SectionCard(
              title: 'Instant Notification',
              subtitle: 'Show a notification immediately',
              icon: Icons.notifications_active,
              iconColor: Theme.of(context).colorScheme.tertiaryContainer,
              child: ActionButton(
                label: 'Show Now',
                icon: Icons.send,
                onPressed: () async {
                  if (!controller.hasPermission) {
                    _showSnackBar('Notification permission denied');
                    return;
                  }
                  await controller.showInstantNotification();
                  _showSnackBar('Instant notification sent!');
                },
              ),
            ),
            const SizedBox(height: 20),

            SectionCard(
              title: 'Scheduled Notifications',
              subtitle: 'Schedule notifications for later',
              icon: Icons.schedule,
              iconColor: const Color(0xFF0F3460),
              child: Column(
                children: [
                  ActionButton(
                    label: 'In 5 Seconds',
                    icon: Icons.timer,
                    onPressed: () async {
                      if (!controller.hasPermission) {
                        _showSnackBar('Notification permission denied');
                        return;
                      }
                      await controller.scheduleNotification5Seconds();
                      _showSnackBar('Notification scheduled for 5 seconds!');
                    },
                  ),
                  const SizedBox(height: 12),
                  ActionButton(
                    label: 'In 30 Seconds',
                    icon: Icons.timer_outlined,
                    onPressed: () async {
                      if (!controller.hasPermission) {
                        _showSnackBar('Notification permission denied');
                        return;
                      }
                      await controller.scheduleNotification30Seconds();
                      _showSnackBar('Notification scheduled for 30 seconds!');
                    },
                  ),
                  const SizedBox(height: 12),
                  ActionButton(
                    label: 'Pick a Time',
                    icon: Icons.access_time,
                    onPressed: () async {
                      if (!controller.hasPermission) {
                        _showSnackBar('Notification permission denied');
                        return;
                      }
                      final pickedTime = await AdaptiveTimePicker.show(context);

                      if (pickedTime != null && context.mounted) {
                        final formattedTime = pickedTime.format(context);
                        await controller.scheduleNotificationAtTime(
                          pickedTime: pickedTime,
                          formattedTime: formattedTime,
                        );
                        _showSnackBar(
                          'Notification scheduled for $formattedTime!',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
