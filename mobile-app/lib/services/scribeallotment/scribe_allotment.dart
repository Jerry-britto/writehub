import 'package:client/services/auth/auth.dart';
import 'package:client/services/notifications/notification_send_service.dart';
import 'package:client/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScribeAllotment {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> bookScribe(
    BuildContext context,
    String subjectname,
    String time,
    String date,
  ) async {
    try {
      final user = await Auth().getCurrentUser();
      final email = user?.email;

      if (email == null) {
        SnackBarUtil.showSnackBar(
          context,
          "User not found. Please log in.",
          backgroundColor: Colors.red,
        );
        return;
      }

      // Fetch user_id from users table
      final userResponse =
          await supabase
              .from("users")
              .select("user_id,course,collegeName")
              .eq("email", email)
              .single();

      final userId = userResponse["user_id"];

      debugPrint("User ID: $userId");

      // Insert exam request
      final requestResponse =
          await supabase
              .from("exam_requests")
              .insert({
                "student_id": userId,
                "subject_name": subjectname,
                "exam_date": date,
                "exam_time": time,
                "status": "PENDING",
              })
              .select("request_id")
              .single();
      final requestId = requestResponse["request_id"];

      // Success notification
      SnackBarUtil.showSnackBar(context, "Application submitted");

      try {
        await NotificationSendService().sendNotification(
          "Application received for subject $subjectname",
          "APPLICATION SUBMITTED",
        );
        await supabase.from("notification").insert({
          "user_id": userId,
          "title": "APPLICATION SUBMITTED",
          "message":
              "Your application is being processed will let you know about the assigned scribe",
        });
      } catch (notificationError) {
        debugPrint("while forwarding ");
        debugPrint("Notification send failed: $notificationError");
      }
      await filterAndNotifyScribes(
        userResponse,
        requestId,
        subjectname,
        date,
        time,
      );
    } catch (e) {
      debugPrint("Could not book scribe due to $e");

      String errorMessage = "An error occurred while booking the scribe.";

      if (e is PostgrestException) {
        errorMessage = e.message;
      }

      SnackBarUtil.showSnackBar(
        context,
        errorMessage,
        backgroundColor: Colors.red,
      );
    }
  }

  // filter scribes based on eligibility and send notifications
  Future<void> filterAndNotifyScribes(
    swdUser,
    requestId,
    subjectName,
    date,
    time, [
    int? scribeId,
    String? messageTitle,
  ]) async {
    try {
      debugPrint(
        "Filtering scribes for Request $requestId, Subject $subjectName, Date $date, Time $time",
      );
      debugPrint("\n\n SWD DETAILS: $swdUser \n\n");
      // Step 1: Fetch all potential scribes excluding the same course

      List<Map<String, dynamic>> scribes = [];

      if (scribeId != null) {
        debugPrint("Excluding already assigned scribe for backup scribe");
        scribes = await supabase
            .from("users")
            .select("user_id,name,fcm_token, collegeName")
            .eq("role", "scribe")
            .neq("course", swdUser["course"])
            .neq("user_id", scribeId);
      } else {
        scribes = await supabase
            .from("users")
            .select("user_id, name ,fcm_token, collegeName")
            .eq("role", "scribe")
            .neq("course", swdUser["course"]);
      }

      if (scribes.isEmpty) {
        debugPrint("No eligible scribes found for different courses.");
        return;
      }

      debugPrint(
        "\nNo of scribes ${scribes.length} and list of scribes as same as SWD are $scribes \n",
      );

      // Step 2: Filter out scribes who already have an assigned request on the same date
      List<String> assignedScribes =
          (await supabase
              .from("exam_requests")
              .select("scribe_id")
              .eq("status", "FULFILLED")
              .eq(
                "exam_date",
                date,
                // "2025-04-03"
              )).map<String>((row) => row["scribe_id"].toString()).toList();

      debugPrint(
        "\n\nNo. of scribes assigned on the same day are ${assignedScribes.length} and list is $assignedScribes \n\n",
      );
      if (assignedScribes.isNotEmpty) {
        scribes.removeWhere(
          (scribe) => assignedScribes.contains(scribe["user_id"]),
        );

        debugPrint(
          "\n\n no of scribes filtered due to assigned on same day are ${scribes.length} and list is $scribes \n\n",
        );
      }

      // Step 3: Prioritize scribes from the same college
      List<Map<String, dynamic>> sameCollegeScribes =
          scribes
              .where(
                (scribe) => scribe["collegeName"] == swdUser["collegeName"],
                // (scribe) => scribe["collegeName"] == "SIES COLLEGE",
              )
              .toList();

      debugPrint(
        "\n\nno of scribes ${sameCollegeScribes.length} and list is $sameCollegeScribes",
      );
      // If no scribes found in the same college, expand search to all scribes
      List<Map<String, dynamic>> finalScribes =
          sameCollegeScribes.isNotEmpty ? sameCollegeScribes : scribes;

      // Step 4: Notify the filtered scribes and add them to pending_requests
      for (var scribe in finalScribes) {
        await supabase.from("pending_requests").insert({
          "request_id": requestId,
          "user_id": scribe["user_id"],
        });

        //   // Send push notification to scribe
        await NotificationSendService().sendNotification(
          "HI ${scribe["name"]} there is an exam happening on $date at $time for subject $subjectName. Kindly provide your response",
          messageTitle ?? "New Scribe Request",
          scribe["fcm_token"],
        );

        await supabase.from("notification").insert({
          "user_id": scribe["user_id"],
          "message":
              "HI ${scribe["name"]} there is an exam happening on $date at $time for subject $subjectName. Kindly provide your response",
          "title": messageTitle ?? "New Scribe Request",
        });
      }

      debugPrint(
        "Notified ${finalScribes.length} scribes and added them to pending_requests.",
      );
    } catch (e) {
      debugPrint("Error while filtering scribes due to $e");
    }
  }

  // accept pending request
  Future<String> acceptRequest(int requestId, int scribeId) async {
    try {
      await supabase.rpc(
        "accept_request",
        params: {"accepted_scribe_id": scribeId, "req_id": requestId},
      );

      debugPrint("Request accepted successfully!");

      return "Request accepted successfully";
    } catch (error) {
      debugPrint("Error: $error");

      // Check if the error message contains our custom exception
      if (error.toString().contains("Request has already been accepted")) {
        return "Request has already been accepted";
      }
      return "Something went wrong. Try again.";
    }
  }

  // decline pending request
  Future<String> rejectPendingRequest(userId, requestId) async {
    try {
      await supabase
          .from("pending_requests")
          .delete()
          .eq("request_id", requestId)
          .eq("user_id", userId);
      return "Declined request successfully";
    } catch (e) {
      debugPrint("could not reject pending request due to $e");
      return "Coudl not reject pending request. Please try again";
    }
  }

  // decline accepted request
  Future<void> rejectAcceptedRequest(requestId) async {
    try {
      // get request details along with scribe and swd details
      final requestData =
          await supabase
              .from("exam_requests")
              .update({"status": "BACKUP NEEDED"})
              .eq("request_id", requestId)
              .select("""
              exam_time,exam_date,subject_name,
              swd:users!exam_requests_student_id_fkey1(*),
              scribe:users!exam_requests_scribe_id_fkey1(*)
              """)
              .single();
      debugPrint("\n Request data: $requestData \n ");
      await supabase
          .from("exam_requests")
          .update({"scribe_id": null})
          .eq("request_id", requestId);
      // informing swd about cancellation of booking
      await NotificationSendService().sendNotification(
        "The assigned scribe has declined the booking for ${requestData["subject_name"]} on ${requestData["exam_date"]}. We are on search for a new scribe",
        "In Search for new scribe",
        requestData["swd"]["fcm_token"],
      );

      await supabase.from("notification").insert({
        "title": "In Search for new scribe",
        "message":
            "The assigned scribe has declined the booking for ${requestData["subject_name"]} on ${requestData["exam_date"]}. We are on search for a new scribe",
        "user_id": requestData["swd"]["user_id"],
      });

      // deducting scribes points and notifying him/her about deduction

      await deductScribePoints(
        requestData["scribe"]["user_id"],
        DateTime.parse("${requestData["exam_date"]}"),
      );

      await NotificationSendService().sendNotification(
        "Your points are deducted. Kindly check your updated points",
        "Points Deduction",
        requestData["scribe"]["fcm_token"],
      );

      await supabase.from("notification").insert({
        "title": "Points Deduction",
        "message": "Your points are deducted. Kindly check your updated points",
        "user_id": requestData["scribe"]["user_id"],
      });

      // based on exam data send requests to that many scribes
      DateTime today = DateTime.now();
      today = DateTime(today.year, today.month, today.day);
      DateTime examDate = DateTime.parse(requestData["exam_date"]);
      int daysLeft = examDate.difference(today).inDays;

      // final newExamRequest =
      //     await supabase
      //         .from("exam_requests")
      //         .insert({
      //           "student_id": requestData["swd"]["user_id"],
      //           "subject_name": requestData["subject_name"],
      //           "exam_time": requestData["exam_time"],
      //           "exam_date": requestData["exam_date"],
      //           "status": 'PENDING',
      //         })
      //         .select("request_id")
      //         .single();

      if (daysLeft <= 3) {
        // inform all scribes excluding current scribe
        debugPrint("exam is close by and days left are $daysLeft");
        final scribesList = await supabase
            .from("users")
            .select("user_id,fcm_token,name")
            .eq("role", "scribe")
            .neq("user_id", requestData["scribe"]['user_id']);
        debugPrint(
          "\n Scribes list is ${scribesList.length} => $scribesList\n",
        );
        for (var scribe in scribesList) {
          await supabase.from("pending_requests").insert({
            // "request_id": newExamRequest["request_id"],
            "request_id": requestId,
            "user_id": scribe["user_id"],
          });

          //   // Send push notification to scribe
          await NotificationSendService().sendNotification(
            "HI ${scribe["name"]} We urgently need a scribe on ${requestData["exam_date"]} at ${requestData["exam_time"]}. Kindly provide your response by responding to this message on pending requests section",
            "Urgent Scribe Requirment",
            scribe["fcm_token"],
          );

          await supabase.from("notification").insert({
            "user_id": scribe["user_id"],
            "message":
                "HI ${scribe["name"]} We urgently need a scribe on ${requestData["exam_date"]} at ${requestData["exam_time"]}. Kindly provide your response by responding to this message on pending requests section",
            "title": "Urgent Scribe Requirment",
          });
        }
      } else {
        // use previous filtering mechanism
        debugPrint("exam has still time and days left are $daysLeft");
        await filterAndNotifyScribes(
          requestData["swd"],
          // newExamRequest["request_id"],
          requestId,
          requestData["subject_name"],
          requestData["exam_date"],
          requestData["exam_time"],
          requestData["scribe"]['user_id'],
          "Urgent scribe needed",
        );
      }
    } catch (e) {
      debugPrint("could not reject request due to $e");
    }
  }

  // deduct scribe points
  Future<void> deductScribePoints(int scribeId, DateTime examDate) async {
    try {
      DateTime now = DateTime.now();
      now = DateTime(now.year, now.month, now.day);
      debugPrint(
        "Today's date is - ${now.toString()} and \n Exam date is  ${examDate.toString()}",
      );

      // Calculate days difference between now and exam date
      int daysDifference = examDate.difference(now).inDays;
      debugPrint("Difference in days $daysDifference");

      double deductionPoints;

      if (daysDifference > 7) {
        deductionPoints = 0.5;
      } else if (daysDifference >= 3 && daysDifference <= 7) {
        deductionPoints = 1.0;
      } else if (daysDifference == 2) {
        deductionPoints = 1.8;
      } else if (daysDifference == 1) {
        deductionPoints = 2.3;
      } else {
        deductionPoints = 3.0;
      }

      final response =
          await supabase
              .from('scribes_points')
              .select('points')
              .eq('user_id', scribeId)
              .single();

      debugPrint("User point details: $response");

      // Ensure 'points' is properly extracted as a double
      double currentPoints = (response['points'] as num).toDouble();

      // Skip if points are already 0
      if (currentPoints <= 0) {
        debugPrint("Scribe already has 0 points. No deduction applied.");
        return;
      }

      double newPoints = currentPoints - deductionPoints;

      // Ensure points don't go below 0
      if (newPoints < 0) {
        newPoints = 0.0;
      }

      await supabase
          .from('scribes_points')
          .update({'points': newPoints})
          .eq('user_id', scribeId);

      debugPrint(
        "Successfully deducted points. Previous: $currentPoints, Deduction: $deductionPoints, New: $newPoints",
      );
    } catch (e) {
      debugPrint("Could not deduct scribe's points due to ${e.toString()}");
    }
  }
}
