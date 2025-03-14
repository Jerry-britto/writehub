import 'package:client/services/notifications/notification_send_service.dart';
import 'package:client/services/scribeallotment/scribe_allotment.dart';
import 'package:client/utils/alertbox_util.dart';
import 'package:client/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PendingRequestCard extends StatefulWidget {
  const PendingRequestCard({
    super.key,
    required this.subjectName,
    required this.dateTime,
    this.isScribe = false,
    this.userId,
    this.requestId,
  });

  final String subjectName;
  final DateTime dateTime;
  final bool isScribe;
  final int? userId, requestId;

  @override
  State<PendingRequestCard> createState() => _PendingRequestCardState();
}

class _PendingRequestCardState extends State<PendingRequestCard> {
  @override
  Widget build(BuildContext context) {
    // Format date and time here where we have access to widget
    final String period = DateFormat('a').format(widget.dateTime);
    final String formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(widget.dateTime);
    final String formattedTime = DateFormat('h:mm').format(widget.dateTime);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.subjectName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  '$formattedTime $period',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            widget.isScribe
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // decline request logic
                        String response = await ScribeAllotment()
                            .rejectPendingRequest(
                              widget.userId,
                              widget.requestId,
                            );
                        SnackBarUtil.showSnackBar(context, response);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        // accept request logic
                        String response = await ScribeAllotment().acceptRequest(
                          widget.requestId!,
                          widget.userId!,
                        );
                        DialogUtil.showAlertDialog(
                          context,
                          "Message",
                          response,
                        );
                        if (response == "Request accepted successfully") {
                          final res =
                              await Supabase.instance.client
                                  .from("exam_requests")
                                  .select(
                                    "student_id, subject_name,exam_date,users!exam_requests_student_id_fkey1(fcm_token)",
                                  )
                                  .eq("request_id", widget.requestId!)
                                  .single();

                          debugPrint("swd data is $res");

                          await NotificationSendService().sendNotification(
                            "Congrats a scribe is alloted for your ${res["subject_name"]} exam on ${res["exam_date"]}",
                            "Scribe alloted",
                            res["users"]["fcm_token"],
                          );

                          await Supabase.instance.client
                              .from("notification")
                              .insert({
                                "user_id": res["student_id"],
                                "message":
                                    "Congrats a scribe is alloted for your ${res["subject_name"]} exam on ${res["exam_date"]}",
                                "title": "Scribe Alloted",
                              });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ],
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
