import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  // التأكد من تهيئة بيئة فلاتر قبل تشغيل أي كود غير متزامن
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة فايربيس باستخدام الإعدادات التي تم توليدها مسبقاً
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تشغيل التطبيق وتغليفه بـ ProviderScope لكي تعمل إدارة الحالة (Riverpod)
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'على عيني',
      debugShowCheckedModeBanner: false, // إخفاء شريط الـ Debug المزعج
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // يتكيف مع وضع الجهاز (فاتح/داكن)
      // إجبار واجهة التطبيق بالكامل لتكون من اليمين إلى اليسار (عربي)
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },

      // تعيين شاشة تسجيل الدخول كشاشة البداية
      home: const LoginPage(),
    );
  }
}
