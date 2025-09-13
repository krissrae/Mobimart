import 'package:flutter/material.dart';
import 'package:mobimart/supabase_manager.dart';
import 'splash_screen.dart';
import 'profile_page.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseManager.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => OrderProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobimart',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.pink,       // AppBar & main buttons
        colorScheme: ColorScheme.light(
          primary: Colors.pink,
          secondary: Colors.pinkAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
          ),
        ),
      ),
      home: SplashScreen(), // start with signup
      debugShowCheckedModeBanner: false,
      routes: {
        '/profile': (_) => const ProfilePage(),
      },
  );
  }
}
