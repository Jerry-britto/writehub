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
}
