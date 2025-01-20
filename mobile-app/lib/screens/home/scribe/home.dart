import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Welcome back Alfred",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4), // Light yellow background
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4), // Shadow position
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10, // Adjusted for inner spacing
                  ),
                  child: const Center(
                    child: Text(
                      "INCOMING REQUESTS",
                      style: TextStyle(
                        fontSize: 20, // Adjusted text size
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black text color
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Spacing between the two containers
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4), // Light yellow background
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4), // Shadow position
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 10, // Adjusted for inner spacing
                    ),
                    child: const Center(
                      child: Text(
                        "ACCEPTED REQUESTS",
                        style: TextStyle(
                          fontSize: 20, // Adjusted text size
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Black text color
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30,),
          
           Text(
            "Your Upcoming Exams",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
        ],
      ),
    );
  }
}