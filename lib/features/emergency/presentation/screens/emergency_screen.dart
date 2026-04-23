import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/emergency/data/services/nearby_hospitals_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// بيانات جهة اتصال طوارئ
class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });
}

/// بيانات رقم طوارئ
class EmergencyNumber {
  final String name;
  final String number;
  final String emoji;

  const EmergencyNumber({
    required this.name,
    required this.number,
    required this.emoji,
  });
}

/// صفحة الطوارئ - Emergency Screen
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  // أرقام الطوارئ المهمة
  final List<EmergencyNumber> _emergencyNumbers = const [
    EmergencyNumber(name: 'الإسعاف', number: '123', emoji: '🚑'),
    EmergencyNumber(name: 'الشرطة', number: '122', emoji: '🚔'),
    EmergencyNumber(name: 'الحماية المدنية', number: '180', emoji: '🚒'),
    EmergencyNumber(name: 'خط نجدة الطفل', number: '16000', emoji: '👶'),
  ];

  // جهات اتصال الطوارئ
  final List<EmergencyContact> _contacts = [
    const EmergencyContact(
      name: 'د. محمد أحمد',
      relationship: 'الطبيب المعالج',
      phone: '+20 123 456 7890',
    ),
    const EmergencyContact(
      name: 'سارة محمد',
      relationship: 'الابنة',
      phone: '+20 100 123 4567',
    ),
  ];

  // أقرب المستشفيات (من Google Places API)
  List<NearbyHospitalResult> _hospitals = [];
  bool _isLoadingHospitals = true;
  String? _hospitalsError;

  // Controllers لإضافة جهة اتصال
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNearbyHospitals();
  }

  /// جلب أقرب المستشفيات من Google Places API (مع Cache)
  Future<void> _loadNearbyHospitals({bool forceRefresh = false}) async {
    try {
      // نعرض loading لو:
      // 1. أول مرة (مفيش بيانات)
      // 2. المستخدم ضغط زر التحديث (force refresh)
      if (_hospitals.isEmpty || forceRefresh) {
        setState(() {
          _isLoadingHospitals = true;
          _hospitalsError = null;
        });
      }
      final results = await NearbyHospitalsService.fetchNearbyHospitals(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _hospitals = results;
        _isLoadingHospitals = false;
        _hospitalsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hospitalsError = e.toString().replaceAll('Exception: ', '');
        _isLoadingHospitals = false;
      });
    }
  }

  /// فتح خرائط جوجل للتنقل
  Future<void> _openInMaps(double lat, double lng, String name) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// الاتصال بالرقم
  Future<void> _makeCall(String number) async {
    // تنظيف الرقم من المسافات
    final cleanNumber = number.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// إضافة جهة اتصال جديدة
  void _showAddContactDialog() {
    _nameController.clear();
    _phoneController.clear();
    _relationController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddContactSheet(),
    );
  }

  void _addContact() {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _relationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى ملء جميع الحقول',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _contacts.add(
        EmergencyContact(
          name: _nameController.text.trim(),
          relationship: _relationController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      );
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت إضافة جهة الاتصال بنجاح ✓',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF00C48C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // تنبيه مهم
                  _buildAlertCard(),
                  const SizedBox(height: 24),

                  // 1- أرقام طوارئ مهمة
                  _buildSectionTitle('أرقام طوارئ مهمة'),
                  const SizedBox(height: 12),
                  ..._emergencyNumbers.map(_buildEmergencyNumberCard),

                  const SizedBox(height: 28),

                  // 2- جهات اتصال الطوارئ
                  _buildContactsSectionHeader(),
                  const SizedBox(height: 12),
                  ..._contacts.map(_buildContactCard),

                  const SizedBox(height: 28),

                  // 3- أقرب المستشفيات
                  _buildHospitalsSectionHeader(),
                  const SizedBox(height: 12),
                  _buildHospitalsSection(),

                  const SizedBox(height: 28),

                  // 4- المعلومات الطبية
                  _buildSectionTitle('المعلومات الطبية'),
                  const SizedBox(height: 12),
                  _buildMedicalInfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// الهيدر + زر اتصال طوارئ سريع
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF4757), Color(0xFFFF6B81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              // العنوان
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات الطوارئ',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Emergency Information',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // زر اتصال طوارئ سريع
              GestureDetector(
                onTap: () => _makeCall('123'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Text(
                            'اتصال طوارئ سريع',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'الإسعاف - 123',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// كارد التنبيه
  Widget _buildAlertCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D4A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنبيه مهم',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber,
                  ),
                ),
                Text(
                  'في حالة الطوارئ، اتصل بالإسعاف فورًا على الرقم 123 أو توجه لأقرب مستشفى.',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// عنوان قسم جهات الاتصال + زر إضافة
  Widget _buildContactsSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'جهات اتصال الطوارئ',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: _showAddContactDialog,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────── أرقام الطوارئ ─────────────────

  Widget _buildEmergencyNumberCard(EmergencyNumber item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _makeCall(item.number),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji
              Text(item.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              // الاسم
              Expanded(
                child: Text(
                  item.name,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // الرقم
              Text(
                item.number,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF4757),
                ),
              ),
              const SizedBox(width: 8),
              // أيقونة الاتصال
              Icon(
                Icons.phone_outlined,
                color: const Color(0xFFFF4757).withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── جهات الاتصال ─────────────────

  Widget _buildContactCard(EmergencyContact contact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // أيقونة الشخص
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // البيانات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    contact.relationship,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    contact.phone,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // زر الاتصال
            GestureDetector(
              onTap: () => _makeCall(contact.phone),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C48C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── أقرب المستشفيات (Google Places API) ─────────────────

  /// عنوان قسم المستشفيات + زر تحديث
  Widget _buildHospitalsSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'أقرب المستشفيات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _loadNearbyHospitals(forceRefresh: true),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4757).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFFFF4757),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalsSection() {
    if (_isLoadingHospitals) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'جاري تحديد موقعك والبحث عن المستشفيات...',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_hospitalsError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.location_off_rounded,
              color: Colors.red.shade300,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              _hospitalsError!,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _loadNearbyHospitals,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_hospitals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'لم يتم العثور على مستشفيات قريبة',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(children: _hospitals.map(_buildHospitalCard).toList());
  }

  Widget _buildHospitalCard(NearbyHospitalResult hospital) {
    final distanceText = hospital.distanceKm < 1
        ? '${(hospital.distanceKm * 1000).toStringAsFixed(0)} م'
        : '${hospital.distanceKm.toStringAsFixed(1)} كم';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _openInMaps(hospital.lat, hospital.lng, hospital.name),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // أيقونة المستشفى
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Color(0xFFFF4757),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            hospital.address,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          distanceText,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        if (hospital.rating != null) ...[
                          const SizedBox(width: 10),
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            hospital.rating!.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // زر الاتجاهات
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.directions_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── المعلومات الطبية ─────────────────

  Widget _buildMedicalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _medicalInfoRow('فصيلة الدم:', 'O+'),
          Divider(color: Colors.grey.withValues(alpha: 0.1), height: 20),
          _medicalInfoRow('الحساسية:', 'بنسلين، فول سوداني'),
          Divider(color: Colors.grey.withValues(alpha: 0.1), height: 20),
          _medicalInfoRow('الأمراض المزمنة:', 'السكري، ارتفاع ضغط الدم'),
          Divider(color: Colors.grey.withValues(alpha: 0.1), height: 20),
          _medicalInfoRow('الأدوية الحالية:', 'أسبرين، ميتفورمين'),
        ],
      ),
    );
  }

  Widget _medicalInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ───────────────── Bottom Sheet إضافة جهة اتصال ─────────────────

  Widget _buildAddContactSheet() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // المقبض
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'إضافة جهة اتصال طوارئ',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // حقل الاسم
            _sheetTextField(
              controller: _nameController,
              label: 'الاسم',
              hint: 'مثال: أحمد محمد',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 14),
            // حقل صلة القرابة
            _sheetTextField(
              controller: _relationController,
              label: 'صلة القرابة',
              hint: 'مثال: الابن، الأخ، الطبيب',
              icon: Icons.family_restroom_rounded,
            ),
            const SizedBox(height: 14),
            // حقل رقم الهاتف
            _sheetTextField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              hint: '+20 xxx xxx xxxx',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            // زر الإضافة
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _addContact,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  'إضافة جهة الاتصال',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            hintStyle: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
