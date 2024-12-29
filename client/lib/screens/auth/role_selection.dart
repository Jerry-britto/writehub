import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/dropdown.dart';
import 'package:client/features/profile/profile.dart';
import 'package:client/screens/profileDetails/user_details.dart';
import 'package:client/screens/profileDetails/volunteer_details.dart';
import 'package:client/utils/alertbox_util.dart';
import 'package:client/utils/snackbar_util.dart';
import 'package:flutter/material.dart';

class RoleSelection extends StatefulWidget {
  const RoleSelection({super.key, required this.email});
  final String email;

  @override
  State<RoleSelection> createState() => _RoleSelectionState();
}

class _RoleSelectionState extends State<RoleSelection> {
  String? selectedRole = "SELECT";

  // Constants for role selection
  static const String roleUser = "swd";
  static const String roleVolunteer = "scribe";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Your Role", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomDropdown(
              label: "SELECT YOUR ROLE",
              options: ["SELECT", roleUser, roleVolunteer],
              value: selectedRole,
              onChanged: (String? role) {
                setState(() {
                  selectedRole = role;
                });
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ReusableButton(
                buttonText: "Confirm Role",
                onPressed: () async {
                  if (selectedRole == "SELECT") {
                    DialogUtil.showAlertDialog(
                      context,
                      "Invalid role",
                      "Kindly select a valid role",
                    );
                    return;
                  }

                  try {
                    // Save the registration info
                    await Profile().saveRegisterationInfo(
                      context,
                      widget.email,
                      selectedRole.toString(),
                    );

                    // Navigate based on the selected role
                    if (selectedRole == roleUser) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => Userdetails(email: widget.email),
                        ),
                      );
                    } else if (selectedRole == roleVolunteer) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => VolunteerDetails(email: widget.email),
                        ),
                      );
                    } else {
                      SnackBarUtil.showSnackBar(context, "INVALID role");
                    }
                    
                  } catch (error) {
                    SnackBarUtil.showSnackBar(context, error.toString());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
