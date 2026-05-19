import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/user_home_screen.dart';
import '../../features/home/presentation/screens/provider_home_screen.dart';
import '../../features/chatbot/presentation/screens/chat_screen.dart';
import '../../features/booking/presentation/screens/booking_detail_screen.dart';
import '../../features/booking/presentation/screens/booking_history_screen.dart';
import '../../features/booking/presentation/screens/booking_confirmation_screen.dart';
import '../../features/provider/presentation/screens/job_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

import '../../shared/models/booking_model.dart';


import '../../features/auth/data/auth_provider.dart';
import '../../shared/models/user_model.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated) {
          notifyListeners();
        }
      },
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) => RouterNotifier(ref));

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final matched = state.matchedLocation;
      final goingToSplash = matched == AppRoutes.splash;
      final goingToOnboarding = matched == AppRoutes.onboarding;

      if (goingToSplash) {
        return null;
      }

      if (!isLoggedIn && !goingToOnboarding) {
        return AppRoutes.onboarding;
      }

      if (isLoggedIn && goingToOnboarding) {
        return authState.user?.role == UserRole.provider
            ? AppRoutes.providerHome
            : AppRoutes.userHome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => UserShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.userHome,
            name: 'userHome',
            builder: (context, state) => const UserHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.chat,
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: AppRoutes.bookingHistory,
            name: 'bookingHistory',
            builder: (context, state) => const BookingHistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => ProviderShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.providerHome,
            name: 'providerHome',
            builder: (context, state) => const ProviderHomeScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.bookingDetail,
        name: 'bookingDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookingDetailScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmation,
        name: 'bookingConfirmation',
        builder: (context, state) {
          final booking = state.extra as BookingModel?;
          return BookingConfirmationScreen(booking: booking);
        },
      ),
      GoRoute(
        path: AppRoutes.jobDetail,
        name: 'jobDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return JobDetailScreen(jobId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
});

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String userHome = '/home';
  static const String providerHome = '/provider-home';
  static const String chat = '/chat';
  static const String bookingDetail = '/booking/:id';
  static const String bookingHistory = '/bookings';
  static const String bookingConfirmation = '/booking/confirm';
  static const String jobDetail = '/job/:id';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
}

class UserShell extends StatefulWidget {
  final Widget child;
  const UserShell({super.key, required this.child});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _currentIndex = 0;

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home', route: AppRoutes.userHome),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'Chat', route: AppRoutes.chat),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Bookings', route: AppRoutes.bookingHistory),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', route: AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        items: _items,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_items[index].route);
        },
      ),
    );
  }
}

class ProviderShell extends StatefulWidget {
  final Widget child;
  const ProviderShell({super.key, required this.child});

  @override
  State<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<ProviderShell> {
  int _currentIndex = 0;

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.work_rounded, label: 'Jobs', route: AppRoutes.providerHome),
    _NavItem(icon: Icons.attach_money_rounded, label: 'Earnings', route: AppRoutes.providerHome),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', route: AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        items: _items,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_items[index].route);
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final Exception? error;
  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
