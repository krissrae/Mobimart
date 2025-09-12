import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static const String supabaseUrl = 'https://tifxbnbrwoegsozbormv.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpZnhibmJyd29lZ3NvemJvcm12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU4NDY0NzksImV4cCI6MjA3MTQyMjQ3OX0.Hva_qWnwitZSR-uFGxtbAJeuoLYYfurwMV9QsfZPicg';

  static late final SupabaseClient client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    client = Supabase.instance.client;
  }
}
