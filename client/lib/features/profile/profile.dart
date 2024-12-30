import 'package:client/utils/snackbar_util.dart';
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
    required List<String> disabilities,
  }) async {
    try {
      // Step 1: Update user details
      final userResponse =
          await supabase
              .from("users")
              .update({"name": name, "phone_number": phoneNumber})
              .eq('email', email.toLowerCase())
              .select();

      if (userResponse.isEmpty) {
        throw Exception("Failed to update user details");
      }
      debugPrint("Updated User Details: $userResponse");

      // Get user ID
      final userId = userResponse[0]['user_id'];
      debugPrint("user id $userId");

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

      // Step 4: insert student details

      await supabase.from('students').insert({
        'user_id': userId,
        'academic_year': academicYear,
        'course': course,
      }).select();
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
    academicYear,
  ) async {
    try {
      final userDetails =
          await supabase
              .from("users")
              .update({"name": name, "phone_number": phoneNumber})
              .eq("email", email)
              .select();
      debugPrint("User details - $userDetails");
      if (userDetails.isEmpty) {
        throw Exception("could not update user details");
      }
      final userId = userDetails[0]['user_id'];
      debugPrint("User id - $userId");

      await supabase.from("scribes").insert({
        "user_id": userId,
        "academic_year": academicYear,
        "course": course,
      }).select();
      debugPrint("succesfully saved scribe details");
    } catch (e) {
      debugPrint("Error saving volunteer details: $e");
      rethrow;
    }
  }
}
