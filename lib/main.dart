import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmacare/app/theme/app_theme.dart';
import 'package:pharmacare/core/config/app_config.dart';
import 'package:pharmacare/features/splash/presentation/screens/splash_screen.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pharmacare/features/home/presentation/controllers/home_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pharmacare/features/devices/data/services/chat_push_handler.dart';
import 'package:pharmacare/firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ⚠️ مهم لو مستخدم FlutterFire CLI

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // شكل الـ status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // ملف البيئة (يحتوي API_HOST والمفاتيح). غيابه لا يجب أن يُسقط التطبيق.
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('⚠️ main: failed to load .env, using defaults: $e');
  }

  if (AppConfig.isCleartext) {
    debugPrint(
      '🚨 SECURITY WARNING: API_HOST is using cleartext HTTP. '
      'Bearer tokens and all traffic are sent unencrypted. '
      'This MUST be switched to https:// before any release build.',
    );
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    // تهيئة الاعتماديات بعد Firebase مباشرة.
    await initDi();
    await sl<ChatPushHandler>().init();
  } catch (e, st) {
    debugPrint('❌ main: fatal init failure: $e\n$st');
    runApp(const _StartupErrorApp());
    return;
  }

  runApp(const MyAppWrapper());
}

/// شاشة بديلة تظهر بدل الشاشة البيضاء لو فشلت التهيئة الأساسية.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'تعذّر تشغيل التطبيق. من فضلك أعد المحاولة لاحقاً.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ فصل الـ BlocProvider (أنضف وأأمن)
class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()),
        BlocProvider(create: (_) => sl<NavigationCubit>()),
      ],
      child: const PharmaCareApp(),
    );
  }
}


class PharmaCareApp extends StatelessWidget {
  const PharmaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard iPhone size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: sl<GlobalKey<NavigatorState>>(),
          title: 'طمني',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: const Locale('ar', 'EG'),
          supportedLocales: const [
            Locale('ar', 'EG'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}
