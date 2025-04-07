import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RewardCard extends StatelessWidget {
  final String rewardName;
  final DateTime obtainedAt;
  final IconData iconData;
  final Color iconColor;

  const RewardCard({
    super.key,
    required this.rewardName,
    required this.obtainedAt,
    required this.iconData,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(obtainedAt);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(iconData, color: iconColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rewardName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Obtained on: $formattedDate",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
