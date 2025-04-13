import 'package:client/components/Cards/pending_request_card.dart';
import 'package:client/screens/users/scribe/scribe_home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IncomingRequests extends StatefulWidget {
  const IncomingRequests({super.key, this.userId});
  final int? userId;

  @override
  State<IncomingRequests> createState() => _IncomingRequestsState();
}

class _IncomingRequestsState extends State<IncomingRequests> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Stream for incoming requests
  Stream<List<Map<String, dynamic>>> getIncomingRequestsStream() {
    return supabase
        .from("pending_requests")
        .stream(primaryKey: ["request_id"])
        .eq("user_id", widget.userId!)
        .map((pendingRequests) async {
      // 🔹 Fetch related exam details for each request
      List<Map<String, dynamic>> enrichedRequests = [];

      for (var request in pendingRequests) {
        final examRequest = await supabase
            .from("exam_requests")
            .select("exam_date, exam_time, subject_name")
            .eq("request_id", request["request_id"])
            .maybeSingle();

        if (examRequest != null) {
          enrichedRequests.add({
            ...request,
            "exam_requests": examRequest,
          });
        }
      }
      return enrichedRequests;
    }).asyncMap((event) => event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          "INCOMING REQUESTS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFBBDEFB),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const ScribeHome()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text("Back to Home"),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getIncomingRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading data: ${snapshot.error}"),
                  );
                }

                List<Map<String, dynamic>> incomingRequests = snapshot.data ?? [];

                if (incomingRequests.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "No pending requests found",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: incomingRequests.map((request) {
                      final examRequest = request["exam_requests"];
                      if (examRequest == null) return const SizedBox(); // Skip if null

                      // Convert exam_date and exam_time to DateTime
                      DateTime dateTime = DateTime.parse(
                        '${examRequest['exam_date']} ${examRequest['exam_time']}',
                      );

                      return PendingRequestCard(
                        subjectName: examRequest['subject_name'],
                        dateTime: dateTime,
                        isScribe: true,
                        userId: widget.userId,
                        requestId: request["request_id"],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
