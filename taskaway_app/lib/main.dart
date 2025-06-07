import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskaway_app/core/constants/app_constants.dart';
import 'package:taskaway_app/core/theme/app_theme.dart';
import 'package:taskaway_app/core/theme/theme_provider.dart';
import 'package:taskaway_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:taskaway_app/features/tasks/presentation/screens/task_list_screen.dart';

Future<void> main() async {
  // Optimize Flutter web performance
  if (kIsWeb && kReleaseMode) {
    // Disable debug prints in release mode for web
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Ensure proper initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  // Create a container to override the theme provider with the saved preference
  final savedTheme = await loadThemePreference();
  final container = ProviderContainer(
    overrides: [
      themeProvider.overrideWith((ref) => savedTheme),
    ],
  );

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'TaskAway',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashScreen(),
        '/tasks': (context) => const TaskListScreen(),
      },
    );
  }
}
