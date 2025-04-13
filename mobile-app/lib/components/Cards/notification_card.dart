import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String time;
  final String description;
  final IconData icon; // Adding an icon for visual appeal

  const NotificationCard({
    super.key,
    required this.title,
    required this.time,
    required this.description,
    this.icon = Icons.notifications, // Default icon
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        onTap: () => _showBottomSheet(context),
        splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Icon with Background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and Preview
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description.length > 80 
                              ? '${description.substring(0, 80)}...' 
                              : description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Bottom row with time and button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Time with icon
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Icons.access_time,
                  //       size: 14,
                  //       color: Colors.grey.shade600,
                  //     ),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       time,
                  //       style: TextStyle(
                  //         fontSize: 12,
                  //         color: Colors.grey.shade600,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  
                  // View Button
                  TextButton.icon(
                    onPressed: () => _showBottomSheet(context),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text("View Details"),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Close button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
              
              // Time information
              // Padding(
              //   padding: const EdgeInsets.only(left: 40, top: 4, bottom: 16),
              //   child: Row(
              //     children: [
              //       Icon(
              //         Icons.calendar_today,
              //         size: 14,
              //         color: Colors.grey.shade600,
              //       ),
              //       const SizedBox(width: 4),
              //       Text(
              //         time,
              //         style: TextStyle(
              //           fontSize: 14,
              //           color: Colors.grey.shade600,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              
              const Divider(),
              const SizedBox(height: 16),
              
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
             
            ],
          ),
        );
      },
    );
  }
}