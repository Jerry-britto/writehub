import 'package:client/components/Cards/exam_card.dart';
import 'package:client/services/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AcceptedRequests extends StatefulWidget {
  const AcceptedRequests({super.key});

  @override
  State<AcceptedRequests> createState() => _AcceptedrequestsState();
}

class _AcceptedrequestsState extends State<AcceptedRequests> {
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
        exam_date,
        exam_time,
        subject_name,
        scribe:users!exam_requests_scribe_id_fkey1(name, email, phone_number)
    """)
          .eq("status", "FULFILLED")
          .eq("student_id", userDetails["user_id"]);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF1A237E),
        title: Text(
          "ACCEPTED REQUESTS",
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
              ? Center(
                child: const CircularProgressIndicator(
                  color: Color(0xFF1A237E),
                ),
              )
              : acceptedRequests.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
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
                          subjectName: request["subject_name"],
                          examDateTime: DateTime.parse(
                            "${request["exam_date"]} ${request["exam_time"]}",
                          ),
                          userDetails: request["scribe"],
                          isDecline: false,
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
