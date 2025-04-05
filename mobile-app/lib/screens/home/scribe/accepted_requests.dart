import 'package:client/components/Cards/exam_card.dart';
import 'package:client/screens/home/scribe/scribe_home.dart';
import 'package:client/services/auth/auth.dart';
import 'package:client/services/scribeallotment/scribe_allotment.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AcceptedRequests extends StatefulWidget {
  const AcceptedRequests({super.key});

  @override
  State<AcceptedRequests> createState() => _AcceptedRequestsState();
}

class _AcceptedRequestsState extends State<AcceptedRequests> {
  List<Map<String, dynamic>> acceptedRequests = [];
  bool isLoading = true;
  final supabase = Supabase.instance.client;

  getAcceptedRequests() async {
    try {
      final loggedInUser = await Auth().getCurrentUser();

      final userDetails =
          await supabase
              .from("users")
              .select("user_id")
              .eq("email", loggedInUser!.email!)
              .single();

      final response = await supabase
          .from("exam_requests")
          .select("""
        request_id,
        exam_date,
        exam_time,
        subject_name,
        swd:users!exam_requests_student_id_fkey1(name, email, phone_number)
    """)
          .eq("status", "FULFILLED")
          .eq("scribe_id", userDetails["user_id"]);

      debugPrint(
        "\n\nAccepted requests length is ${response.length} and list is \n $response",
      );

      if (response.length > 1) {
        response.sort((a, b) {
          DateTime dateTimeA = DateTime.parse(
            "${a["exam_date"]} ${a["exam_time"]}",
          );
          DateTime dateTimeB = DateTime.parse(
            "${b["exam_date"]} ${b["exam_time"]}",
          );
          return dateTimeA.compareTo(dateTimeB);
        });
      }

      setState(() {
        acceptedRequests = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("could not get accepted requests of swd due to $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAcceptedRequests();
  }

  void cancelRequest(requestId){
    ScribeAllotment().rejectAcceptedRequest(requestId);
    final updatedRequests = acceptedRequests.where((request) => 
          request["request_id"] != requestId).toList();
      
      setState(() {
        acceptedRequests = updatedRequests;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          "ACCEPTED REQUESTS",
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ScribeHome()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text("Back to Home"),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A237E),
                      ),
                    )
                    : acceptedRequests.isEmpty
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "No accepted requests found",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children:
                            acceptedRequests.map((request) {
                              return ExamCard(
                                requestId: request["request_id"],
                                subjectName: request["subject_name"],
                                examDateTime: DateTime.parse(
                                  "${request["exam_date"]} ${request["exam_time"]}",
                                ),
                                userDetails: request["swd"],
                                forScribe: false,
                                onCancel: () => cancelRequest(request["request_id"]),
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
