import 'package:client/services/auth/auth.dart';
import 'package:client/services/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  String name = "";
  Future<void> getDetails() async {
    User? user = await Auth().getCurrentUser();
    if (user != null) {
      var details = await Profile().getDetails(user.email.toString());
      setState(() {
        name = details["name"] ?? "No Name";

        isLoading = false;
      });
    } else {
      debugPrint("No user is logged in");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading spinner
              : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back $name",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFF9C4,
                            ), // Light yellow background
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 4), // Shadow position
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10, // Adjusted for inner spacing
                          ),
                          child: const Center(
                            child: Text(
                              "PENDING REQUESTS",
                              style: TextStyle(
                                fontSize: 20, // Adjusted text size
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Black text color
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ), // Spacing between the two containers
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFFF9C4,
                              ), // Light yellow background
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4), // Shadow position
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 10, // Adjusted for inner spacing
                            ),
                            child: const Center(
                              child: Text(
                                "ACCEPTED REQUESTS",
                                style: TextStyle(
                                  fontSize: 20, // Adjusted text size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Black text color
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Text(
                    "Your Upcoming Exams",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                ],
              ),
    );
  }
}
