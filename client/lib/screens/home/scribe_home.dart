import 'package:client/components/inputs/button.dart';
import 'package:client/features/auth/auth.dart';
import 'package:client/screens/auth/login.dart';
import 'package:flutter/material.dart';

class ScribeHome extends StatefulWidget {
  const ScribeHome({super.key});

  @override
  State<ScribeHome> createState() => _ScribeHomeState();
}

class _ScribeHomeState extends State<ScribeHome> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(title: Text("Scribe's Home Page"),),
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
      )
    );
  }
}
