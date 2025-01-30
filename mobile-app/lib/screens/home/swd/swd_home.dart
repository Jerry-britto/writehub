import 'package:client/screens/home/swd/bookscribe.dart';
import 'package:client/screens/home/swd/home.dart';
import 'package:client/screens/home/notifications.dart';
import 'package:client/screens/home/swd/profile.dart';
import 'package:flutter/material.dart';

class SwdHome extends StatefulWidget {
  const SwdHome({super.key});

  @override
  State<SwdHome> createState() => _SwdHomeState();
}

class _SwdHomeState extends State<SwdHome> {
  int screenIdx = 0;
  String screenTitle = "Home Screen";

  List<Widget> screens = [Home(), Bookscribe(), Notifications(), SwdProfile()];

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
              label: "Book Scribe",
              child: const Icon(Icons.border_color),
            ),
            label: "Book Scribe",
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
                  screenTitle = "Home Page";
                  break;
                case 1:
                  screenTitle = "Book Scribe";
                  break;
                case 2:
                  screenTitle = "Notifications";
                  break;
                case 3:
                  screenTitle = "Your Profile";
                  break;
              }
            }),
      ),
    );
  }
}
