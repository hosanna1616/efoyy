import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:efoy/services/sync_service.dart';
import 'package:efoy/router/app_router.dart';
import 'package:efoy/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:efoy/generated/l10n/app_localizations.dart';
import 'package:efoy/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for offline storage
  await Hive.initFlutter();
  await HiveService.init();
  
  // Initialize Supabase
  await SupabaseService.init();
  
  // Sync pending offline data if online
  try {
    if (await SyncService.isOnline()) {
      await SyncService.syncAllPendingData();
    }
  } catch (e) {
    print('Sync skipped: $e');
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: EfoyApp(),
    ),
  );
}

class EfoyApp extends ConsumerStatefulWidget {
  const EfoyApp({super.key});

  @override
  ConsumerState<EfoyApp> createState() => _EfoyAppState();
}

class _EfoyAppState extends ConsumerState<EfoyApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(languageProvider);
    
    // Force rebuild when locale changes by using key
    return MaterialApp.router(
      key: ValueKey(locale.languageCode), // This forces rebuild on locale change
      title: 'Efoy - እፎይ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}


