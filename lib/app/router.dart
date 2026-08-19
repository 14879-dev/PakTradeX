import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/ai/presentation/ai_copilot_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/otp_verification_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/home/models/market_data_models.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/markets/presentation/markets_screen.dart';
import '../features/news/models/news_item.dart';
import '../features/news/presentation/news_detail_screen.dart';
import '../features/news/presentation/news_screen.dart';
import '../features/portfolio/presentation/portfolio_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/shell/presentation/main_shell_screen.dart';
import '../features/stock_details/presentation/stock_detail_screen.dart';
import '../features/trading/presentation/trade_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _marketsNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _tradeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _portfolioNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final target = state.uri.queryParameters['target'] ?? '';
        return OtpVerificationScreen(target: target);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/ai',
      builder: (context, state) => const AiCopilotScreen(),
    ),
    GoRoute(
      path: '/news',
      builder: (context, state) => const NewsScreen(),
      routes: [
        GoRoute(
          path: 'detail',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final article = state.extra as NewsArticle;
            return NewsDetailScreen(article: article);
          },
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'stock/:symbol',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final stock = state.extra as StockQuote;
                    return StockDetailScreen(stock: stock);
                  },
                ),
              ],
            ),
          ],
        ),

        // Branch 1: Markets
        StatefulShellBranch(
          navigatorKey: _marketsNavigatorKey,
          routes: [
            GoRoute(
              path: '/markets',
              builder: (context, state) => const MarketsScreen(),
              routes: [
                GoRoute(
                  path: 'stock/:symbol',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final stock = state.extra as StockQuote;
                    return StockDetailScreen(stock: stock);
                  },
                ),
              ],
            ),
          ],
        ),

        // Branch 2: Trade
        StatefulShellBranch(
          navigatorKey: _tradeNavigatorKey,
          routes: [
            GoRoute(
              path: '/trade',
              builder: (context, state) => const TradeScreen(),
            ),
          ],
        ),

        // Branch 3: Assets (Portfolio)
        StatefulShellBranch(
          navigatorKey: _portfolioNavigatorKey,
          routes: [
            GoRoute(
              path: '/portfolio',
              builder: (context, state) => const PortfolioScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
