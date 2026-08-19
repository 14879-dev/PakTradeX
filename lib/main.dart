import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_typography.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom Error Widget for Graceful Crash Recovery
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return Material(
        color: AppColors.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
                const SizedBox(height: 12),
                Text('Application Exception', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                Text(
                  details.exceptionAsString(),
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const Material(
      color: AppColors.background,
      child: Center(
        child: Text('An unexpected error occurred. Please restart the application.'),
      ),
    );
  };

  // Fix orientation to portrait for mobile-first experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: PakTradeXApp(),
    ),
  );
}
