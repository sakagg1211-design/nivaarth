import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient client = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: name != null && name.trim().isNotEmpty
          ? {'name': name.trim(), 'full_name': name.trim()}
          : null,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  User? get currentUser => client.auth.currentUser;
}