import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/login_register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/berita_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_login_screen.dart';
import 'widgets/admin_layout.dart';
import 'services/admin_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Jika Firebase init gagal, tetap jalankan aplikasi
    debugPrint('Error initializing Firebase: $e');
  }

  // Setup admin default di background (tidak blocking)
  // Jangan await agar tidak menghambat startup aplikasi
  AdminAuthService().setupDefaultAdmin().catchError((e) {
    debugPrint('Error setting up admin: $e');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Berita',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginRegisterScreen(),
        '/admin/login': (context) => const AdminLoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/berita': (context) => BeritaListScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/admin': (context) => const AdminLayout(),
        '/admin/dashboard': (context) => const AdminLayout(),
        '/admin/users': (context) => const AdminLayout(),
        '/admin/berita': (context) => const AdminLayout(),
        '/admin/kategori': (context) => const AdminLayout(),
      },
      // Error handling
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
