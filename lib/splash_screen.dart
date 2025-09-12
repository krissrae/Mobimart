import 'package:flutter/material.dart';
import 'package:mobimart/supabase_manager.dart';
import 'home_screen.dart';
import 'auth_pages.dart';
import 'admin_page.dart';

const String adminEmail = 'nnamuradiance@gmail.com';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for the first frame then check auth
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  /// 🔹 Checks current session and navigates accordingly
  Future<void> _checkAuth() async {
    final session = SupabaseManager.client.auth.currentSession;
    final user = session?.user;

    if (user != null) {
      final emailLower = user.email?.toLowerCase();
      if (emailLower == adminEmail.toLowerCase()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
