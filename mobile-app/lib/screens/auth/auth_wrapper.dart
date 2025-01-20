import 'package:client/services/profile/profile.dart';
import 'package:client/screens/auth/login.dart';
import 'package:client/screens/auth/role_selection.dart';
import 'package:client/screens/home/scribe/scribe_home.dart';
import 'package:client/screens/home/swd/swd_home.dart';
import 'package:client/screens/profileDetails/user_details.dart';
import 'package:client/screens/profileDetails/volunteer_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<Map<String, dynamic>> _userInfoFuture;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          // User is logged in
          User? user = snapshot.data;
          String? email = user?.email;

          // If the email is null, you should handle this case
          if (email == null) {
            return LoginPage();
          }

          // Fetch user details asynchronously
          _userInfoFuture = Profile().getDetails(email);

          return FutureBuilder<Map<String, dynamic>>(
            future: _userInfoFuture,
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (futureSnapshot.hasError) {
                return Center(child: Text('Error: ${futureSnapshot.error}'));
              } else if (futureSnapshot.hasData) {
                Map<String, dynamic> userInfo = futureSnapshot.data!;

                // If the user is new, show the role selection screen
                if (userInfo.containsKey("new-user")) {
                  return RoleSelection(email: email);
                }

                // If the user details are missing, show the user details screen
                if (userInfo["name"] == null || userInfo["phone_number"] == null) {
                  if (userInfo["role"] == "swd") {
                    return Userdetails(email: email);
                  } else {
                    return VolunteerDetails(email: email);
                  }
                }

                // If the user has a role, show the appropriate home screen
                if (userInfo["role"] == "swd") {
                  return SwdHome();
                } else {
                  return ScribeHome();
                }
              } else {
                return Center(child: Text('No user info found.'));
              }
            },
          );
        } else {
          // User is not logged in
          return LoginPage();
        }
      },
    );
  }
}
