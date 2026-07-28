import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// بيانات مستشفى قريبة
class NearbyHospitalResult {
  final String name;
  final String address;
  final double distanceKm;
  final double lat;
  final double lng;
  final double? rating;

  const NearbyHospitalResult({
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.lat,
    required this.lng,
    this.rating,
  });
}

/// خدمة البحث عن المستشفيات القريبة عبر Google Places API
/// مع نظام Cache ذكي يتجنب استدعاءات API متكررة
class NearbyHospitalsService {
  static String get _apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  // ───────────── Cache ─────────────
  static List<NearbyHospitalResult>? _cachedHospitals;
  static DateTime? _cacheTimestamp;
  static Position? _cachedPosition;

  /// مدة صلاحية الكاش (5 دقايق)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// هل الكاش لسه صالح؟
  static bool get _isCacheValid {
    if (_cachedHospitals == null ||
        _cacheTimestamp == null ||
        _cachedPosition == null) {
      return false;
    }
    // تحقق من انتهاء الوقت
    final elapsed = DateTime.now().difference(_cacheTimestamp!);
    if (elapsed > _cacheDuration) {
      return false;
    }
    return true;
  }

  /// مسح الكاش يدوياً
  static void clearCache() {
    _cachedHospitals = null;
    _cacheTimestamp = null;
    _cachedPosition = null;
  }

  // ───────────── Location ─────────────

  /// التحقق من صلاحيات الموقع وتفعيلها
  static Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمة الموقع غير مفعلة. يرجى تفعيل GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض صلاحية الموقع.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'صلاحية الموقع مرفوضة بشكل دائم. يرجى تفعيلها من الإعدادات.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// حساب المسافة بين نقطتين (بالكيلومتر)
  static double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final distanceInMeters = Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
    return distanceInMeters / 1000;
  }

  // ───────────── API ─────────────

  /// جلب أقرب 7 مستشفيات — يستخدم الكاش أولاً
  /// لو الكاش صالح → يرجع النتايج المخزنة فوراً بدون أي انتظار
  /// لو الكاش مش صالح → يستدعي GPS + API جديد
  static Future<List<NearbyHospitalResult>> fetchNearbyHospitals({
    bool forceRefresh = false,
  }) async {
    // ⚡ 1. تحقق من الكاش أولاً (قبل GPS!)
    //    لو الكاش صالح ومش force refresh → نرجع فوراً بدون أي انتظار
    if (!forceRefresh && _isCacheValid) {
      return _cachedHospitals!;
    }

    // 2. الكاش مش صالح → نحتاج GPS + API
    final position = await _getCurrentPosition();

    // 3. استدعاء Google Places API - Nearby Search
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${position.latitude},${position.longitude}'
      '&radius=10000'
      '&type=hospital'
      '&language=ar'
      '&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('فشل الاتصال بخدمة البحث. كود: ${response.statusCode}');
    }

    final data = json.decode(response.body);

    if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      throw Exception('خطأ في API: ${data['status']}');
    }

    final results = data['results'] as List<dynamic>? ?? [];

    // 4. تحويل النتائج وحساب المسافة
    final hospitals = results.map<NearbyHospitalResult>((place) {
      final location = place['geometry']['location'];
      final lat = (location['lat'] as num).toDouble();
      final lng = (location['lng'] as num).toDouble();
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );

      return NearbyHospitalResult(
        name: place['name'] ?? 'مستشفى',
        address: place['vicinity'] ?? 'عنوان غير متوفر',
        distanceKm: distance,
        lat: lat,
        lng: lng,
        rating: (place['rating'] as num?)?.toDouble(),
      );
    }).toList();

    // 5. ترتيب حسب المسافة وأخذ أقرب 7
    hospitals.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    final topHospitals = hospitals.take(7).toList();

    // 6. تخزين في الكاش
    _cachedHospitals = topHospitals;
    _cacheTimestamp = DateTime.now();
    _cachedPosition = position;

    return topHospitals;
  }
}
