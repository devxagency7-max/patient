import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pharmacare/features/auth/presentation/cubit/auth_state.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';
import 'package:pharmacare/features/auth/presentation/screens/login_screen.dart';
import 'package:pharmacare/features/profile/presentation/screens/address_book_screen.dart';
import 'package:pharmacare/features/pharmacist/presentation/screens/pharmacist_directory_screen.dart';
import 'package:pharmacare/features/medical_records/presentation/screens/medical_records_screen.dart';
import 'package:pharmacare/features/patient_conditions/presentation/screens/patient_conditions_screen.dart';
import 'package:pharmacare/features/reminders/presentation/screens/adherence_screen.dart';
import 'package:pharmacare/features/pharmacist/presentation/screens/my_requests_screen.dart';
import 'package:pharmacare/features/prescription/presentation/screens/my_prescriptions_screen.dart';
import 'package:pharmacare/features/pharmacy/presentation/screens/my_orders_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// صفحة الملف الطبي - Profile / Medical Profile Screen بنمط زجاجي فاخر
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FC),
        body: Stack(
          children: [
            _buildMeshBackground(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(context),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                SliverToBoxAdapter(child: _buildMenuList(context)),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                SliverToBoxAdapter(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                    child: _buildHealthSummary(),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 110.h)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// خلفية الميش المتدرجة - Mesh Background
  Widget _buildMeshBackground() {
    return Stack(
      children: [
        Positioned(
          top: -80.h,
          right: -50.w,
          child: Container(
            width: 350.r,
            height: 350.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5A97DF).withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          top: 320.h,
          left: -100.w,
          child: Container(
            width: 380.r,
            height: 380.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF08C75A).withOpacity(0.06),
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  /// الهيدر الزجاجي المرن القابل للانكماش - Collapsible SliverAppBar
  Widget _buildSliverHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        UserEntity? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }
        final fbUser = FirebaseAuth.instance.currentUser;

        String displayName = 'المستخدم';
        if (user?.name != null && user!.name.isNotEmpty) {
          displayName = user.name;
        } else if (fbUser?.displayName != null && fbUser!.displayName!.isNotEmpty) {
          displayName = fbUser.displayName!;
        }

        String displayEmail = '---';
        if (user?.email != null && user!.email.isNotEmpty) {
          displayEmail = user.email;
        } else if (fbUser?.email != null && fbUser!.email!.isNotEmpty) {
          displayEmail = fbUser.email!;
        }

        String? photoUrl;
        if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
          photoUrl = user.avatarUrl;
        } else if (fbUser?.photoURL != null && fbUser!.photoURL!.isNotEmpty) {
          photoUrl = fbUser.photoURL;
        }

        String ageDisplay = 'غير معروف';
        if (user?.dateOfBirth != null && user!.dateOfBirth!.isNotEmpty) {
          try {
            final birthDate = DateTime.parse(user.dateOfBirth!);
            final now = DateTime.now();
            int age = now.year - birthDate.year;
            if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
              age--;
            }
            ageDisplay = '$age سنة';
          } catch (e) {
            debugPrint('Error parsing date: $e');
          }
        }

        return SliverAppBar(
          pinned: true,
          expandedHeight: 330.h,
          toolbarHeight: 64.h,
          backgroundColor: const Color(0xFFF4F7FC).withOpacity(0.95),
          elevation: 0,
          scrolledUnderElevation: 2,
          shadowColor: Colors.black.withOpacity(0.04),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(18.r)),
          ),
          automaticallyImplyLeading: false,
          titleSpacing: 20.w,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(Icons.settings_outlined, color: const Color(0xFF64748B), size: 22.sp),
              ),
              Text(
                'الملف الطبي',
                style: GoogleFonts.cairo(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF5FC),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFF5A97DF).withOpacity(0.2)),
                ),
                child: Icon(Icons.edit_note_rounded, color: const Color(0xFF5A97DF), size: 24.sp),
              ),
            ],
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 64.h, 20.w, 16.h),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 96.r,
                            height: 96.r,
                            padding: EdgeInsets.all(3.r),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF5A97DF), Color(0xFF08C75A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: photoUrl != null && photoUrl.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.person_rounded, size: 52.sp, color: const Color(0xFFCBD5E1)),
                                      ),
                                    )
                                  : Icon(Icons.person_rounded, size: 52.sp, color: const Color(0xFFCBD5E1)),
                            ),
                          ),
                          Positioned(
                            bottom: 2.h,
                            right: 6.w,
                            child: Container(
                              padding: EdgeInsets.all(5.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFF08C75A),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 10),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        displayName,
                        style: GoogleFonts.cairo(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        displayEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildInfoRow(user, ageDisplay),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(UserEntity? user, String ageDisplay) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _infoItem(
            'ID',
            (user?.id != null && user!.id.isNotEmpty)
                ? user.id.substring(0, user.id.length < 6 ? user.id.length : 6).toUpperCase()
                : 'N/A',
            Icons.fingerprint_rounded,
            const Color(0xFF5A97DF),
          ),
          _divider(),
          _infoItem(
            'العمر', 
            ageDisplay,
            Icons.cake_rounded,
            const Color(0xFF08C75A),
          ),
          _divider(),
          _infoItem(
            'النوع', 
            user?.gender == 'Male' ? 'ذكر' : 'أنثى',
            user?.gender == 'Male' ? Icons.male_rounded : Icons.female_rounded,
            const Color(0xFFFF4757),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 28.h, color: const Color(0xFFE2E8F0));

  Widget _infoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  /// قائمة القوائم الزجاجية
  Widget _buildMenuList(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.assignment_rounded,
        color: const Color(0xFF5A97DF),
        titleAr: 'السجل الطبي',
        titleEn: 'Medical History',
        screenBuilder: (_) => const MedicalRecordsScreen(),
      ),
      _MenuItem(
        icon: Icons.favorite_rounded,
        color: const Color(0xFFFF4757),
        titleAr: 'الأمراض المزمنة',
        titleEn: 'Chronic Diseases',
        screenBuilder: (_) => const PatientConditionsScreen(),
      ),
      _MenuItem(
        icon: Icons.warning_rounded,
        color: const Color(0xFFFF9F43),
        titleAr: 'الحساسية',
        titleEn: 'Allergies',
        screenBuilder: (_) => const PatientConditionsScreen(),
      ),
      _MenuItem(icon: Icons.location_on_rounded, color: const Color(0xFF5A97DF), titleAr: 'العناوين المحفوظة', titleEn: 'Saved Addresses', isAddressBook: true),
      _MenuItem(icon: Icons.medical_services_outlined, color: const Color(0xFF08C75A), titleAr: 'طلب صيدلي رعاية', titleEn: 'Care Pharmacist', isPharmacistDirectory: true),
      _MenuItem(
        icon: Icons.groups_rounded,
        color: const Color(0xFF08C75A),
        titleAr: 'طلبات الرعاية',
        titleEn: 'My Care Requests',
        screenBuilder: (_) => const MyRequestsScreen(),
      ),
      _MenuItem(
        icon: Icons.shopping_bag_rounded,
        color: const Color(0xFF5A97DF),
        titleAr: 'طلباتي ومتابعة الحالة',
        titleEn: 'My Orders & Tracking',
        screenBuilder: (_) => const MyOrdersScreen(),
      ),
      _MenuItem(
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF5A97DF),
        titleAr: 'روشتاتي',
        titleEn: 'My Prescriptions',
        screenBuilder: (_) => const MyPrescriptionsScreen(),
      ),
      _MenuItem(icon: Icons.medication_rounded, color: const Color(0xFF5A97DF), titleAr: 'قائمة الأدوية', titleEn: 'Medications'),
      _MenuItem(
        icon: Icons.show_chart_rounded,
        color: const Color(0xFF08C75A),
        titleAr: 'الالتزام الدوائي',
        titleEn: 'Medication Adherence',
        screenBuilder: (_) => const AdherenceScreen(),
      ),
      _MenuItem(icon: Icons.logout_rounded, color: const Color(0xFFFF4757), titleAr: 'تسجيل الخروج', titleEn: 'Logout', isLogout: true),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: List.generate(menuItems.length, (index) => 
          FadeInUp(
            duration: const Duration(milliseconds: 350),
            delay: Duration(milliseconds: 50 + (index * 30)),
            child: _buildMenuItem(context, menuItems[index]),
          )
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          if (item.isLogout) {
            _showLogoutDialog(context);
          } else if (item.isAddressBook) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddressBookScreen()),
            );
          } else if (item.isPharmacistDirectory) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PharmacistDirectoryScreen()),
            );
          } else if (item.screenBuilder != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: item.screenBuilder!),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(item.icon, color: item.color, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titleAr,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      item.titleEn,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  /// ملخص صحي بتصميم عصري
  Widget _buildHealthSummary() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            child: Text(
              'الملخص الصحي',
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5A97DF), Color(0xFF08C75A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5A97DF).withOpacity(0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _healthStatTile(Icons.bloodtype_rounded, 'فصيلة الدم', 'O+', const Color(0xFFFF4757)),
                    _vDivider(),
                    _healthStatTile(Icons.height_rounded, 'الطول', '175 سم', Colors.white),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Divider(color: Colors.white.withOpacity(0.15), thickness: 1),
                ),
                Row(
                  children: [
                    _healthStatTile(Icons.monitor_weight_rounded, 'الوزن', '75 كجم', const Color(0xFF38BDF8)),
                    _vDivider(),
                    _healthStatTile(Icons.speed_rounded, 'BMI', '24.5', const Color(0xFFFBBF24)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 36.h, color: Colors.white.withOpacity(0.2));

  Widget _healthStatTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 10.sp,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'تسجيل الخروج',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
            style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthCubit>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4757),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text(
                'خروج',
                style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color color;
  final String titleAr;
  final String titleEn;
  final bool isLogout;
  final bool isAddressBook;
  final bool isPharmacistDirectory;
  final WidgetBuilder? screenBuilder;
  const _MenuItem({
    required this.icon,
    required this.color,
    required this.titleAr,
    required this.titleEn,
    this.isLogout = false,
    this.isAddressBook = false,
    this.isPharmacistDirectory = false,
    this.screenBuilder,
  });
}

