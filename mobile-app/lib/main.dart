import 'package:client/screens/auth/auth_wrapper.dart';
import 'package:client/screens/auth/login.dart';
import 'package:client/screens/home/scribe/scribe_home.dart';
import 'package:client/screens/home/swd/swd_home.dart';
import 'package:client/services/notifications/notification_service.dart';
import 'package:client/utils/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: "https://yaqkxmizbbmhnicgxqke.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlhcWt4bWl6YmJtaG5pY2d4cWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUwNDkyMTYsImV4cCI6MjA1MDYyNTIxNn0.Y-aLOmlZnENqK28lrFwzOWDa7mSj5dfMxV9Rlik2EzY",
  );
  await NotificationService().initNotifications();
  runApp(const MainApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      navigatorKey: navigatorKey,
      routes: {
        '/login': (_) => LoginPage(),
        '/swd': (context) => SwdHome(),
        '/scribe': (context) => ScribeHome(),
      },
    );
  }
}
