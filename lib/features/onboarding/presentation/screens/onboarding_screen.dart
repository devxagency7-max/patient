import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/constants/app_strings.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/auth/presentation/screens/login_screen.dart';
import 'package:pharmacare/features/onboarding/data/models/onboarding_page_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmacare/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:pharmacare/features/onboarding/presentation/widgets/onboarding_dots_indicator.dart';

/// شاشة الـ Onboarding الرئيسية - 3 صفحات
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // بيانات الصفحات الثلاثة
  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      icon: Icons.favorite_outline_rounded,
      iconColor: Color(0xFF2F6BFF),
      titleAr: AppStrings.onboarding1TitleAr,
      titleEn: AppStrings.onboarding1TitleEn,
      descriptionAr: AppStrings.onboarding1DescAr,
      descriptionEn: AppStrings.onboarding1DescEn,
    ),
    OnboardingPageData(
      icon: Icons.notifications_none_rounded,
      iconColor: Color(0xFF00BFA6),
      titleAr: AppStrings.onboarding2TitleAr,
      titleEn: AppStrings.onboarding2TitleEn,
      descriptionAr: AppStrings.onboarding2DescAr,
      descriptionEn: AppStrings.onboarding2DescEn,
    ),
    OnboardingPageData(
      icon: Icons.shield_outlined,
      iconColor: Color(0xFF00C48C),
      titleAr: AppStrings.onboarding3TitleAr,
      titleEn: AppStrings.onboarding3TitleEn,
      descriptionAr: AppStrings.onboarding3DescAr,
      descriptionEn: AppStrings.onboarding3DescEn,
    ),
  ];

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onGetStarted() async {
    // حفظ حالة المشاهدة
    await sl<SharedPreferences>().setBool('isIntroSeen', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onSkip() {
    _onGetStarted();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // زر تخطي في أعلى اليمين
            // _buildSkipButton(),

            // صفحات الـ Onboarding
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(data: _pages[index]);
                },
              ),
            ),

            // مؤشر النقاط
            OnboardingDotsIndicator(
              currentPage: _currentPage,
              totalPages: _pages.length,
            ),

            const SizedBox(height: 32),

            // أزرار التنقل
            _buildNavigationButtons(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// زر تخطي
  // Widget _buildSkipButton() {
  //   return Align(
  //     alignment: Alignment.topRight,
  //     child: Padding(
  //       padding: const EdgeInsets.only(top: 16, right: 24),
  //       child: TextButton(
  //         onPressed: _onSkip,
  //         style: TextButton.styleFrom(
  //           foregroundColor: AppColors.textSecondary,
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //         ),
  //         child: Text(
  //           AppStrings.skip,
  //           style: GoogleFonts.cairo(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //             color: AppColors.textSecondary,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// أزرار التنقل (السابق / التالي / ابدأ الآن)
  Widget _buildNavigationButtons() {
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // زر السابق
          if (!isFirstPage)
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _goToPreviousPage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.cardBackground, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chevron_right, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.previous,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (!isFirstPage) const SizedBox(width: 16),

          // زر التالي / ابدأ الآن
          Expanded(
            flex: isFirstPage ? 1 : 1,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _goToNextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastPage ? AppStrings.getStarted : AppStrings.next,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (!isLastPage) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_left,
                        size: 22,
                        color: Colors.white,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
