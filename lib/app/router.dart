import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/ai/presentation/ai_copilot_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/markets/presentation/markets_screen.dart';
import '../features/portfolio/presentation/portfolio_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/shell/presentation/main_shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _marketsNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _portfolioNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _aiNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 2: Markets
        StatefulShellBranch(
          navigatorKey: _marketsNavigatorKey,
          routes: [
            GoRoute(
              path: '/markets',
              builder: (context, state) => const MarketsScreen(),
            ),
          ],
        ),
        // Tab 3: Portfolio
        StatefulShellBranch(
          navigatorKey: _portfolioNavigatorKey,
          routes: [
            GoRoute(
              path: '/portfolio',
              builder: (context, state) => const PortfolioScreen(),
            ),
          ],
        ),
        // Tab 4: AI Copilot
        StatefulShellBranch(
          navigatorKey: _aiNavigatorKey,
          routes: [
            GoRoute(
              path: '/ai',
              builder: (context, state) => const AiCopilotScreen(),
            ),
          ],
        ),
        // Tab 5: Profile
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
