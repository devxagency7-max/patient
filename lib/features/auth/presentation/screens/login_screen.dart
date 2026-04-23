import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_assets.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/widgets/custom_button.dart';
import 'package:pharmacare/core/widgets/custom_text_field.dart';
import 'package:pharmacare/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pharmacare/features/home/presentation/screens/main_shell_screen.dart';

/// صفحة تسجيل الدخول - Login Screen
/// الآن مفصولة تماماً عن الـ Logic!
/// UI → AuthController → LoginUseCase → AuthRepository → DataSource
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// تسجيل الدخول — يستدعي الـ Controller فقط!
  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _onForgotPassword() {
    // TODO: صفحة نسيت كلمة المرور
  }

  void _onSignUp() {
    // TODO: صفحة إنشاء حساب جديد
  }

  @override
  Widget build(BuildContext context) {
    // الاستماع لتغيرات الـ AuthState
    ref.listen<AuthState>(authControllerProvider, (previous, current) {
      if (current is AuthAuthenticated) {
        // نجاح → انتقل للصفحة الرئيسية
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainShellScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false,
        );
      } else if (current is AuthError) {
        // خطأ → أظهر رسالة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              current.message,
              style: GoogleFonts.cairo(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });

    // هل جاري التحميل؟
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildWelcomeHeader(),
                  const SizedBox(height: 40),
                  _buildLoginForm(),
                  const SizedBox(height: 16),
                  _buildRememberAndForgot(),
                  const SizedBox(height: 32),

                  // زر تسجيل الدخول — isLoading من الـ AuthState
                  CustomButton(
                    text: 'تسجيل الدخول',
                    onPressed: _onLogin,
                    isLoading: isLoading,
                    icon: Icons.login_rounded,
                  ),

                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'المتابعة بحساب Google',
                    onPressed: () {
                      // TODO: Google Sign-In
                    },
                    isOutlined: true,
                    icon: Icons.g_mobiledata_rounded,
                  ),

                  const SizedBox(height: 32),
                  _buildSignUpLink(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        Text(
          'مرحبًا بعودتك!',
          style: GoogleFonts.cairo(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome Back!',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'سجّل دخولك للوصول إلى حسابك الصحي',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'البريد الإلكتروني',
            hint: 'example@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال البريد الإلكتروني';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'يرجى إدخال بريد إلكتروني صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'كلمة المرور',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            controller: _passwordController,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              if (value.length < 6) {
                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() => _rememberMe = value ?? false);
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'تذكرني',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: _onForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'نسيت كلمة المرور؟',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.cardBackground)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.cardBackground)),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _onSignUp,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(right: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'أنشئ حساب جديد',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
