import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/input.dart';
import 'package:client/screens/auth/login.dart';
import 'package:client/services/auth/auth.dart';
import 'package:client/services/profile/profile.dart';
import 'package:client/utils/alertbox_util.dart';
import 'package:client/utils/snackbar_util.dart';
import 'package:client/utils/uploadfile.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScribeProfile extends StatefulWidget {
  const ScribeProfile({super.key});

  @override
  State<ScribeProfile> createState() => _ScribeProfileState();
}

class _ScribeProfileState extends State<ScribeProfile> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  int userId = 0;
  String profilePhoto = "";
  bool isLoading = true;
  // Add points variable
  dynamic userPoints = 0;

  // Track the edit mode for each field
  bool isEditingName = false;
  bool isEditingPhoneNumber = false;

  Future<void> _pickImage() async {
    setState(() {
      isLoading = true;
    });
    await Profile().deleteOldImageFromSupabase("scribes", profilePhoto);
    Map<String, String>? userPhoto = await Uploadfile().selectSingleFile();
    if (userPhoto != null) {
      // Assuming a function `uploadImageToSupabase` that uploads the image and returns the URL.
      String imageUrl = await Profile().uploadProfilePhoto(
        userPhoto,
        "scribes",
      );

      setState(() {
        profilePhoto =
            imageUrl; // Update profile photo URL with the one from Supabase
      });

      updateProfileData(
        "profile_photo",
        imageUrl,
      ); // Update profile photo in your backend
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getDetails() async {
    firebase_auth.User? user = await Auth().getCurrentUser();
    if (user != null) {
      var details = await Profile().getDetails(user.email.toString());
      setState(() {
        nameController.text = details["name"] ?? "No Name";
        emailController.text = details["email"] ?? "No Email";
        userId = details["user_id"];
        phoneNumberController.text =
            details["phone_number"] ?? "No Phone Number";
        profilePhoto =
            details["profile_photo"] ??
            "https://img.freepik.com/premium-vector/default-avatar-profile-icon-social-media-user-image-gray-avatar-icon-blank-profile-silhouette-vector-illustration_561158-3383.jpg?w=360";
        isLoading = false;
      });
      final pointsScored =
          await supabase
              .from("scribes_points")
              .select("points")
              .eq("user_id", userId)
              .single();
      setState(() {
        userPoints = pointsScored["points"];
      });
      debugPrint("${pointsScored["points"]}");
    } else {
      debugPrint("No user is logged in");
      setState(() => isLoading = false);
    }
  }

  updateProfileData(String field, String value) {
    try {
      Profile().updateDetails(userId, field, value);
      SnackBarUtil.showSnackBar(context, "updated $field");
    } catch (e) {
      SnackBarUtil.showSnackBar(context, "could not update $field");
    }
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ReusableInputField(
            hintText: label,
            controller: controller,
            readOnly: !isEditing,
            isEnabled: isEditing,
            maxLength: label == "Phone Number" ? 10 : null,
            keyboardType:
                label == "Phone Number"
                    ? TextInputType.phone
                    : TextInputType.text,
          ),
        ),
        const SizedBox(width: 8),
        isEditing
            ? ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            )
            : ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Edit", style: TextStyle(color: Colors.white)),
            ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{
        debugPrint("refreshed profile screen");
        await getDetails();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(),
                ) // Show loading spinner
                : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Points Display Card - positioned prominently at the top
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Your Points",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.stars_rounded,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  userPoints.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
      
                      // Profile Picture
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xFF1A237E), width: 5),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 100,
                          backgroundImage: NetworkImage(profilePhoto),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          "Change Profile Photo",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ReusableInputField(
                        hintText: "Email",
                        controller: emailController,
                        isEnabled: false,
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      // Editable Name Field
                      _buildEditableField(
                        label: "Name",
                        controller: nameController,
                        isEditing: isEditingName,
                        onEdit: () {
                          setState(() {
                            isEditingName = true;
                          });
                        },
                        onSave: () {
                          if (nameController.text.isEmpty ||
                              nameController.text.trim().isEmpty) {
                            DialogUtil.showAlertDialog(
                              context,
                              "Empty field",
                              "Kindly provide a valid name",
                            );
                            return;
                          }
                          setState(() {
                            isEditingName = false;
                          });
                          // Save the updated name
                          debugPrint("Updated name");
      
                          updateProfileData("name", nameController.text);
                        },
                      ),
      
                      const SizedBox(height: 20),
      
                      // Editable Phone Number Field
                      _buildEditableField(
                        label: "Phone Number",
                        controller: phoneNumberController,
                        isEditing: isEditingPhoneNumber,
                        onEdit: () {
                          setState(() {
                            isEditingPhoneNumber = true;
                          });
                        },
                        onSave: () {
                          if (phoneNumberController.text.isEmpty ||
                              phoneNumberController.text.trim().isEmpty ||
                              !RegExp(
                                r'^[0-9]{8,10}$',
                              ).hasMatch(phoneNumberController.text)) {
                            DialogUtil.showAlertDialog(
                              context,
                              "Invalid phone number",
                              "Kindly provide a valid phone number",
                            );
                            return;
                          }
      
                          setState(() {
                            isEditingPhoneNumber = false;
                          });
      
                          updateProfileData(
                            "phone_number",
                            phoneNumberController.text,
                          );
                        },
                      ),
                      const SizedBox(height: 30),
      
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ReusableButton(
                          buttonText: "LOGOUT",
                          weight: FontWeight.bold,
                          padding: 16,
                          buttonColor: const Color(0xFF1A237E),
                          onPressed: () async {
                            await Auth().logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
