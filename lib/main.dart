    import 'package:flutter/material.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'package:firebase_auth/firebase_auth.dart';
    import 'package:google_fonts/google_fonts.dart';
    import 'package:intl/date_symbol_data_local.dart'; // Pastikan ini ada
    import 'firebase_options.dart';
    import 'package:aplikasi_absensi_sederhana/login_screen.dart';
    import 'package:aplikasi_absensi_sederhana/dashboard_screen.dart';

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // PASTIKAN PANGGILAN INI ADA DI SINI
      await initializeDateFormatting('id_ID', null); // Pastikan 'id_ID' sudah benar
      runApp(const MyApp());
    }

    class MyApp extends StatelessWidget {
      const MyApp({super.key});

      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          title: 'Aplikasi Absensi Guru',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.blueGrey[50],
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              labelStyle: GoogleFonts.poppins(color: Colors.blueGrey[700]),
              hintStyle: GoogleFonts.poppins(color: Colors.blueGrey[400]),
              prefixIconColor: Colors.blueGrey[400],
            ),
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  ),
                );
              }
              if (snapshot.hasData) {
                return const DashboardScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      }
    }
    