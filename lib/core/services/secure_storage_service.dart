import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// خدمة التخزين الآمن للبيانات الحساسة.
///
/// ملاحظة: الـ Backend يعتمد Firebase ID tokens فقط (لا JWT من السيرفر ولا
/// refresh token)، لذا لا نخزّن التوكنات هنا — الجلسة مصدرها Firebase SDK.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  static const _userIdKey = 'user_id';
  static const _deviceIdKey = 'push_device_id';

  // ===== User ID =====

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // ===== Push Device ID (server-side UserDevice row for this install) =====

  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: _deviceIdKey, value: deviceId);
  }

  Future<String?> getDeviceId() async {
    return await _storage.read(key: _deviceIdKey);
  }

  Future<void> clearDeviceId() async {
    await _storage.delete(key: _deviceIdKey);
  }

  // ===== مسح كل البيانات (عند الـ Logout) =====

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
