import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: ArthaAIApp(),
    ),
  );
}

class ArthaAIApp extends StatelessWidget {
  const ArthaAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ARTHA AI',
      theme: AppTheme.darkTheme,
      home: const DashboardPage(),
    );
  }
}