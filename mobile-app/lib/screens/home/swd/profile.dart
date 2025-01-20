import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/input.dart';
import 'package:client/screens/auth/login.dart';
import 'package:client/services/auth/auth.dart';
import 'package:flutter/material.dart';

class SwdProfile extends StatefulWidget {
  const SwdProfile({super.key});

  @override
  State<SwdProfile> createState() => _SwdProfileState();
}

class _SwdProfileState extends State<SwdProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 100,
              backgroundImage: NetworkImage(
                "https://images.pexels.com/photos/7366257/pexels-photo-7366257.jpeg?auto=compress&cs=tinysrgb&w=600",
              ),
            ),
            const SizedBox(height: 40),
        
            // Name Input
            Semantics(
              label: "User's name",
              hint: "Displays the user's name",
              child: ReusableInputField(
                labelText: "Akshay Kumar",
                hintText: "Name",
                readOnly: true,
                isEnabled: false,
              ),
            ),
        
            const SizedBox(height: 10),
        
            // Email Input
            Semantics(
              label: "User's email address",
              hint: "Displays the user's email address",
              child: ReusableInputField(
                labelText: "abc@gmail.com",
                hintText: "Email",
                readOnly: true,
                isEnabled: false,
              ),
            ),
            const SizedBox(height: 10),
        
            // Phone Number Input
            Semantics(
              label: "User's phone number",
              hint: "Displays the user's phone number",
              child: ReusableInputField(
                labelText: "9833598829",
                hintText: "Phone Number",
                readOnly: true,
                isEnabled: false,
              ),
            ),
            
            const SizedBox(height: 20),
        
            // Logout Button
            Semantics(
              label: "Logout button",
              hint: "Logs out the user and navigates back to the login screen",
              button: true,
              child: SizedBox(
                width: double.infinity,
                child: ReusableButton(
                  buttonText: "LOGOUT",
                  weight: FontWeight.bold,
                  padding: 16,
                  buttonColor: Color(0xFF1A237E),
                  onPressed: () {
                    Auth().logout().then((value) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
