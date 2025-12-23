import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/fcm_service.dart';

/// Provider for the FCM Service instance
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

/// Provider for the current FCM token
/// Use ref.watch(fcmTokenProvider) to reactively get the token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);
  return await fcmService.getToken();
});

/// Controller for FCM operations
final fcmControllerProvider = Provider<FcmController>((ref) {
  return FcmController(ref);
});

class FcmController {
  FcmController(this._ref);

  final Ref _ref;

  FcmService get _service => _ref.read(fcmServiceProvider);

  /// Get the current FCM token
  Future<String?> getToken() async {
    return await _service.getToken();
  }

  /// Subscribe to a notification topic
  Future<void> subscribeToTopic(String topic) async {
    await _service.subscribeToTopic(topic);
  }

  /// Unsubscribe from a notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _service.unsubscribeFromTopic(topic);
  }

  /// Refresh the FCM token provider
  void refreshToken() {
    _ref.invalidate(fcmTokenProvider);
  }
}

