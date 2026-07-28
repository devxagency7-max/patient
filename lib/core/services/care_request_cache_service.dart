import 'package:shared_preferences/shared_preferences.dart';

/// يخزّن آخر حالة معروفة لوجود طلب رعاية صيدلي (Active/Pending) محلياً،
/// لمنع اختفاء/ظهور بانر الرعاية بشكل مفاجئ أثناء إعادة تحميل البيانات.
class CareRequestCacheService {
  final SharedPreferences _prefs;

  CareRequestCacheService(this._prefs);

  static const _hasActiveOrPendingKey = 'care_request_has_active_or_pending';

  bool getHasActiveOrPending() {
    return _prefs.getBool(_hasActiveOrPendingKey) ?? false;
  }

  Future<void> setHasActiveOrPending(bool value) async {
    await _prefs.setBool(_hasActiveOrPendingKey, value);
  }
}
