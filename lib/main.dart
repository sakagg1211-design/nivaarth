import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/login/login_page.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: NivaarthApp(),
    ),
  );
}

class NivaarthApp extends StatelessWidget {
  const NivaarthApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NIVAARTH',
      theme: AppTheme.darkTheme,
      home: session == null
          ? const LoginPage()
          : const DashboardPage(),
    );
  }
}