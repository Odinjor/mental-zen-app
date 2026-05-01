import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/journal_entry_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Force dark status bar icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MentalZenApp());
}

class MentalZenApp extends StatelessWidget {
  const MentalZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<AuthService>(create: (_) => AuthService())],
      child: MaterialApp(
        title: 'Mental Zen',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const HomeScreen(),
          '/journal': (_) => const JournalScreen(),
          '/journal-entry': (_) => const JournalEntryScreen(),
          '/mood-tracker': (_) => const MoodTrackerScreen(),
          '/insights': (_) => const InsightsScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    const kBackground = Color(0xFF0D1117);
    const kSurface = Color(0xFF161B22);
    const kCard = Color(0xFF1E2530);
    const kPrimary = Color(0xFF7C6FCD);
    const kSecondary = Color(0xFF6BCB77);
    const kTextPrimary = Color(0xFFE6EDF3);
    const kTextSecondary = Color(0xFF8B949E);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBackground,

      colorScheme: const ColorScheme.dark(
        surface: kSurface,
        primary: kPrimary,
        secondary: kSecondary,
        onSurface: kTextPrimary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          color: kTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: kTextPrimary,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: kTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.nunito(
          color: kTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.nunito(
          color: kTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.nunito(
          color: kTextPrimary,
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.nunito(
          color: kTextSecondary,
          fontSize: 14,
          height: 1.5,
        ),
        labelSmall: GoogleFonts.nunito(
          color: kTextSecondary,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: kSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.nunito(
          color: kTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: kTextSecondary),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: kCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kCard,
        hintStyle: GoogleFonts.nunito(color: kTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE05C5C), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kPrimary.withValues(alpha: 0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kPrimary,
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: kCard,
        labelStyle: GoogleFonts.nunito(color: kTextSecondary, fontSize: 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kCard,
        contentTextStyle: GoogleFonts.nunito(color: kTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: kTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: GoogleFonts.nunito(
          color: kTextSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
