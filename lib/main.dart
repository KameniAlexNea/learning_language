import 'package:discursia/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db/auth_google.dart';
import 'firebase_options.dart';
import 'utilities/storage_manager.dart';
import 'screens/login.dart';
import 'db/discusia.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async calls in main
  await PreferencesManager.instance.init(); // Initialize SharedPreferences
  await dotenv.load(fileName: "conf");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DiscusiaConfig.init();
  runApp(DiscursiaAuthApp());
}

class DiscursiaAuthApp extends StatelessWidget {
  const DiscursiaAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discusia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.adventProTextTheme(),
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: GoogleAuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          return user == null ? LoginPage() : WritingAssistantApp();
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
