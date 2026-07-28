import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/emergency/data/services/nearby_hospitals_service.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_cubit.dart';
import 'package:pharmacare/features/patient_conditions/domain/entities/patient_condition_entity.dart';
import 'package:pharmacare/features/patient_conditions/presentation/cubit/patient_condition_cubit.dart';
import 'package:pharmacare/features/patient_conditions/presentation/cubit/patient_condition_state.dart';
import 'package:pharmacare/features/patient_conditions/presentation/screens/patient_conditions_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

/// بيانات جهة اتصال طوارئ (ديناميكية قابلة للتخزين والتحكم)
class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'relationship': relationship,
        'phone': phone,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
        name: json['name'] as String? ?? '',
        relationship: json['relationship'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
      );
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

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<PatientConditionCubit>()..fetchConditions()),
        BlocProvider(create: (context) => sl<HealthCubit>()..fetchHistory()),
      ],
      child: const _EmergencyView(),
    );
  }
}

class _EmergencyView extends StatefulWidget {
  const _EmergencyView();

  @override
  State<_EmergencyView> createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<_EmergencyView> {
  // أرقام الطوارئ المهمة
  final List<EmergencyNumber> _emergencyNumbers = const [
    EmergencyNumber(name: 'الإسعاف', number: '123', emoji: '🚑'),
    EmergencyNumber(name: 'الشرطة', number: '122', emoji: '🚔'),
    EmergencyNumber(name: 'الحماية المدنية', number: '180', emoji: '🚒'),
    EmergencyNumber(name: 'خط نجدة الطفل', number: '16000', emoji: '👶'),
  ];

  // جهات اتصال الطوارئ (ديناميكية بالكامل من SharedPreferences - بدون داتا ثابته في الكود)
  List<EmergencyContact> _contacts = [];

  // أقرب المستشفيات
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
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final prefs = sl<SharedPreferences>();
      final String? jsonStr = prefs.getString('emergency_contacts');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        if (mounted) {
          setState(() {
            _contacts = list
                .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
                .toList();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveEmergencyContacts() async {
    try {
      final prefs = sl<SharedPreferences>();
      final String jsonStr = jsonEncode(_contacts.map((c) => c.toJson()).toList());
      await prefs.setString('emergency_contacts', jsonStr);
    } catch (_) {}
  }

  Future<void> _loadNearbyHospitals({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoadingHospitals = true;
        _hospitalsError = null;
      });
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

  Future<void> _openInMaps(double lat, double lng, String name) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall(String number) async {
    final cleanNumber = number.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
      _showSnackBar('يرجى ملء جميع الحقول', isError: true);
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
    _saveEmergencyContacts();

    Navigator.of(context).pop();
    _showSnackBar('تمت إضافة جهة الاتصال بنجاح ✓');
  }

  void _deleteContact(int index) {
    final deletedName = _contacts[index].name;
    setState(() {
      _contacts.removeAt(index);
    });
    _saveEmergencyContacts();
    _showSnackBar('تم حذف جهة الاتصال ($deletedName) بنجاح');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? Colors.red.shade400 : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.w),
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
      backgroundColor: const Color(0xFFF0F5FF),
      body: Stack(
        children: [
          // Background Mesh
          Positioned(
            top: -100.h,
            right: -50.w,
            child: Container(
              width: 300.w,
              height: 300.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 100.h,
            left: -80.w,
            child: Container(
              width: 250.w,
              height: 250.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withOpacity(0.08),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),

          // Content
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(duration: const Duration(milliseconds: 500), child: _buildAlertCard()),
                      SizedBox(height: 24.h),

                      FadeInUp(duration: const Duration(milliseconds: 600), child: _buildSectionTitle('أرقام طوارئ مهمة')),
                      SizedBox(height: 12.h),
                      ...List.generate(_emergencyNumbers.length, (index) => 
                        FadeInUp(
                          duration: Duration(milliseconds: 600 + (index * 100)),
                          child: _buildEmergencyNumberCard(_emergencyNumbers[index]),
                        )
                      ),

                      SizedBox(height: 28.h),
                      FadeInUp(duration: const Duration(milliseconds: 700), child: _buildContactsSectionHeader()),
                      SizedBox(height: 12.h),
                      _buildContactsList(),

                      SizedBox(height: 28.h),
                      FadeInUp(duration: const Duration(milliseconds: 800), child: _buildHospitalsSectionHeader()),
                      SizedBox(height: 12.h),
                      _buildHospitalsSection(),

                      SizedBox(height: 28.h),
                      FadeInUp(duration: const Duration(milliseconds: 900), child: _buildSectionTitle('المعلومات الطبية الحية')),
                      SizedBox(height: 12.h),
                      FadeInUp(duration: const Duration(milliseconds: 900), child: _buildMedicalInfoCard()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات الطوارئ',
                        style: GoogleFonts.cairo(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Text(
                        'Emergency Information',
                        style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () => _makeCall('123'),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Pulse(infinite: true, child: Icon(Icons.phone, color: Colors.white, size: 24.sp)),
                      SizedBox(width: 12.w),
                      Column(
                        children: [
                          Text(
                            'اتصال طوارئ سريع',
                            style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          Text(
                            'الإسعاف - 123',
                            style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
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

  Widget _buildAlertCard() {  
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D4A),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24.sp),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنبيه مهم',
                  style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.amber),
                ),
                Text(
                  'في حالة الطوارئ، اتصل بالإسعاف فورًا على الرقم 123 أو توجه لأقرب مستشفى.',
                  style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.85), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A)),
    );
  }

  Widget _buildContactsSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'جهات اتصال الطوارئ',
          style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A)),
        ),
        GestureDetector(
          onTap: _showAddContactDialog,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2F6BFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.add_rounded, color: const Color(0xFF2F6BFF), size: 20.sp),
                SizedBox(width: 4.w),
                Text(
                  'إضافة جهة',
                  style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2F6BFF)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsList() {
    if (_contacts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Icon(Icons.person_add_disabled_rounded, color: const Color(0xFF8A94A6), size: 36.sp),
            SizedBox(height: 10.h),
            Text(
              'لا توجد جهات اتصال طوارئ مضافة حالياً.',
              style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E2D4A)),
            ),
            SizedBox(height: 4.h),
            Text(
              'اضغط على زر (+ إضافة جهة) بالأعلى لإضافة الأقارب أو الأطباء للطوارئ.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF8A94A6)),
            ),
          ],
        ),
      );
    }
    return Column(
      children: List.generate(
        _contacts.length,
        (index) => FadeInUp(
          duration: Duration(milliseconds: 700 + (index * 100)),
          child: _buildContactCard(_contacts[index], index),
        ),
      ),
    );
  }

