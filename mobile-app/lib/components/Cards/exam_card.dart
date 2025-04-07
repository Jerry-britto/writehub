import 'package:client/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ExamCard extends StatelessWidget {
  ExamCard({
    super.key,
    required this.subjectName,
    required this.examDateTime,
    required this.userDetails,
    this.forScribe = true,
    this.isDecline = true,
    this.requestId,
    this.onCancel
  });
  final String subjectName;
  final int? requestId;
  final DateTime examDateTime;
  final Map<String, dynamic> userDetails;
  bool forScribe, isDecline;
  final VoidCallback?onCancel;

  void _showuserDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                forScribe ? 'Scribe Details' : "SWD Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                Icons.person,
                'Name',
                userDetails['name'] ?? 'Not assigned',
              ),
              const Divider(height: 24),
              _buildDetailRow(
                Icons.email,
                'Email',
                userDetails['email'] ?? 'Not available',
              ),
              const Divider(height: 24),
              _buildDetailRow(
                Icons.phone,
                'Phone',
                userDetails['phone_number'] ?? 'Not available',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd MMM yyyy').format(examDateTime);
    final String formattedTime = DateFormat('h:mm a').format(examDateTime);

    void confirmBeforeDelete() {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Are you sure you want to decline the booking"),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // ScribeAllotment().rejectAcceptedRequest(requestId);
                    onCancel!();
                    Navigator.pop(context);
                    SnackBarUtil.showSnackBar(context, "Cancelled Booking successfully");
                  },
                  child: const Text("Yes"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
      );
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade100, width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subjectName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.access_time, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (isDecline)
                    ElevatedButton(
                      onPressed: () => confirmBeforeDelete(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel Booking'),
                    ),

                  ElevatedButton.icon(
                    onPressed: () => _showuserDetails(context),
                    icon: const Icon(Icons.person),
                    label:
                        forScribe
                            ? Text('View Scribe Details')
                            : Text("View SWD Details"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
