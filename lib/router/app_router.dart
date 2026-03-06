import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/screens/home_screen.dart';
import 'package:efoy/screens/queue_screen.dart';
import 'package:efoy/screens/digital_card_screen.dart';
import 'package:efoy/screens/instructions_screen.dart';
import 'package:efoy/screens/navigation_screen.dart';
import 'package:efoy/screens/admin_dashboard_screen.dart';
import 'package:efoy/screens/register_screen.dart';
import 'package:efoy/screens/qr_scanner_screen.dart';
import 'package:efoy/screens/settings_screen.dart';
import 'package:efoy/screens/patient_login_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/patient-login',
        name: 'patient-login',
        builder: (context, state) => const PatientLoginScreen(),
      ),
      GoRoute(
        path: '/queue',
        name: 'queue',
        builder: (context, state) => const QueueScreen(),
      ),
      GoRoute(
        path: '/card',
        name: 'card',
        builder: (context, state) => const DigitalCardScreen(),
      ),
      GoRoute(
        path: '/instructions',
        name: 'instructions',
        builder: (context, state) => const InstructionsScreen(),
      ),
      GoRoute(
        path: '/navigation',
        name: 'navigation',
        builder: (context, state) => const NavigationScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/qr-scanner',
        name: 'qr-scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});


