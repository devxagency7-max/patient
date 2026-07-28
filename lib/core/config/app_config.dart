import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized runtime configuration sourced from `.env`.
///
/// All network hosts live here so there is a single place to flip
/// http → https (see [_host]) and no hardcoded IPs scattered across
/// datasources. Loaded after `dotenv.load()` in `main()`.
class AppConfig {
  AppConfig._();

  /// Backend host without a trailing slash, e.g. `https://api.tamenny.com`.
  ///
  /// Falls back to the legacy cleartext placeholder only if `.env` is missing
  /// the key, so a misconfigured build fails loudly in logs rather than
  /// silently pointing nowhere.
  static String get _host {
    final raw = dotenv.env['API_HOST']?.trim();
    if (raw == null || raw.isEmpty) {
      // Placeholder — MUST be overridden by .env with an https:// host.
      return 'http://204.168.149.185';
    }
    // Normalize away any accidental trailing slash.
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  /// Dio base URL — the versioned API root (trailing slash required by Dio
  /// so relative paths like `users/sync` resolve correctly).
  static String get apiBaseUrl => '$_host/api/v1/';

  /// File uploads live under `/api/files` (NO `/v1` — per backend routing).
  static String get fileUploadUrl => '$_host/api/files/upload';

  /// SignalR chat hub (root, no `/api` prefix).
  static String get chatHubUrl => '$_host/hubs/chat';

  /// True when talking to a non-TLS host — used to gate/annotate dev behavior.
  static bool get isCleartext => _host.startsWith('http://');
}
