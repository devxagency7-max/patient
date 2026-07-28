import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmacare/core/services/secure_storage_service.dart';
import 'package:pharmacare/features/devices/data/datasources/device_remote_datasource.dart';

/// Registers/unregisters this install's FCM token with the backend
/// (`POST/DELETE /api/v1/users/me/devices`). Invisible background task —
/// call [registerCurrentDevice] on login/app-start and [unregisterCurrentDevice]
/// on explicit logout.
class DevicePushService {
  final DeviceRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;
  final FirebaseMessaging _messaging;

  DevicePushService({
    required this.remoteDataSource,
    required this.secureStorage,
    FirebaseMessaging? messaging,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  bool _listeningForRefresh = false;

  String get _deviceType {
    if (kIsWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    return 'Unknown';
  }

  /// Requests notification permission (iOS/web no-op on Android <13 without
  /// runtime prompt handled by the OS), fetches the current FCM token, and
  /// upserts it server-side. Safe to call redundantly (cheap upsert).
  Future<void> registerCurrentDevice() async {
    try {
      await _messaging.requestPermission();

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      await _upsertToken(token);
      _listenForTokenRefresh();
    } catch (e) {
      debugPrint('⚠️ DevicePushService: failed to register device: $e');
    }
  }

  void _listenForTokenRefresh() {
    if (_listeningForRefresh) return;
    _listeningForRefresh = true;
    _messaging.onTokenRefresh.listen((newToken) {
      _upsertToken(newToken);
    });
  }

  Future<void> _upsertToken(String token) async {
    final deviceId = await remoteDataSource.registerDevice(
      deviceType: _deviceType,
      deviceName: kIsWeb ? null : Platform.operatingSystemVersion,
      fcmToken: token,
    );
    if (deviceId.isNotEmpty) {
      await secureStorage.saveDeviceId(deviceId);
    }
  }

  /// Deletes the server-side `UserDevice` row for this install so push
  /// notifications stop immediately, rather than relying on Firebase sign-out
  /// alone (which does not revoke the FCM token server-side).
  Future<void> unregisterCurrentDevice() async {
    final deviceId = await secureStorage.getDeviceId();
    if (deviceId == null || deviceId.isEmpty) return;
    try {
      await remoteDataSource.unregisterDevice(deviceId);
    } catch (e) {
      debugPrint('⚠️ DevicePushService: failed to unregister device: $e');
    } finally {
      await secureStorage.clearDeviceId();
    }
  }
}
