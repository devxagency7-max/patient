import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/auth/presentation/screens/login_screen.dart';
import 'package:pharmacare/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pharmacare/features/home/presentation/screens/main_shell_screen.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  void _startSplashSequence() async {
    final prefs = sl<SharedPreferences>();
    final bool isIntroSeen = prefs.getBool('isIntroSeen') ?? false;

    // Session source of truth is Firebase, NOT a cached (expirable) token.
    // Validate by forcing a fresh ID token — if Firebase can mint one, the
    // account still exists and the session is live.
    final bool isSignedIn = await _resolveSignedIn();

    // Minimum delay for splash aesthetic.
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (isSignedIn) {
      _navigateTo(const MainShellScreen());
    } else if (isIntroSeen) {
      _navigateTo(const LoginScreen());
    } else {
      _navigateTo(const OnboardingScreen());
    }
  }

  /// Returns true only if there's a Firebase user whose token can be refreshed
  /// (i.e. the account wasn't deleted/disabled server-side).
  Future<bool> _resolveSignedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final token = await user.getIdToken(true);
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('⚠️ Splash: token refresh failed, treating as signed-out: $e');
      return false;
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Mesh
          _buildBackgroundMesh(),
          
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with Simple Animation
                FadeInDown(
                  duration: const Duration(milliseconds: 1000),
                  child: Image.asset(
                    'assets/images/logo_icon_app-removebg-preview.png',
                    width: 160.r,
                    height: 160.r,
                  ),
                ),
                SizedBox(height: 40.h),
                
                // Loading Indicator
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 500),
                  child: _buildLoadingDots(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundMesh() {
    return Stack(
      children: [
        Positioned(
          top: -100.h,
          left: -100.w,
          child: _buildGradientBlob(color: AppColors.primary.withOpacity(0.12), size: 450.r), // Sky Blue
        ),
        Positioned(
          bottom: -50.h,
          right: -50.w,
          child: _buildGradientBlob(color: AppColors.primaryGreen.withOpacity(0.08), size: 400.r), // Mint Green
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(
              color: AppColors.primaryLight.withOpacity(0.4),
            ),
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
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return FadeIn(
          delay: Duration(milliseconds: 200 * index),
          duration: const Duration(milliseconds: 1000),
          animate: true,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.4 + (index * 0.2)),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
