import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/input.dart';
import 'package:client/features/auth/auth.dart';
import 'package:client/features/profile/profile.dart';
import 'package:client/screens/auth/login.dart';
import 'package:client/screens/auth/role_selection.dart';
import 'package:client/screens/home/scribe_home.dart';
import 'package:client/screens/home/swd_home.dart';
import 'package:client/screens/profileDetails/user_details.dart';
import 'package:client/screens/profileDetails/volunteer_details.dart';
import 'package:client/utils/snackbar_util.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
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
  bool _isLoading = false; // Loading state for signup process

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  Column(
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
                        onPressed: _handleSignup,
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
                        onPressed: _handleGoogleSignUp,
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
          
                  // Show the loading spinner on top of the UI
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        child: Center(
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Show loading spinner
    });

    try {
      String signupResponse = await Auth().register(
        emailController.text.toString().toLowerCase().trim(),
        passwordController.text.trim(),
      );

      if (!signupResponse.startsWith("success")) {
        SnackBarUtil.showSnackBar(context, signupResponse);
        setState(() {
          _isLoading = false; // Hide loading spinner
        });
        return;
      }

      // On successful signup, save the registration info
      Profile().saveRegisterationInfo(
        context,
        emailController.text.toString().toLowerCase().trim(),
        isScribe ? "scribe" : "swd",
      );

      Auth().login(emailController.text, passwordController.text);
      // Navigate based on user role
      if (isScribe) {
        _navigateTo(VolunteerDetails(email: emailController.text));
      } else {
        _navigateTo(Userdetails(email: emailController.text));
      }
    } catch (error) {
      SnackBarUtil.showSnackBar(context, error.toString());
      setState(() {
        _isLoading = false; // Hide loading spinner
      });
    }
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      final value = await Auth().registerOrLoginWithGoogle();
      debugPrint("Google signed up user: $value");

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
}
