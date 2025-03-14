import 'dart:io';
import 'package:client/utils/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> saveRegisterationInfo(
    BuildContext context,
    String email,
    String role,
  ) async {
    try {
      final response = await supabase.from("users").insert({
        "email": email,
        "role": role,
      });

      debugPrint("response object: $response");

      if (response != null && response.error != null) {
        SnackBarUtil.showSnackBar(
          context,
          response.error!.message,
          backgroundColor: Colors.red,
        );
      } else {
        SnackBarUtil.showSnackBar(
          context,
          'Registration details saved successfully',
        );
      }
    } catch (e) {
      debugPrint('Error inserting record: $e');
      SnackBarUtil.showSnackBar(
        context,
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDetails(String email) async {
    try {
      // First, let's debug the email we're searching for
      debugPrint('Searching for email: $email');

      final response =
          await supabase
              .from("users")
              .select()
              .eq("email", email.trim().toLowerCase())
              .maybeSingle();

      if (response == null) {
        return {"new-user": "user not found"};
      }

      // Add more detailed debugging
      debugPrint('Response length: ${response.length}');
      debugPrint('Full response: $response');

      return response;
    } catch (e) {
      debugPrint('Error fetching role: $e');
      return {"Error": "An error occurred while fetching the role"};
    }
  }

  Future<void> saveUserDetails({
    required String name,
    required String phoneNumber,
    required String email,
    required String academicYear,
    required String course,
    required String collegeName,
    required List<String> disabilities,
    profilePhoto = "",
    collegeProof = "",
    List<Map<String, dynamic>> certificates =
        const [], // Changed type to List<Map>
  }) async {
    try {
      // Step 1: Update user details
      final userResponse =
          await supabase
              .from("users")
              .update({
                "name": name,
                "phone_number": phoneNumber,
                "profile_photo": profilePhoto != "" ? profilePhoto : null,
                "collegeName": collegeName,
                "college_proof": collegeProof != "" ? collegeProof : null,
                'academic_year': academicYear,
                'course': course,
              })
              .eq('email', email.toLowerCase())
              .select();

      if (userResponse.isEmpty) {
        throw Exception("Failed to update user details");
      }
      debugPrint("Updated User Details: $userResponse");

      // Get user ID
      final userId = userResponse[0]['user_id'];
      debugPrint("user id $userId");

      if (certificates.isNotEmpty) {
        await uploadCertificates(userId, certificates);
      }

      // Step 2: Get disability IDs from the disabilities table
      final disabilitiesResponse = await supabase
          .from("disability")
          .select('disability_id')
          .inFilter('disability_name', disabilities);

      debugPrint("disability id's $disabilitiesResponse");

      // Extract disability IDs
      final List<int> disabilityIds = List<int>.from(
        disabilitiesResponse.map((disability) => disability['disability_id']),
      );
      debugPrint("disability id's $disabilityIds");

      // Step 3: Insert disability relationships into the user_disabilities table
      await supabase
          .from("user_disabilities")
          .upsert(
            disabilityIds.map((disabilityId) {
              return {"user_id": userId, "disability_id": disabilityId};
            }).toList(),
          )
          .select();

      debugPrint("User and student details updated successfully");
    } catch (e) {
      debugPrint("Error saving user details: $e");
      rethrow;
    }
  }

  Future<void> saveVolunteerDetails(
    name,
    email,
    phoneNumber,
    course,
    college,
    academicYear, {
    profilePhoto = "",
    collegeProof = "",
  }) async {
    debugPrint("Profile Photo: $profilePhoto");
    try {
      final userDetails =
          await supabase
              .from("users")
              .update({
                "name": name,
                "phone_number": phoneNumber,
                "collegeName": college,
                "profile_photo":
                    profilePhoto != "" ? profilePhoto.toString() : null,
                "college_proof":
                    collegeProof != "" ? collegeProof.toString() : null,
                "academic_year": academicYear,
                "course": course,
              })
              .eq("email", email)
              .select();
      debugPrint("User details - $userDetails");
      if (userDetails.isEmpty) {
        throw Exception("could not update user details");
      }

      await supabase.from("scribes_points").insert(
        {
          "user_id": userDetails[0]["user_id"]
        }
      );
      debugPrint("succesfully saved scribe details");
    } catch (e) {
      debugPrint("Error saving volunteer details: $e");
      rethrow;
    }
  }

  Future<String> uploadProfilePhoto(
    Map<String, String> profilePhoto,
    String folder, // scribe or swd
  ) async {
    try {
      // Get the file path and name
      String filePath = profilePhoto['path']!;
      String fileName = profilePhoto['name']!;

      // Create a reference to the correct folder in Supabase storage
      final storage = supabase.storage.from('profile-pictures');

      // Create a File object from the path
      final file = File(filePath);

      final uploadResponse = await storage.upload(
        '$folder/$fileName', // Path in the folder
        file,
      );

      final String publicUrl = storage.getPublicUrl('$folder/$fileName');

      debugPrint("File uploaded successfully: $uploadResponse");
      debugPrint("Public URL: $publicUrl");

      bool isFileExists = await file.exists();
      if (isFileExists) {
        await file.delete();
        debugPrint("File deleted from cache after upload.");
      } else {
        debugPrint("File does not exist at the cached path.");
      }

      return publicUrl.toString();
    } catch (e) {
      // Handle errors
      debugPrint("Error uploading file: $e");
      rethrow;
    }
  }

  Future<void> uploadCertificates(
    userId,
    List<Map<String, dynamic>> certificates,
  ) async {
    try {
      for (var certificate in certificates) {
        // Get file path and name
        String filePath = certificate['path']!;
        String fileName = certificate['name']!;

        // Create a File object
        final file = File(filePath);

        // Upload to Supabase storage
        final storage = supabase.storage.from('certificates');

        // Upload file with user_id in path for better organization
        final String storagePath =
            '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        await storage.upload(storagePath, file);

        // Get public URL
        final String publicUrl = storage.getPublicUrl(storagePath);

        // Store certificate details in the certificates table
        await supabase.from('certificates').insert({
          'user_id': userId,
          'certificate_name': fileName,
          'certificate_url': publicUrl,
        });

        // Clean up local file
        if (await file.exists()) {
          await file.delete();
        }
      }
      debugPrint('All certificates uploaded successfully');
    } catch (e) {
      debugPrint('Error uploading certificates: $e');
      rethrow;
    }
  }

  Future<String> uploadCollegeIdentity(
    Map<String, String> collegeIdentity,
  ) async {
    try {
      // Validate input
      if (collegeIdentity['path'] == null || collegeIdentity['name'] == null) {
        throw Exception('File path or name is missing');
      }

      String filePath = collegeIdentity['path']!;
      String fileName = collegeIdentity['name']!;
      String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Initialize Supabase storage
      final storage = supabase.storage.from('college-identity');
      final file = File(filePath);

      // Upload file
      final uploadResponse = await storage.upload(uniqueFileName, file);

      // Generate public URL
      final String publicUrl = storage.getPublicUrl(uniqueFileName);

      debugPrint("File uploaded successfully: $uploadResponse");
      debugPrint("Public URL: $publicUrl");

      // Delete local file after upload
      if (await file.exists()) {
        await file.delete();
        debugPrint("File deleted from cache after upload.");
      } else {
        debugPrint("File does not exist at the cached path.");
      }

      return publicUrl.toString();
    } catch (e) {
      debugPrint("Error uploading file: ${e.toString()}");
      rethrow; // Rethrow to handle upstream if necessary
    }
  }

  Future<void> updateDetails(id, field, value) async {
    try {
      await supabase.from("users").update({field: value}).eq("user_id", id);
    } catch (e) {
      debugPrint("could not update user data due to $e");
      rethrow;
    }
  }

  Future<void> deleteOldImageFromSupabase(role, String oldImageUrl) async {
    if (oldImageUrl.isNotEmpty &&
        oldImageUrl !=
            "https://images.pexels.com/photos/7366257/pexels-photo-7366257.jpeg?auto=compress&cs=tinysrgb&w=600") {
      try {
        // Extract the image file path from the URL (Assuming it's stored in Supabase with a known path)
        String filePath = extractFilePathFromUrl(oldImageUrl);

        // Call Supabase Storage API to delete the old image
        await supabase.storage.from('profile-pictures').remove([
          "$role/$filePath",
        ]);

        debugPrint("Old image deleted successfully from Supabase");
      } catch (e) {
        debugPrint("Failed to delete old image: $e");
      }
    }
  }

  String extractFilePathFromUrl(String imageUrl) {
    Uri uri = Uri.parse(imageUrl);
    debugPrint(uri.pathSegments.last);
    return uri.pathSegments.last;
  }

  saveFcmToken(email) async {
    try {
      final fCMToken = await FirebaseMessaging.instance.getToken();

      await supabase
          .from("users")
          .update({"fcm_token": fCMToken})
          .eq("email", email);

      debugPrint("saved user's token");
    } catch (e) {
      debugPrint("Could not save FCM token due to $e");
    }
  }
}
