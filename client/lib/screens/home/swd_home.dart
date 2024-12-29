import 'package:client/components/inputs/button.dart';
import 'package:client/features/auth/auth.dart';
import 'package:client/screens/auth/login.dart';
import 'package:flutter/material.dart';

class SwdHome extends StatefulWidget {
  const SwdHome({super.key});

  @override
  State<SwdHome> createState() => _SwdHomeState();
}

class _SwdHomeState extends State<SwdHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SWD HOME"),),
      body: Center(
        child: ReusableButton(
            buttonText: "LOGOUT",
            onPressed: () {
              Auth().logout().then((value) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              });
            },
          ),
      ),
    );
  }
}
