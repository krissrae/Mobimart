import 'package:mobimart/supabase_manager.dart';

class AuthService {
  static Future signUp(String email, String password) async {
    return await SupabaseManager.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future signIn(String email, String password) async {
    return await SupabaseManager.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future signOut() async {
    return await SupabaseManager.client.auth.signOut();
  }

  static get currentUser => SupabaseManager.client.auth.currentUser;
}
