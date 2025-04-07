import 'package:client/components/Cards/exam_card.dart';
import 'package:client/screens/home/scribe/accepted_requests.dart';
import 'package:client/screens/home/scribe/incoming_requests.dart';
import 'package:client/services/auth/auth.dart';
import 'package:client/services/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  String name = "";
  List<Map<String, dynamic>> acceptedRequests = [];
  int userId = 0;
  final supabase = Supabase.instance.client;
  
  Future<void> getDetails() async {
    try {
      firebase_auth.User? user = await Auth().getCurrentUser();
      if (user != null) {
        var details = await Profile().getDetails(user.email.toString());
        setState(() {
          name = details["name"] ?? "No Name";
          userId = details["user_id"];
        });
        // Call getAcceptedRequests after user details are fetched
        await getAcceptedRequests();
      } else {
        debugPrint("No user is logged in");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> getAcceptedRequests() async {
    try {
      final response = await supabase
          .from("exam_requests")
          .select("""
        exam_date,
        exam_time,
        subject_name,
        swd:users!exam_requests_student_id_fkey1(name, email, phone_number)
      """)
          .eq("status", "FULFILLED")
          .eq("scribe_id", userId)
          .limit(2);

      debugPrint(
        "\n\nAccepted requests length is ${response.length} and list is \n $response",
      );

      // Sort by exam date and time
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
      debugPrint("Could not get accepted requests due to $e");
      setState(() {
        isLoading = false;
      });
    }
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
        debugPrint("Refreshing accepted requests");
        await getAcceptedRequests();
      },
      child: Container(
        padding: EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back $name",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => IncomingRequests(userId: userId),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9C4),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 10,
                            ),
                            child: const Center(
                              child: Text(
                                "INCOMING REQUESTS",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const AcceptedRequests(),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9C4),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 10,
                            ),
                            child: const Center(
                              child: Text(
                                "ACCEPTED REQUESTS",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Your Upcoming Exams",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  const SizedBox(height: 16),
                  
                  // Upcoming Exams Section
                  acceptedRequests.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No upcoming exams found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: acceptedRequests.length,
                                  itemBuilder: (context, index) {
                                    final request = acceptedRequests[index];
                                    DateTime examDateTime;
                                    try {
                                      examDateTime = DateTime.parse(
                                        "${request["exam_date"]} ${request["exam_time"]}",
                                      );
                                    } catch (e) {
                                      examDateTime = DateTime.now();
                                      debugPrint("Error parsing date: $e");
                                    }
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: ExamCard(
                                        subjectName: request["subject_name"] ?? "Unknown Subject",
                                        examDateTime: examDateTime,
                                        userDetails: request["swd"] ?? {},
                                        forScribe: false,
                                        isDecline: false,
                                      ),
                                    );
                                  },
                                ),
                              // View More Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const AcceptedRequests(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "View More",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                              ],
                            ),
                          ),
                        ),
                  
                ],
              ),
      ),
    );
  }
}