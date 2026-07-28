import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmacare/features/telemetry/data/datasources/telemetry_remote_datasource.dart';

/// Lightweight engagement tracking (`POST /api/v1/users/telemetry`).
/// Rate-limited server-side to 10 requests / 10 seconds, so the heartbeat
/// must not fire faster than once per minute.
class TelemetryService {
  final TelemetryRemoteDataSource remoteDataSource;

  TelemetryService({required this.remoteDataSource});

  Timer? _heartbeatTimer;

  /// Starts a 60-second foreground heartbeat. Call when the app becomes
  /// active (e.g. `MainShellScreen.initState`); call [stopHeartbeat] when it
  /// goes to background/is disposed.
  void startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _send(feature: 'heartbeat');
    });
  }

  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Fire a one-off analytics event (e.g. `"opened_medicine_detail"`).
  Future<void> logEvent(String feature, {String? details}) {
    return _send(feature: feature, details: details);
  }

  Future<void> _send({required String feature, String? details}) async {
    try {
      await remoteDataSource.sendTelemetry(feature: feature, details: details);
    } catch (e) {
      debugPrint('⚠️ TelemetryService: failed to send "$feature": $e');
    }
  }
}