  Widget _buildEmergencyNumberCard(EmergencyNumber item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: () => _makeCall(item.number),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            children: [
              Text(item.emoji, style: TextStyle(fontSize: 24.sp)),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  item.name,
                  style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E2D4A)),
                ),
              ),
              Text(
                item.number,
                style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.phone_rounded, color: AppColors.primary.withOpacity(0.6), size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFF2F6BFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.person_rounded, color: const Color(0xFF2F6BFF).withOpacity(0.7), size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E2D4A)),
                  ),
                  Text(
                    contact.relationship,
                    style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xFF8A94A6)),
                  ),
                  Text(
                    contact.phone,
                    style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2F6BFF)),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _deleteContact(index),
                  child: Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20.sp),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _makeCall(contact.phone),
                  child: Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primaryGreen, AppColors.primaryGreen.withOpacity(0.8)]),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Icon(Icons.phone_rounded, color: Colors.white, size: 20.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalsSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'أقرب المستشفيات',
          style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A)),
        ),
        GestureDetector(
          onTap: () => _loadNearbyHospitals(forceRefresh: true),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4757).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.refresh_rounded, color: const Color(0xFFFF4757), size: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalsSection() {
    if (_isLoadingHospitals) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4757))),
            SizedBox(height: 16.h),
            Text(
              'جاري البحث عن المستشفيات...',
              style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF8A94A6)),
            ),
          ],
        ),
      );
    }

    if (_hospitalsError != null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(14.r)),
        child: Column(
          children: [
            Icon(Icons.location_off_rounded, color: Colors.red.shade300, size: 40.sp),
            SizedBox(height: 12.h),
            Text(_hospitalsError!, textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 13.sp, color: Colors.red.shade400)),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: _loadNearbyHospitals,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('إعادة المحاولة', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    if (_hospitals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(14.r)),
        child: Text('لم يتم العثور على مستشفيات قريبة', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF8A94A6))),
      );
    }

    return Column(children: _hospitals.map(_buildHospitalCard).toList());
  }

  Widget _buildHospitalCard(NearbyHospitalResult hospital) {
    final distanceText = hospital.distanceKm < 1
        ? '${(hospital.distanceKm * 1000).toStringAsFixed(0)} م'
        : '${hospital.distanceKm.toStringAsFixed(1)} كم';

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: () => _openInMaps(hospital.lat, hospital.lng, hospital.name),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.local_hospital_rounded, color: const Color(0xFFFF4757), size: 24.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E2D4A)),
                    ),
                    Text(
                      hospital.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xFF8A94A6)),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 12.sp, color: const Color(0xFFFF4757)),
                        SizedBox(width: 4.w),
                        Text(distanceText, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFFFF4757))),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.directions_rounded, color: const Color(0xFF2F6BFF), size: 26.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalInfoCard() {
    return BlocBuilder<PatientConditionCubit, PatientConditionState>(
      builder: (context, state) {
        List<PatientConditionEntity> conditions = [];
        if (state is PatientConditionLoaded) {
          conditions = state.conditions;
        }

        final allergiesList = conditions
            .where((c) => c.type.toLowerCase() == 'allergy')
            .map((c) => c.name)
            .toList();

        final chronicList = conditions
            .where((c) => c.type.toLowerCase() == 'chronic' || c.type.toLowerCase() == 'chronicdisease')
            .map((c) => c.name)
            .toList();

        final String allergyText = allergiesList.isNotEmpty
            ? allergiesList.join('، ')
            : 'لا توجد حساسية مسجلة';

        final String chronicText = chronicList.isNotEmpty
            ? chronicList.join('، ')
            : 'لا توجد أمراض مزمنة مسجلة';

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'السجل الطبي للمريض',
                    style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PatientConditionsScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'تعديل الحالات',
                          style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2F6BFF)),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.edit_rounded, size: 14.sp, color: const Color(0xFF2F6BFF)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _medicalInfoItem(Icons.bloodtype_rounded, 'فصيلة الدم', 'O+', const Color(0xFFFF4757)),
              Divider(height: 24.h, color: const Color(0xFF2F6BFF).withOpacity(0.05)),
              _medicalInfoItem(Icons.warning_rounded, 'الحساسية', allergyText, Colors.orange),
              Divider(height: 24.h, color: const Color(0xFF2F6BFF).withOpacity(0.05)),
              _medicalInfoItem(Icons.history_edu_rounded, 'الأمراض المزمنة', chronicText, const Color(0xFF2F6BFF)),
            ],
          ),
        );
      },
    );
  }

  Widget _medicalInfoItem(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xFF8A94A6))),
              Text(value, style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E2D4A))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddContactSheet() {
    return Container(
      padding: EdgeInsets.all(24.w).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r))),
          SizedBox(height: 24.h),
          Text('إضافة جهة اتصال طوارئ', style: GoogleFonts.cairo(fontSize: 20.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A))),
          SizedBox(height: 24.h),
          _textField(_nameController, 'الاسم بالكامل', Icons.person_rounded),
          SizedBox(height: 16.h),
          _textField(_relationController, 'صلة القرابة', Icons.people_rounded),
          SizedBox(height: 16.h),
          _textField(_phoneController, 'رقم الهاتف', Icons.phone_rounded, isPhone: true),
          SizedBox(height: 32.h),
          GestureDetector(
            onTap: _addContact,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Center(child: Text('إضافة جهة الاتصال', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint, IconData icon, {bool isPhone = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF0F5FF), borderRadius: BorderRadius.circular(16.r)),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.cairo(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintTextDirection: TextDirection.rtl,
          prefixIcon: Icon(icon, color: const Color(0xFF2F6BFF), size: 20.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        ),
      ),
    );
  }
}
