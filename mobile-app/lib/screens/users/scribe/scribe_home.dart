import 'package:client/screens/users/scribe/home.dart';
import 'package:client/screens/users/notifications.dart';
import 'package:client/screens/users/scribe/profile.dart';
import 'package:client/screens/users/scribe/rewards.dart';
import 'package:flutter/material.dart';

class ScribeHome extends StatefulWidget {
  const ScribeHome({super.key});

  @override
  State<ScribeHome> createState() => _ScribeHomeState();
}

class _ScribeHomeState extends State<ScribeHome> {
  int screenIdx = 0;
  String screenTitle = "Home Screen";

  List<Widget> screens = [
    Home(),
    RewardsScreen(),
    Notifications(),
    ScribeProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1A237E),
      ),
      backgroundColor: Color(0xFFBBDEFB),
      body: screens[screenIdx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: screenIdx,
        items: [
          BottomNavigationBarItem(
            icon: Semantics(label: "Home", child: const Icon(Icons.home)),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: "Rewards",
              child: const Icon(Icons.emoji_events),
            ),
            label: "Rewards",
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: "Notifications",
              child: const Icon(Icons.notifications),
            ),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: "Profile",
              child: const Icon(Icons.person_2),
            ),
            label: "Profile",
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF1A237E),
        selectedItemColor: Color.fromARGB(255, 21, 231, 234),
        unselectedItemColor: Colors.white,
        onTap:
            (value) => setState(() {
              screenIdx = value;
              switch (value) {
                case 0:
                  screenTitle = "Home";
                  break;
                case 1:
                  screenTitle = "Rewards";
                  break;
                case 2:
                  screenTitle = "Notifications";
                  break;
                case 3:
                  screenTitle = "Profile";
                  break;
              }
            }),
      ),
    );
  }
}
