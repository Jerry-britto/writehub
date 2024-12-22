import 'package:client/components/button.dart';
import 'package:client/components/input.dart';
import 'package:client/screens/auth/login.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool isScribe = false; // Tracks whether the user is a Scribe or an SWD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome! 👋",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Sign up to continue",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Checkbox for Scribe
              CheckboxListTile(
                title: Text('I am a Scribe'),
                value: isScribe,
                onChanged: (value) {
                  setState(() {
                    isScribe = value!;
                  });
                },
                activeColor: Colors.deepPurple,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),

              // Email Input Field
              ReusableInputField(
                labelText: 'Email',
                controller: emailController,
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Kindly enter your email";
                  } else if (!RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  ).hasMatch(value)) {
                    return "Invalid Email";
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Password Input Field
              ReusableInputField(
                labelText: 'Password',
                controller: passwordController,
                prefixIcon: Icons.lock,
                isPassword: !_isPasswordVisible,
                suffixIcon:
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                onSuffixTap: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password Input Field
              ReusableInputField(
                labelText: 'Confirm Password',
                controller: confirmPasswordController,
                prefixIcon: Icons.lock,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Signup Button
              ReusableButton(
                buttonText: "Sign Up",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isScribe
                              ? 'Signing up as a Scribe'
                              : 'Signing up as an SWD',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(thickness: 1, color: Colors.grey[400]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "OR",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    child: Divider(thickness: 1, color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Google Signup Button
              OutlinedButton.icon(
                onPressed: () {
                  // Add Google Signup Logic
                },
                icon: Image.asset('assets/images/google.png', height: 24),
                label: Text(
                  "Sign up with Google",
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Already Have an Account?
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: Text(
                  "Already have an account? Log in",
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
