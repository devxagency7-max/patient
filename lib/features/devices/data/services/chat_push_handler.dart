import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pharmacare/core/services/local_notifications_service.dart';
import 'package:pharmacare/features/home/presentation/controllers/home_controller.dart';

/// Must be a top-level (or static) function per the firebase_messaging
/// contract — the OS may invoke it in a separate isolate while the app is
/// fully backgrounded/terminated. Nothing to do here yet: FCM itself already
/// renders the system notification for a data+notification payload when the
/// app isn't running; this hook exists for cases where we'd need to react to
/// a data-only payload in the background (e.g. silently updating local
/// state), which we don't do today.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Shows a local notification for chat push messages that arrive while the
/// app is in the foreground (FCM does not auto-display those — only
/// background/terminated notifications get the OS tray treatment
/// automatically), and deep-links a tap on a background/terminated
/// notification straight to the pharmacist conversation.
///
/// Payload shape (confirmed with backend): `{type, referenceId,
/// referenceType}` — `referenceId`/`referenceType` are generic across all
/// notification kinds (Order, Conversation, MedicationPlan...), not chat
/// specific, and are omitted entirely (not empty strings) when absent. We
/// don't even need `referenceId`'s value here — a patient has at most one
/// active pharmacist conversation, so ChatScreen() with no pharmacistId
/// already resolves it via ChatCubit.connectAndLoadHistory (looks up the
/// Active assignment's conversationId from GET /patients/my-requests).
class ChatPushHandler {
  final LocalNotificationsService _localNotifications;
  final GlobalKey<NavigatorState> _navigatorKey;
  final NavigationCubit _navigationCubit;

  /// Index of the chat tab inside MainShellScreen's IndexedStack (see
  /// main_shell_screen.dart's `pages` list: Home, Reminders, Order, Chat,
  /// Profile).
  static const _chatTabIndex = 3;

  ChatPushHandler(
    this._localNotifications,
    this._navigatorKey,
    this._navigationCubit,
  );

  Future<void> init() async {
    await _localNotifications.init();
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _localNotifications.showNotification(
      id: message.hashCode,
      title: notification.title ?? 'رسالة جديدة',
      body: notification.body ?? '',
    );
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    final data = message.data;
    if (data['type'] != 'ChatMessage' || data['referenceType'] != 'Conversation') {
      return;
    }
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;
    // ChatScreen already lives permanently inside MainShellScreen's
    // IndexedStack (see main_shell_screen.dart) — it is never absent, only
    // hidden behind another tab. Pushing a second ChatScreen route on top
    // used to spin up a second ChatCubit subscribed to the same singleton
    // ChatSignalRService, so every incoming message got delivered — and
    // rendered — twice. The correct action is to pop back to the shell and
    // switch to the existing chat tab instead of creating a new screen.
    navigator.popUntil((route) => route.isFirst);
    _navigationCubit.setIndex(_chatTabIndex);
  }
}
