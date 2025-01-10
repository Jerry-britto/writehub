import 'package:client/services/auth/auth.dart';
import 'package:client/screens/auth/login.dart';
import 'package:client/utils/alertbox_util.dart';
import 'package:flutter/material.dart';
import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        String response = await Auth().passwordReset(_emailController.text);
        DialogUtil.showAlertDialog(
          context,
          response.toLowerCase().contains("password reset")
              ? "Successfully done"
              : "Error",
          response,
        );
        _emailController.clear();
      } catch (error) {
        DialogUtil.showAlertDialog(
          context,
          "Error",
          "Something went wrong. Please try again.",
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email input field
                    Semantics(
                      label: 'Email input field',
                      hint: 'Enter your registered email',
                      child: ReusableInputField(
                        labelText: "Email",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email cannot be empty";
                          } else if (!RegExp(
                            r'^[^@]+@[^@]+\.[^@]+',
                          ).hasMatch(value)) {
                            return "Enter a valid email address";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button for sending password reset link
                    Semantics(
                      label: 'Send password reset link button',
                      hint: 'Double tap to send password reset link',
                      child: ReusableButton(
                        buttonText: "SEND RESET LINK",
                        onPressed: _handlePasswordReset,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Go to login page button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text("Go to login page"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loader overlay
          if (isLoading)
            Container(
              child: Center(
                child: SizedBox(
                  height: 100.0, 
                  width: 100.0,
                  child: const CircularProgressIndicator(
                    strokeWidth: 8.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
