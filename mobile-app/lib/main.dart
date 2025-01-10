import 'package:client/screens/auth/auth_wrapper.dart';
import 'package:client/utils/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: "https://yaqkxmizbbmhnicgxqke.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlhcWt4bWl6YmJtaG5pY2d4cWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUwNDkyMTYsImV4cCI6MjA1MDYyNTIxNn0.Y-aLOmlZnENqK28lrFwzOWDa7mSj5dfMxV9Rlik2EzY"
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}
