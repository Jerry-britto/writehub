import 'package:flutter/material.dart';
import 'package:client/screens/auth/role_selection.dart';
import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/input.dart';
import 'package:client/services/auth/auth.dart';
import 'package:client/services/profile/profile.dart';
import 'package:client/screens/auth/password_reset.dart';
import 'package:client/screens/auth/register.dart';
import 'package:client/screens/home/scribe/scribe_home.dart';
import 'package:client/screens/home/swd/swd_home.dart';
import 'package:client/screens/profileDetails/user_details.dart';
import 'package:client/screens/profileDetails/volunteer_details.dart';
import 'package:client/utils/alertbox_util.dart';
import 'package:client/utils/snackbar_util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1A237E),
      ),
      backgroundColor: Color(0xFFBBDEFB),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Welcome Back! 👋",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Login to continue",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Email Input
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
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Input
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
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your password'
                                : null,
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ReusableButton(
                    buttonText: "Login",
                    onPressed: _handleLogin,
                    buttonColor: Color(0xFF1A237E),
                  ),
                  const SizedBox(height: 16),

                  // OR Divider
                  _buildOrDivider(),
                  const SizedBox(height: 16),

                  // Google Login Button
                  OutlinedButton.icon(
                    onPressed: _handleGoogleLogin,
                    icon: Image.asset('assets/images/google.png', height: 24),
                    label: const Text(
                      "Login with Google",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Forgot Password
                  TextButton(
                    onPressed: () => _navigateTo(const ForgotPasswordScreen()),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ),

                  // Sign Up Option
                  TextButton(
                    onPressed: () => _navigateTo(const SignupPage()),
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Show loading spinner
          if (_isLoading)
            Positioned.fill(
              child: Container(
                child: const Center(
                  child: SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: CircularProgressIndicator(strokeWidth: 8.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String loginResponse = await Auth().login(
        emailController.text.trim().toLowerCase(),
        passwordController.text.trim(),
      );

      if (!loginResponse.startsWith("success")) {
        // ignore: use_build_context_synchronously
        DialogUtil.showAlertDialog(context, "Login failed", loginResponse);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // ignore: use_build_context_synchronously
      SnackBarUtil.showSnackBar(context, loginResponse);

      Map<String, dynamic> user = await Profile().getDetails(
        emailController.text.trim().toLowerCase(),
      );

      if (user["name"] == null || user["phone_number"] == null) {
        _redirectToDetailsPage(user);
      } else {
        _redirectToHomePage(user);
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      DialogUtil.showAlertDialog(context, "Error", error.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final value = await Auth().registerOrLoginWithGoogle();
      debugPrint("Google signed in user: $value");

      Map<String, dynamic> user = await Profile().getDetails(value);

      if (user.containsKey("new-user") &&
          user["new-user"] == "user not found") {
        _navigateTo(RoleSelection(email: value));
      } else {
        if (user["name"] == null || user["phone_number"] == null) {
          _redirectToDetailsPage(user);
        } else {
          _redirectToHomePage(user);
        }
      }
    } catch (error) {
      debugPrint("Google sign-in error: ${error.toString()}");
      SnackBarUtil.showSnackBar(
        // ignore: use_build_context_synchronously
        context,
        "Google sign-in failed, please try again",
      );
    }
  }

  void _redirectToDetailsPage(Map<String, dynamic> user) {
    if (user["role"] == "swd") {
      _navigateTo(Userdetails(email: user["email"]));
    } else if (user["role"] == "scribe") {
      _navigateTo(VolunteerDetails(email: user["email"]));
    } else {
      SnackBarUtil.showSnackBar(
        context,
        "Invalid role detected",
        backgroundColor: Colors.red,
      );
    }
  }

  void _redirectToHomePage(Map<String, dynamic> user) {
    if (user["role"] == "swd") {
      _navigateTo(const SwdHome());
    } else if (user["role"] == "scribe") {
      _navigateTo(const ScribeHome());
    } else {
      SnackBarUtil.showSnackBar(
        context,
        "Invalid role detected",
        backgroundColor: Colors.red,
      );
    }
  }

  void _navigateTo(Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(thickness: 1, color: Colors.grey[400])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0)),
      ],
    );
  }
}
