import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pharmacare/features/auth/presentation/cubit/auth_state.dart';
import 'package:pharmacare/features/home/presentation/screens/main_shell_screen.dart';
import 'package:pharmacare/features/profile/presentation/screens/complete_profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.isNewUser) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainShellScreen()),
              (route) => false,
            );
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              _buildBackgroundMesh(),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FadeInRight(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: _buildHeader(),
                      ),
                      SizedBox(height: 30.h),
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: _buildRegisterForm(isLoading),
                      ),
                      SizedBox(height: 30.h),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildLoginLink(),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundMesh() {
    return Stack(
      children: [
        Positioned(
          top: -100.h,
          left: -100.w,
          child: _buildGradientBlob(color: const Color(0xFFB3E5FC).withOpacity(0.6), size: 500.r), // Icy Blue
        ),
        Positioned(
          bottom: -50.h,
          right: -50.w,
          child: _buildGradientBlob(color: const Color(0xFFFFE6DC).withOpacity(0.4), size: 450.r), // Soft Peach
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.white.withOpacity(0.3)),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientBlob({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 60)],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'إنشاء حساب جديد',
          style: GoogleFonts.cairo(
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
        ),
        Text(
          'انضم إلينا وابدأ رحلتك الصحية',
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildGlassTextField(
            controller: _nameController,
            hint: 'الاسم بالكامل',
            icon: Icons.person_outline_rounded,
          ),
          SizedBox(height: 15.h),
          _buildGlassTextField(
            controller: _emailController,
            hint: 'البريد الإلكتروني',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 15.h),
          _buildGlassTextField(
            controller: _phoneController,
            hint: 'رقم الهاتف (11 رقم)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'هذا الحقل مطلوب';
              if (val.trim().length != 11) return 'رقم الهاتف يجب أن يتكون من 11 رقم';
              return null;
            },
          ),
          SizedBox(height: 15.h),
          _buildGlassTextField(
            controller: _passwordController,
            hint: 'كلمة المرور',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
          ),
          SizedBox(height: 30.h),
          _buildPremiumButton(
            text: 'إنشاء حساب',
            onPressed: _onRegister,
            isLoading: isLoading,
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.textSecondary.withOpacity(0.2),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'أو التسجيل بواسطة',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.textSecondary.withOpacity(0.2),
                  thickness: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildGlassGoogleButton(
            onPressed: () {
              context.read<AuthCubit>().signInWithGoogle();
            },
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.cairo(color: AppColors.textSecondary.withOpacity(0.6)),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 22.r),
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            ),
            validator: validator ?? (val) => val == null || val.isEmpty ? 'هذا الحقل مطلوب' : null,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassGoogleButton({
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google.png',
                    height: 24.r,
                    width: 24.r,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'المتابعة باستخدام Google',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 60.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withBlue(255)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : Text(
                  text,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟',
          style: GoogleFonts.cairo(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'سجل دخولك',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
