import 'package:client/screens/auth/auth_wrapper.dart';
import 'package:client/screens/auth/login.dart';
import 'package:client/screens/users/scribe/scribe_home.dart';
import 'package:client/screens/users/swd/swd_home.dart';
import 'package:client/services/notifications/notification_receive__service.dart';
import 'package:client/utils/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: dotenv.env["SUPABASE_URL"].toString(),
    anonKey: dotenv.env["SUPABASE_ANONKEY"].toString(),
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
