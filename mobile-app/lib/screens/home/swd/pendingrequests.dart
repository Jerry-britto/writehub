import 'package:client/components/Cards/pending_request_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Pendingrequests extends StatefulWidget {
  const Pendingrequests({super.key, this.userId});
  final int? userId;

  @override
  State<Pendingrequests> createState() => _PendingrequestsState();
}

class _PendingrequestsState extends State<Pendingrequests> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pendingRequests = [];
  bool isLoading = true;
  void getPendingRequests() async {
    debugPrint("getting pending requests");
    try {
      List<Map<String, dynamic>> response = await supabase
          .from("exam_requests")
          .select("request_id,subject_name,exam_date,exam_time")
          .eq("student_id", widget.userId!)
          .eq("status", "PENDING");

      debugPrint(
        "\n\nNo of pending requests is ${response.length} which are $response\n",
      );
      setState(() {
        pendingRequests = response;
        isLoading = false; // Set loading to false when data is fetched
      });
    } catch (e) {
      debugPrint("could not retrieve requests due to $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF1A237E),
        title: Text(
          "PENDING REQUESTS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
      ),
      backgroundColor: Color(0xFFBBDEFB),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : pendingRequests.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "No pending requests found",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children:
                      pendingRequests.map((request) {
                        // Convert exam_date and exam_time to DateTime
                        DateTime dateTime = DateTime.parse(
                          '${request['exam_date']} ${request['exam_time']}',
                        );

                        return PendingRequestCard(
                          subjectName: request['subject_name'],
                          dateTime: dateTime,
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
